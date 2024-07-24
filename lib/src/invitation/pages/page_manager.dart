// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_callkit/zego_callkit.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/handler.ios.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_ring.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/invitation_notify.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// @nodoc
class ZegoCallInvitationPageManager {
  ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  ZegoCallInvitationNotificationManager? _notificationManager;

  ZegoCallInvitationPageManager({
    required this.callInvitationData,
  });

  final _defaultPackagePrefix = 'packages/zego_uikit_prebuilt_call/';
  final _callerRingtone = ZegoRingtone();
  final _calleeRingtone = ZegoRingtone();

  bool _init = false;
  ZegoCallingMachine? callingMachine;
  bool _invitationTopSheetVisibility = false;
  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  bool _appInBackground = false;

  /// If the call is ended by the end button of iOS CallKit,
  /// the widget navigation of the CallPage will not be properly
  /// execute dispose function.
  ///
  /// As a result, during the next offline call,
  /// the dispose of the previous CallPage will cause confusion in the widget
  /// navigation.
  ZegoCallInvitationData? _invitationDataOfWaitCallPageDisposeInIOSCallKit;
  final _waitCallPageDisposeFlagInIOSCallKit = ValueNotifier<bool>(false);
  Timer? _timerWaitAppResumedFlagInIOSCallKit;

  bool inCallingByIOSBackgroundLock = false;
  StreamSubscription<dynamic>?
      userListStreamSubscriptionInCallingByIOSBackgroundLock;

  /// iOS的bug, 锁屏下接受呼叫，有时候会先收到CallKit的performAnswerCallAction, 后才收到ZIM的onCallInvitationReceived
  /// 这时候需要在onCallInvitationReceived直接同意
  /// todo wait zim sdk fix bug
  bool _hasCallkitIncomingCauseAppInBackground = false;
  bool _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;
  bool _waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;

  ZegoCallInvitationData _invitationData = ZegoCallInvitationData.empty();
  List<ZegoUIKitUser> _invitingInvitees = []; //  only change by inviter
  ZegoCallInvitationLocalParameter _localInvitationParameter =
      ZegoCallInvitationLocalParameter.empty();

  bool get appInBackground => _appInBackground;

  ZegoCallInvitationData get invitationData => _invitationData;

  bool get isAdvanceInvitationMode =>
      ZegoUIKitPrebuiltCallInvitationService()
          .private
          .callInvitationConfig
          ?.canInvitingInCalling ??
      true;

  bool get isGroupCall => _invitationData.invitees.length > 1;

  String get currentCallID => _invitationData.callID;

  List<ZegoUIKitUser> get invitingInvitees => _invitingInvitees;

  ZegoCallInvitationLocalParameter get localInvitationParameter =>
      _localInvitationParameter;

  /// still ring mean nobody accept this invitation
  bool get isNobodyAccepted => _callerRingtone.isRingTimerRunning;

  bool get hasCallkitIncomingCauseAppInBackground =>
      _hasCallkitIncomingCauseAppInBackground;

  set hasCallkitIncomingCauseAppInBackground(value) =>
      _hasCallkitIncomingCauseAppInBackground = value;

  bool get waitingCallInvitationReceivedAfterCallKitIncomingAccepted =>
      _waitingCallInvitationReceivedAfterCallKitIncomingAccepted;

  set waitingCallInvitationReceivedAfterCallKitIncomingAccepted(value) =>
      _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = value;

  bool get waitingCallInvitationReceivedAfterCallKitIncomingRejected =>
      _waitingCallInvitationReceivedAfterCallKitIncomingRejected;

  set waitingCallInvitationReceivedAfterCallKitIncomingRejected(value) =>
      _waitingCallInvitationReceivedAfterCallKitIncomingRejected = value;

  bool get isInCalling =>
      CallingState.kOnlineAudioVideo ==
          (callingMachine?.getPageState() ?? CallingState.kIdle) ||
      inCallingByIOSBackgroundLock;

  Future<void> init({
    required ZegoCallRingtoneConfig ringtoneConfig,
    required ZegoCallInvitationNotificationManager notificationManager,
  }) async {
    if (_init) {
      ZegoLoggerService.logInfo(
        'is init before',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
      return;
    }

    _init = true;

    _notificationManager = notificationManager;

    callingMachine = ZegoCallingMachine(
      pageManager: this,
      callInvitationData: callInvitationData,
    );
    callingMachine!.init();

    initRing(ringtoneConfig);

    ZegoCallMiniOverlayMachine().listenStateChanged(
      onMiniOverlayMachineStateChanged,
    );

    ZegoLoggerService.logInfo(
      'init, appID:${callInvitationData.appID}, '
      // 'appSign:${callInvitationConfig.appSign},'
      'userID:${callInvitationData.userID}, '
      'userName: ${callInvitationData.userName}',
      tag: 'call-invitation',
      subTag: 'page manager',
    );
  }

  void uninit() {
    if (!_init) {
      ZegoLoggerService.logInfo(
        'no init, not need to uninit',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _init = false;

    _notificationManager = null;

    _invitationTopSheetVisibility = false;
    _appInBackground = false;
    _hasCallkitIncomingCauseAppInBackground = false;
    _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;
    _waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;
    userListStreamSubscriptionInCallingByIOSBackgroundLock?.cancel();

    _invitationData = ZegoCallInvitationData.empty();
    _invitingInvitees.clear();
    _localInvitationParameter = ZegoCallInvitationLocalParameter.empty();

    ZegoCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);

    removeStreamListener();
  }

  void initRing(ZegoCallRingtoneConfig ringtoneConfig) {
    if (ringtoneConfig.outgoingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset caller ring, source path:${ringtoneConfig.outgoingCallPath}',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
      _callerRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.outgoingCallPath!,
        isVibrate: false,
      );
    } else {
      _callerRingtone.init(
        prefix: _defaultPackagePrefix,
        sourcePath: 'assets/invitation/audio/outgoing.mp3',
        isVibrate: false,
      );
    }
    if (ringtoneConfig.incomingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset callee ring, source path:${ringtoneConfig.incomingCallPath}',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
      _calleeRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.incomingCallPath!,
        isVibrate: true,
      );
    } else {
      _calleeRingtone.init(
        prefix: _defaultPackagePrefix,
        sourcePath: 'assets/invitation/audio/incoming.mp3',
        isVibrate: true,
      );
    }
  }

  void listenStream() {
    ZegoLoggerService.logInfo(
      'listen stream, '
      'isAdvanceInvitationMode:$isAdvanceInvitationMode, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    // check plugin installed
    removeStreamListener();

    if (isAdvanceInvitationMode) {
      _streamSubscriptions
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInvitationUserStateChangedStream()
            .where((event) => ZegoCallTypeExtension.isCallType(event.type))
            .listen(onInvitationUserStateChanged))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInvitationReceivedStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationReceived))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInvitationTimeoutStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInvitationCanceledStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationCanceled))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getAdvanceInvitationEndedStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationEnded));
    } else {
      _streamSubscriptions
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationUserStateChangedStream()
            .listen(onInvitationUserStateChanged))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationReceivedStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationReceived))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationAcceptedStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationAccepted))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationTimeoutStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationResponseTimeoutStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationResponseTimeout))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationRefusedStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationRefused))
        ..add(ZegoUIKit()
            .getSignalingPlugin()
            .getInvitationCanceledStream()
            .where((param) =>
                ZegoCallTypeExtension.isCallType((param['type'] as int?) ?? -1))
            .listen(onInvitationCanceled));
    }
  }

  void removeStreamListener() {
    ZegoLoggerService.logInfo(
      'remove stream',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    for (final streamSubscription in _streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  void onLocalAddInvitation({
    required String callID,
    required List<ZegoUIKitUser> invitees,
    required ZegoCallInvitationType invitationType,
    required String customData,
    required String code,
    required String message,
    required String invitationID,
    required List<String> errorInvitees,
  }) {
    ZegoLoggerService.logInfo(
      'local add invitation, '
      'call id:$callID, '
      'invitees:$invitees, '
      'type:$invitationType, '
      'customData:$customData, '
      'code:$code, '
      'message:$message, '
      'error invitees:$errorInvitees, '
      'invitation id:$invitationID, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'add invitation error!!! '
        'code:$code, message:$message',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
      return;
    }

    _invitingInvitees = [
      ..._invitingInvitees,
      ...invitees,
    ];
    _invitingInvitees.removeWhere(
      (invitee) => errorInvitees.contains(invitee.id),
    );

    _invitationData.invitees = [
      ..._invitationData.invitees,
      ...invitees,
    ];

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onLocalSendInvitation({
    required String callID,
    required List<ZegoUIKitUser> invitees,
    required ZegoCallInvitationType invitationType,
    required String customData,
    required String code,
    required String message,
    required String invitationID,
    required List<String> errorInvitees,
    required ZegoCallInvitationLocalParameter localConfig,
  }) {
    ZegoLoggerService.logInfo(
      'local send invitation, '
      'call id:$callID, '
      'invitees:$invitees, '
      'type:$invitationType, '
      'customData:$customData, '
      'code:$code, '
      'message:$message, '
      'error invitees:$errorInvitees, '
      'invitation id:$invitationID, '
      'localConfig:$localConfig, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'send invitation error!!! '
        'code:$code, message:$message',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
      return;
    }

    _localInvitationParameter = localConfig;

    _invitingInvitees = List.from(invitees);
    _invitingInvitees.removeWhere(
      (invitee) => errorInvitees.contains(invitee.id),
    );

    _invitationData
      ..callID = callID
      ..invitationID = invitationID
      ..inviter = ZegoUIKit().getLocalUser()
      ..invitees = List.from(invitees)
      ..type = invitationType
      ..customData = customData;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (_invitingInvitees.isNotEmpty) {
      _callerRingtone.startRing();

      if (isGroupCall) {
        /// group call, enter room directly
        callingMachine?.stateOnlineAudioVideo.enter();
      } else {
        /// single call
        if (ZegoCallInvitationType.voiceCall == _invitationData.type) {
          callingMachine?.stateCallingWithVoice.enter();
        } else {
          if (callInvitationData
              .requireConfig(_invitationData)
              .turnOnCameraWhenJoining) {
            ZegoUIKit.instance.turnCameraOn(true);
          }

          callingMachine?.stateCallingWithVideo.enter();
        }
      }
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation(String code, String message) {
    ZegoLoggerService.logInfo(
      'local accept invitation, code:$code, message:$message, '
      'app in background:$_appInBackground',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    callInvitationData.invitationEvents?.onIncomingCallAcceptButtonPressed
        ?.call();

    _calleeRingtone.stopRing();

    ///  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (Platform.isIOS && _appInBackground) {
      ZegoLoggerService.logInfo(
        'accept call by callkit in background-locked, manually enter room',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      if (_waitCallPageDisposeFlagInIOSCallKit.value) {
        /// If the call is ended by the end button of iOS CallKit,
        /// the widget navigation of the CallPage will not be properly
        /// execute dispose function.
        ///
        /// As a result, during the next offline call,
        /// the dispose of the previous CallPage will cause confusion in the widget
        /// navigation.
        ///
        /// Here, because call page had not disposed cause by previous
        /// callkit end, but now next call is incoming, so listening for the
        /// dispose of the previous call page, incoming call will be enter after
        /// previous dispose
        _waitCallPageDisposeFlagInIOSCallKit.addListener(
          onWaitingCallPageDisposeInIOSCallKit,
        );
      } else {
        inCallingByIOSBackgroundLock = true;

        /// At this point, when answering a CallKit call on iOS lock screen,
        /// the audio-video view interface not be rendered properly, causing the normal in-room logic to not run.
        /// Therefore, it is necessary to manually enter the room at this point.

        ZegoUIKit().login(
          callInvitationData.userID,
          callInvitationData.userName,
        );

        ZegoUIKit()
            .init(
          appID: callInvitationData.appID,
          appSign: callInvitationData.appSign,
        )
            .then((value) async {
          ZegoUIKit()
            ..turnMicrophoneOn(true)
            ..setAudioOutputToSpeaker(true);

          await ZegoUIKit()
              .joinRoom(invitationData.callID, token: callInvitationData.token)
              .then((result) async {
            userListStreamSubscriptionInCallingByIOSBackgroundLock?.cancel();
            userListStreamSubscriptionInCallingByIOSBackgroundLock = ZegoUIKit()
                .getUserLeaveStream()
                .listen(onUserLeaveInIOSBackgroundLockCalling);

            if (result.errorCode != 0) {
              ZegoLoggerService.logError(
                'accept call by callkit in background-locked, failed to login room:${result.errorCode},${result.extendedData}',
                tag: 'call-invitation',
                subTag: 'page manager',
              );
            }
          });
        });
      }
    } else {
      callingMachine?.stateOnlineAudioVideo.enter();
    }
  }

  void onWaitingAppResumedInIOSCallKit(
    AppLifecycleState appLifecycleState,
  ) {
    if (appLifecycleState != AppLifecycleState.resumed) {
      return;
    }

    ZegoLoggerService.logInfo(
      'app resumed, try enter current invitation call',
      tag: 'call-invitation',
      subTag: 'prebuilt',
    );

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(onWaitingAppResumedInIOSCallKit);
    _timerWaitAppResumedFlagInIOSCallKit?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      enterCallAfterCallPageDisposeInIOSCallKit();
    });
  }

  Future<void> onWaitingCallPageDisposeInIOSCallKit() async {
    /// If the call is ended by the end button of iOS CallKit,
    /// the widget navigation of the CallPage will not be properly
    /// execute dispose function.
    ///
    /// As a result, during the next offline call,
    /// the dispose of the previous CallPage will cause confusion in the widget
    /// navigation.
    ///
    /// Here, the previous call page was destroyed.
    /// Only at this moment does the page navigation and enter room.
    _waitCallPageDisposeFlagInIOSCallKit.removeListener(
      onWaitingCallPageDisposeInIOSCallKit,
    );

    ZegoLoggerService.logInfo(
      'call page dispose, try enter current invitation call',
      tag: 'call-invitation',
      subTag: 'prebuilt',
    );

    /// waits for a maximum of one second and executes immediately if it exceeds that time.
    _timerWaitAppResumedFlagInIOSCallKit = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        ZegoUIKit()
            .adapterService()
            .unregisterMessageHandler(onWaitingAppResumedInIOSCallKit);
        _timerWaitAppResumedFlagInIOSCallKit?.cancel();

        enterCallAfterCallPageDisposeInIOSCallKit();
      },
    );
    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(onWaitingAppResumedInIOSCallKit);
  }

  void enterCallAfterCallPageDisposeInIOSCallKit() {
    /// assign invitation data from cache
    if (null != _invitationDataOfWaitCallPageDisposeInIOSCallKit) {
      _invitationData = _invitationDataOfWaitCallPageDisposeInIOSCallKit!;
    }

    ZegoLoggerService.logInfo(
      'call page dispose, enter cache invitation call by callkit:$_invitationData',
      tag: 'call-invitation',
      subTag: 'prebuilt',
    );

    callingMachine?.stateOnlineAudioVideo.enter();

    /// clear
    cacheInvitationDataForWaitCallPageDisposeInIOSCallKit(false);
    setWaitCallPageDisposeFlag(false);
  }

  void onUserLeaveInIOSBackgroundLockCalling(List<ZegoUIKitUser> users) {
    if (ZegoUIKit().getRemoteUsers().isEmpty) {
      ZegoLoggerService.logInfo(
        'on user leave in iOS background lock calling',
        tag: 'call-invitation',
        subTag: 'prebuilt',
      );

      userListStreamSubscriptionInCallingByIOSBackgroundLock?.cancel();

      ///  If the remote users has already ended the call, it is necessary to clear the current CallKit call.
      clearAllCallKitCalls();
    }
  }

  void onLocalRefuseInvitation(
    String code,
    String message, {
    bool needClearCallKit = true,
  }) {
    ZegoLoggerService.logInfo(
      'local refuse invitation, code:$code, message:$message, lifecycleState:${WidgetsBinding.instance.lifecycleState}',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    callInvitationData.invitationEvents?.onIncomingCallDeclineButtonPressed
        ?.call();

    restoreToIdle(
      needClearCallKit: needClearCallKit,
    );
  }

  void onLocalCancelInvitation(
      String code, String message, List<String> errorInvitees) {
    ZegoLoggerService.logInfo(
      'local cancel invitation, code:$code, message:$message, error invitees, $errorInvitees',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    callInvitationData.invitationEvents?.onOutgoingCallCancelButtonPressed
        ?.call();

    _invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on invitation user state changed, event:$event',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (event.invitationID == _invitationData.invitationID) {
      for (var userInfo in event.callUserList) {
        switch (userInfo.state) {
          case ZegoSignalingPluginInvitationUserState.accepted:
            if (userInfo.userID != ZegoUIKit().getLocalUser().id) {
              onInvitationAccepted({
                'invitee': ZegoUIKitUser(id: userInfo.userID, name: ''),
                'data': userInfo.extendedData,
              });
            }
            break;
          case ZegoSignalingPluginInvitationUserState.rejected:
            if (userInfo.userID != ZegoUIKit().getLocalUser().id) {
              onInvitationRefused({
                'invitee': ZegoUIKitUser(id: userInfo.userID, name: ''),
                'data': userInfo.extendedData,
              });
            }
            break;
          case ZegoSignalingPluginInvitationUserState.timeout:
            if (userInfo.userID == ZegoUIKit().getLocalUser().id) {
              /// local timeout
              onInvitationResponseTimeout({
                'invitees': [
                  ZegoUIKitUser(id: userInfo.userID, name: ''),
                ],
                'data': userInfo.extendedData,
              });
            }
            break;
          case ZegoSignalingPluginInvitationUserState.inviting:
          case ZegoSignalingPluginInvitationUserState.offline:
          case ZegoSignalingPluginInvitationUserState.received:
          case ZegoSignalingPluginInvitationUserState.notYetReceived:
          case ZegoSignalingPluginInvitationUserState.quited:
          case ZegoSignalingPluginInvitationUserState.ended:
          case ZegoSignalingPluginInvitationUserState.cancelled:
          case ZegoSignalingPluginInvitationUserState.beCanceled:
          case ZegoSignalingPluginInvitationUserState.unknown:
            break;
        }

        if ([
          ZegoSignalingPluginInvitationUserState.accepted,
          ZegoSignalingPluginInvitationUserState.rejected,
          ZegoSignalingPluginInvitationUserState.timeout,
          ZegoSignalingPluginInvitationUserState.beCanceled,
        ].contains(userInfo.state)) {
          final oldValue = List<ZegoCallUser>.from(
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .invitingUsersNotifier
                  .value);
          oldValue.removeWhere((user) => user.id == userInfo.userID);
          ZegoUIKitPrebuiltCallInvitationService()
              .private
              .invitingUsersNotifier
              .value = oldValue;
        }
      }
    }

    callInvitationData.invitationEvents?.onInvitationUserStateChanged
        ?.call(event.callUserList);
  }

  ///title:user_073493,
  ///content:,
  ///extras:{
  ///body: Incoming video call...,
  ///title: user_073493,
  /// payload: {
  /// "inviter_name":"user_073493",
  /// "type":1,
  /// "data":"{
  /// \"call_id\":\"call_073493_1694161894381\",
  /// \"invitees\":[{\"user_id\":\"946042\",\"user_name\":\"user_946042\"}],
  /// \"timeout\":60,
  /// \"custom_data\":\"\
  /// "}
  /// "},
  /// call_id: 14400815982535765263}
  ///
  /// inviter:{id:073493, name:user_073493, in-room attributes:{}, camera:false, microphone:false, microphone mute mode:false },
  /// type:1,
  /// data:{"call_id":"call_073493_1694162272838","invitees":[{"user_id":"946042","user_name":"user_946042"}],"timeout":60,"custom_data":""}
  Future<void> onInvitationReceived(Map<String, dynamic> params) async {
    var inviter = ZegoUIKitUser.empty();
    if (params['inviter'] is ZegoUIKitUser) {
      inviter = params['inviter']!;
    } else if (params['inviter'] is Map<String, dynamic>) {
      inviter =
          ZegoUIKitUser.fromJson(params['inviter'] as Map<String, dynamic>);
    }
    final int type = params['type']!; // call type
    final String data = params['data']!; // extended field

    /// zim call id
    final invitationID = params['invitation_id'] as String? ?? '';

    /// todo@yuyj offlinecall bug, 接受事件先于 received事件，时序问题
    // flag[1] = true

    ZegoLoggerService.logInfo(
      'on invitation received, state:${WidgetsBinding.instance.lifecycleState}, '
      '_init:$_init, inviter:$inviter, type:$type, in background: $_appInBackground, '
      'data:$data, params:$params',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (_invitationData.callID.isNotEmpty ||
        CallingState.kIdle !=
            (callingMachine?.getPageState() ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'auto refuse this call, because is busy, '
        'is inviting: ${_invitationData.callID.isNotEmpty}, '
        'current state: ${callingMachine?.getPageState() ?? CallingState.kIdle}',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      if (isAdvanceInvitationMode) {
        ZegoUIKit()
            .getSignalingPlugin()
            .refuseAdvanceInvitation(
              inviterID: inviter.id,
              invitationID: invitationID,
              data: ZegoCallInvitationRejectRequestProtocol(
                reason: ZegoCallInvitationProtocolKey.refuseByBusy,
                targetInvitationID: invitationID,
              ).toJson(),
            )
            .then((result) {
          ZegoLoggerService.logInfo(
            'auto refuse result, $result',
            tag: 'call-invitation',
            subTag: 'page manager',
          );
        });
      } else {
        ZegoUIKit()
            .getSignalingPlugin()
            .refuseInvitation(
              inviterID: inviter.id,
              data: ZegoCallInvitationRejectRequestProtocol(
                reason: ZegoCallInvitationProtocolKey.refuseByBusy,
                targetInvitationID: invitationID,
              ).toJson(),
            )
            .then((result) {
          ZegoLoggerService.logInfo(
            'auto refuse result, $result',
            tag: 'call-invitation',
            subTag: 'page manager',
          );
        });
      }

      return;
    }

    final sendRequestProtocol =
        ZegoCallInvitationSendRequestProtocol.fromJson(data);
    _invitationData
      ..customData = sendRequestProtocol.customData
      ..callID = sendRequestProtocol.callID
      ..invitationID = invitationID
      ..invitees = List.from(sendRequestProtocol.invitees)
      ..inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name)
      ..type = ZegoCallTypeExtension.mapValue[type] ??
          ZegoCallInvitationType.voiceCall;

    ZegoLoggerService.logInfo(
      '_invitationData:$_invitationData',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (_waitCallPageDisposeFlagInIOSCallKit.value) {
      cacheInvitationDataForWaitCallPageDisposeInIOSCallKit(true);
    }

    final callKitCallID = await getOfflineCallKitCallID();
    ZegoLoggerService.logInfo(
      '_waitingCallInvitationReceivedAfterCallKitIncomingAccepted:$_waitingCallInvitationReceivedAfterCallKitIncomingAccepted, '
      'callkit call id:$callKitCallID',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (Platform.isAndroid) {
      if (_waitingCallInvitationReceivedAfterCallKitIncomingAccepted) {
        _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;
        ZegoLoggerService.logInfo(
          'auto agree, cause waiting invitation received after callkit accept',
          tag: 'call-invitation',
          subTag: 'page manager',
        );

        /// todo wait zim sdk fix bug
        if (Platform.isAndroid) {
          clearAllCallKitCalls();
        }

        clearOfflineCallKitCallID();
        clearOfflineCallKitCacheParams();

        if (isAdvanceInvitationMode) {
          ZegoUIKit()
              .getSignalingPlugin()
              .acceptAdvanceInvitation(
                inviterID: _invitationData.inviter?.id ?? '',
                invitationID: invitationID,
                data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
              )
              .then((result) {
            onLocalAcceptInvitation(
              result.error?.code ?? '',
              result.error?.message ?? '',
            );
          });
        } else {
          ZegoUIKit()
              .getSignalingPlugin()
              .acceptInvitation(
                inviterID: _invitationData.inviter?.id ?? '',
                targetInvitationID: invitationID,
                data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
              )
              .then((result) {
            onLocalAcceptInvitation(
              result.error?.code ?? '',
              result.error?.message ?? '',
            );
          });
        }
      } else {
        if (_appInBackground) {
          ZegoLoggerService.logInfo(
            'app in background, app in background:$_appInBackground, create notification',
            tag: 'call-invitation',
            subTag: 'page manager',
          );

          hasCallkitIncomingCauseAppInBackground = true;
          // ZegoUIKit().getSignalingPlugin().addLocalCallNotification();
          /// android 先弹prebuilt 呼叫邀请弹框
          _notificationManager?.showInvitationNotification(invitationData);
        } else {
          showNotificationOnInvitationReceived();
        }
      }
    } else {
      // ios
      // The logic here is a bit confusing. Todo requires adam to look at this part of the logic.
      if (_waitingCallInvitationReceivedAfterCallKitIncomingAccepted ||
          (callKitCallID != null && callKitCallID == _invitationData.callID)) {
        if (_waitingCallInvitationReceivedAfterCallKitIncomingRejected) {
          _waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;

          ZegoLoggerService.logInfo(
            'refuse invitation($invitationData) by callkit rejected',
            tag: 'call-invitation',
            subTag: 'page manager',
          );

          if (isAdvanceInvitationMode) {
            ZegoUIKit()
                .getSignalingPlugin()
                .refuseAdvanceInvitation(
                  inviterID: invitationData.inviter?.id ?? '',
                  invitationID: invitationID,
                  data: ZegoCallInvitationRejectRequestProtocol(
                    reason: ZegoCallInvitationProtocolKey.refuseByDecline,
                  ).toJson(),
                )
                .then((result) {
              onLocalRefuseInvitation(
                  result.error?.code ?? '', result.error?.message ?? '');
            });
          } else {
            ZegoUIKit()
                .getSignalingPlugin()
                .refuseInvitation(
                  inviterID: invitationData.inviter?.id ?? '',
                  data: ZegoCallInvitationRejectRequestProtocol(
                    reason: ZegoCallInvitationProtocolKey.refuseByDecline,
                  ).toJson(),
                )
                .then((result) {
              onLocalRefuseInvitation(
                  result.error?.code ?? '', result.error?.message ?? '');
            });
          }
        } else {
          /// in iOS's callkit, will [onIncomingPushReceived] first,
          /// then [onInvitationReceived] latter
          /// so, deal auto agree login in VoIP Event
          ZegoLoggerService.logInfo(
            'iOS, wait user decide to answer or end in popup window',
            tag: 'call-invitation',
            subTag: 'page manager',
          );
          hasCallkitIncomingCauseAppInBackground = true;
        }
      } else {
        final iOSCallKitBackground = Platform.isIOS &&
            AppLifecycleState.inactive ==
                WidgetsBinding.instance.lifecycleState;

        if (_appInBackground || iOSCallKitBackground) {
          ZegoLoggerService.logInfo(
            'app in background, app in background:$_appInBackground, iOS callkit background:$iOSCallKitBackground, create notification',
            tag: 'call-invitation',
            subTag: 'page manager',
          );

          hasCallkitIncomingCauseAppInBackground = true;

          await getOfflineCallKitCallID().then((offlineCallID) {
            ZegoLoggerService.logInfo(
              'offlineCallID:$offlineCallID, _invitationData.callID:${_invitationData.callID}',
              tag: 'call-invitation',
              subTag: 'page manager',
            );

            if (offlineCallID != _invitationData.callID) {
              setOfflineCallKitCallID(_invitationData.callID);

              showCallkitIncoming(
                caller: inviter,
                callType: _invitationData.type,
                sendRequestProtocol: sendRequestProtocol,
                ringtonePath: callInvitationData
                        .notificationConfig.androidNotificationConfig?.sound ??
                    '',
                iOSIconName: callInvitationData.notificationConfig
                    .iOSNotificationConfig?.systemCallingIconName,
              );
            }
          });
        } else {
          showNotificationOnInvitationReceived();
        }
      }
    }
  }

  void showNotificationOnInvitationReceived() {
    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    _calleeRingtone.startRing();

    callInvitationData.invitationEvents?.onIncomingCallReceived?.call(
      _invitationData.callID,
      ZegoCallUser(
        _invitationData.inviter?.id ?? '',
        _invitationData.inviter?.name ?? '',
      ),
      _invitationData.type,
      _invitationData.invitees
          .map((user) => ZegoCallUser(user.id, user.name))
          .toList(),
      _invitationData.customData,
    );

    showInvitationTopSheet();
  }

  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;

    /// todo get invitee's name form data
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'invitee:$invitee, data:$data',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation accepted',
    );

    final inviteeIndex = _invitingInvitees
        .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$_invitingInvitees',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation accepted',
      );
      return;
    } else {
      invitee.name = _invitingInvitees[inviteeIndex].name;
    }

    callInvitationData.invitationEvents?.onOutgoingCallAccepted?.call(
      _invitationData.callID,
      ZegoCallUser(invitee.id, invitee.name),
    );

    _invitingInvitees.removeAt(inviteeIndex);

    _callerRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (!isInCalling) {
      callingMachine?.stateOnlineAudioVideo.enter();
    }
  }

  void onInvitationTimeout(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'data:$data',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation timeout',
    );

    callInvitationData.invitationEvents?.onIncomingCallTimeout?.call(
      _invitationData.callID,
      ZegoCallUser(inviter.id, inviter.name),
    );

    _invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationResponseTimeout(Map<String, dynamic> params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    for (var invitee in invitees) {
      final index = _invitingInvitees
          .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
      if (-1 != index) {
        invitee.name = _invitingInvitees[index].name;
      }
    }

    final String data = params['data']!; // extended field

    for (final timeoutInvitee in invitees) {
      _invitingInvitees
          .removeWhere((invitee) => timeoutInvitee.id == invitee.id);
    }
    ZegoLoggerService.logInfo(
      'data: $data, '
      'invitees:${invitees.map((e) => e.toString())}, '
      'inviting invitees: ${_invitingInvitees.map((e) => e.toString())}',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation response timeout',
    );

    final currentInvitationCallID = _invitationData.callID;
    final currentInvitationCallType = _invitationData.type;
    final currentInvitees =
        invitees.map((user) => ZegoCallUser(user.id, user.name)).toList();

    if (isGroupCall) {
      if (_invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'all invitees had timeout',
          tag: 'call-invitation',
          subTag: 'page manager, on invitation response timeout',
        );

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }

    callInvitationData.invitationEvents?.onOutgoingCallTimeout?.call(
      currentInvitationCallID,
      currentInvitees,
      ZegoCallInvitationType.videoCall == currentInvitationCallType,
    );
  }

  void onInvitationRefused(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    final inviteeIndex = _invitingInvitees
        .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$_invitingInvitees',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation refused',
      );
      return;
    } else {
      invitee.name = _invitingInvitees[inviteeIndex].name;
    }

    final rejectRequestData =
        ZegoCallInvitationRejectRequestProtocol.fromJson(data);
    final refusedInvitationID = rejectRequestData.targetInvitationID;
    if (refusedInvitationID.isNotEmpty &&
        _invitationData.invitationID != refusedInvitationID) {
      ZegoLoggerService.logInfo(
        'but invitation id is not current, '
        'current id:${_invitationData.invitationID}, '
        'refused id:$refusedInvitationID',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation refused',
      );
      return;
    }

    if (ZegoCallInvitationProtocolKey.refuseByBusy ==
        rejectRequestData.reason) {
      callInvitationData.invitationEvents?.onOutgoingCallRejectedCauseBusy
          ?.call(
        _invitationData.callID,
        ZegoCallUser(invitee.id, invitee.name),
        rejectRequestData.customData,
      );
    } else {
      /// "decline"
      callInvitationData.invitationEvents?.onOutgoingCallDeclined?.call(
        _invitationData.callID,
        ZegoCallUser(invitee.id, invitee.name),
        rejectRequestData.customData,
      );
    }

    _invitingInvitees.removeAt(inviteeIndex);

    ZegoLoggerService.logInfo(
      'data: $data, '
      'invitee:$invitee, '
      'inviting invitees: ${_invitingInvitees.map((e) => e.toString())}',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation refused',
    );

    if (isGroupCall) {
      if (_invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'all refuse',
          tag: 'call-invitation',
          subTag: 'page manager, on invitation refused',
        );

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }
  }

  void onInvitationCanceled(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'params:$params, '
      'inviter:$inviter, '
      'data:$data',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation canceled',
    );

    var cancelRequestData =
        ZegoCallInvitationCancelRequestProtocol.fromJson(data);

    callInvitationData.invitationEvents?.onIncomingCallCanceled?.call(
      _invitationData.callID,
      ZegoCallUser(inviter.id, inviter.name),
      cancelRequestData.customData,
    );

    restoreToIdle();
  }

  void onInvitationEnded(Map<String, dynamic> params) {
    ZegoLoggerService.logInfo(
      'params:$params, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation ended',
    );
    // final ZegoUIKitUser inviter = params['inviter'] ?? ZegoUIKitUser.empty();
    final String invitationID = params['invitation_id'] ?? '';
    if (_invitationData.invitationID == invitationID) {
      restoreToIdle();
    }
  }

  void onPrebuiltCallPageDispose() {
    ZegoLoggerService.logInfo(
      'prebuilt call page dispose, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _invitingInvitees.clear();

    restoreToIdle(needPop: false);
  }

  void restoreToIdle({
    bool needPop = true,
    bool needClearCallKit = true,
  }) {
    ZegoLoggerService.logInfo(
      'needPop:$needPop, '
      'needClearCallKit:$needClearCallKit',
      tag: 'call-invitation',
      subTag: 'page manager, restore to idle',
    );

    _callerRingtone.stopRing();
    _calleeRingtone.stopRing();

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoCallMiniOverlayMachine().state()) {
      ZegoUIKit.instance.turnCameraOn(false);
    }

    _notificationManager?.cancelAll();
    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine?.machine.current?.identifier ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'restore to idle, current state:${callingMachine?.machine.current?.identifier}',
        tag: 'call-invitation',
        subTag: 'page manager, restore to idle',
      );

      if (needPop) {
        assert(callInvitationData.contextQuery != null);
        try {
          Navigator.of(callInvitationData.contextQuery!.call()).pop();
        } catch (e) {
          ZegoLoggerService.logError(
            'Navigator pop exception:$e, '
            'contextQuery:${callInvitationData.contextQuery}, ',
            tag: 'call-invitation',
            subTag: 'page manager, restore to idle',
          );
        }
      }

      callingMachine?.stateIdle.enter();
    }

    if (null != iOSIncomingPushUUID) {
      ZegoUIKit().getSignalingPlugin().reportCallEnded(
            CXCallEndedReason.CXCallEndedReasonRemoteEnded,
            iOSIncomingPushUUID!,
          );
      iOSIncomingPushUUID = null;
    }

    if (needClearCallKit) {
      clearOfflineCallKitCallID();
      clearOfflineCallKitCacheParams();
      clearAllCallKitCalls();
    }

    _invitationData = ZegoCallInvitationData.empty();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoCallInvitationType.voiceCall == _invitationData.type) {
      callingMachine?.stateCallingWithVoice.enter();
    } else {
      callingMachine?.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    if (!callInvitationData.uiConfig.invitee.popUp.visible) {
      ZegoLoggerService.logInfo(
        'config is not display popup',
        tag: 'call-invitation',
        subTag: 'page manager, showInvitationTopSheet',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'contextQuery:${callInvitationData.contextQuery}, ',
      tag: 'call-invitation',
      subTag: 'page manager, showInvitationTopSheet',
    );

    if (_invitationTopSheetVisibility) {
      return;
    }

    _invitationTopSheetVisibility = true;

    showTopModalSheet(
      callInvitationData.contextQuery?.call(),
      GestureDetector(
        onTap: onInvitationTopSheetEmptyClicked,
        child: ZegoCallInvitationNotifyDialog(
          pageManager: this,
          callInvitationConfig: callInvitationData,
          invitationData: _invitationData,
          config: callInvitationData.uiConfig.invitee.popUp,
          avatarBuilder:
              callInvitationData.requireConfig(_invitationData).avatarBuilder,
          declineButtonConfig:
              callInvitationData.uiConfig.invitee.declineButton,
          acceptButtonConfig: callInvitationData.uiConfig.invitee.acceptButton,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    ZegoLoggerService.logInfo(
      'hideInvitationTopSheet',
      tag: 'call-invitation',
      subTag: 'page manager, hideInvitationTopSheet',
    );

    if (_invitationTopSheetVisibility) {
      assert(callInvitationData.contextQuery != null);
      try {
        Navigator.of(callInvitationData.contextQuery!.call()).pop();
      } catch (e) {
        ZegoLoggerService.logError(
          'Navigator pop exception:$e, '
          'contextQuery:${callInvitationData.contextQuery}, ',
          tag: 'call-invitation',
          subTag: 'page manager, hideInvitationTopSheet',
        );
      }

      _invitationTopSheetVisibility = false;
    }
  }

  void didChangeAppLifecycleState(bool isAppInBackground) {
    if (!_init) {
      return;
    }

    ZegoLoggerService.logInfo(
      'is app in background: previous:$_appInBackground, current: $isAppInBackground, '
      'call machine page state:${callingMachine?.getPageState() ?? CallingState.kIdle}, '
      'invitation data:$_invitationData, '
      'in calling by ios background lock:$inCallingByIOSBackgroundLock, '
      'current room info:${ZegoUIKit().getRoom()}',
      tag: 'call-invitation',
      subTag: 'page manager, didChangeAppLifecycleState',
    );

    final hasReceivedInvitation = _invitationData.callID.isNotEmpty &&
        _invitationData.inviter?.id != ZegoUIKit().getLocalUser().id;
    if (CallingState.kIdle ==
            (callingMachine?.getPageState() ?? CallingState.kIdle) &&
        _appInBackground &&
        !isAppInBackground &&
        hasReceivedInvitation) {
      ZegoLoggerService.logInfo(
        'had invitation in background before',
        tag: 'call-invitation',
        subTag: 'page manager, didChangeAppLifecycleState',
      );
      if (hasCallkitIncomingCauseAppInBackground) {
        hasCallkitIncomingCauseAppInBackground = false;

        ZegoLoggerService.logInfo(
          'not show notification, will be auto agree until callkit accept event received',
          tag: 'call-invitation',
          subTag: 'page manager, didChangeAppLifecycleState',
        );

        if (Platform.isAndroid) {
          // && ! is screen lock
          _notificationManager?.cancelAll();

          if (ZegoCallInvitationNotificationManager.hasInvitation) {
            ZegoCallInvitationNotificationManager.hasInvitation = false;

            clearAllCallKitCalls();

            /// click on empty space of notification, not accept or decline
            showNotificationOnInvitationReceived();
          }
        } else {
          if (ZegoCallKitBackgroundService().isIOSCallKitDisplaying) {
            /// not accept or reject, then switch to app, close callkit popup
            /// and show top sheet

            ZegoLoggerService.logInfo(
              'close callkit now, then show top invitation popup',
              tag: 'call-invitation',
              subTag: 'page manager, didChangeAppLifecycleState',
            );

            clearAllCallKitCalls();

            /// click on empty space of notification, not accept or decline
            showNotificationOnInvitationReceived();
          }
        }
      } else {
        if (ZegoUIKit().getRoom().id.isEmpty) {
          ZegoLoggerService.logInfo(
            'show notification now',
            tag: 'call-invitation',
            subTag: 'page manager, didChangeAppLifecycleState',
          );
          showNotificationOnInvitationReceived();
        } else {
          /// if accept by callkit when ios is screen-locked,
          /// room will be enter in callkit
          ZegoLoggerService.logInfo(
            'already in room, now show notification',
            tag: 'call-invitation',
            subTag: 'page manager, didChangeAppLifecycleState',
          );
        }
      }
    }

    _appInBackground = isAppInBackground;

    if (!_appInBackground && inCallingByIOSBackgroundLock) {
      /// Previously, due to answering a CallKit call on iOS lock screen,
      /// the automatic enter-room logic was triggered, but the interface was not displayed properly.
      /// At this point, since the device is no longer on lock screen,
      /// it is necessary to manually re-render the audio-video page.
      inCallingByIOSBackgroundLock = false;
      userListStreamSubscriptionInCallingByIOSBackgroundLock?.cancel();

      callingMachine?.stateOnlineAudioVideo.enter();
    }
  }

  void onMiniOverlayMachineStateChanged(ZegoCallMiniOverlayPageState state) {
    if (ZegoCallMiniOverlayPageState.calling == state) {
      callingMachine?.stateOnlineAudioVideo.enter();
    }
  }

  ValueNotifier<bool> get waitCallPageDisposeInIOSCallKit =>
      _waitCallPageDisposeFlagInIOSCallKit;

  void cacheInvitationDataForWaitCallPageDisposeInIOSCallKit(bool isCache) {
    _invitationDataOfWaitCallPageDisposeInIOSCallKit =
        isCache ? invitationData : null;

    ZegoLoggerService.logInfo(
      'isCache:$isCache,'
      'data:$_invitationDataOfWaitCallPageDisposeInIOSCallKit',
      tag: 'call-invitation',
      subTag:
          'page manager, cacheInvitationDataForWaitCallPageDisposeInIOSCallKit',
    );
  }

  /// If the call is ended by the end button of iOS CallKit,
  /// the widget navigation of the CallPage will not be properly
  /// execute dispose function.
  ///
  /// As a result, during the next offline call,
  /// the dispose of the previous CallPage will cause confusion in the widget
  /// navigation.
  void setWaitCallPageDisposeFlag(bool needWait) {
    _waitCallPageDisposeFlagInIOSCallKit.value = needWait;

    ZegoLoggerService.logInfo(
      'needWait:$needWait',
      tag: 'call-invitation',
      subTag: 'page manager, setPendingCallPageDisposeFlag',
    );
  }
}
