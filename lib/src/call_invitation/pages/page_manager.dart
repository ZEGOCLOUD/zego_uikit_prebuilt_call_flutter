// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_callkit/zego_callkit.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/handler.ios.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/notification_ring.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/invitation_notify.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// @nodoc
class ZegoInvitationPageManager {
  ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  ZegoNotificationManager? _notificationManager;

  ZegoInvitationPageManager({
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

  bool get appInBackground => _appInBackground;

  ZegoCallInvitationData get invitationData => _invitationData;

  bool get isGroupCall => _invitationData.invitees.length > 1;

  String get currentCallID => _invitationData.callID;

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
    required ZegoRingtoneConfig ringtoneConfig,
    required ZegoNotificationManager notificationManager,
  }) async {
    if (_init) {
      ZegoLoggerService.logInfo(
        'is init before',
        tag: 'call',
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

    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine()
        .listenStateChanged(onMiniOverlayMachineStateChanged);

    ZegoLoggerService.logInfo(
      'init, appID:${callInvitationData.appID}, '
      // 'appSign:${callInvitationConfig.appSign},'
      'userID:${callInvitationData.userID}, '
      'userName: ${callInvitationData.userName}',
      tag: 'call',
      subTag: 'page manager',
    );
  }

  void uninit() {
    if (!_init) {
      ZegoLoggerService.logInfo(
        'no init, not need to uninit',
        tag: 'call',
        subTag: 'page manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'call',
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

    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);

    removeStreamListener();
  }

  void initRing(ZegoRingtoneConfig ringtoneConfig) {
    if (ringtoneConfig.outgoingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset caller ring, source path:${ringtoneConfig.outgoingCallPath}',
        tag: 'call',
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
        tag: 'call',
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
      'listen stream',
      tag: 'call',
      subTag: 'page manager',
    );

    // check plugin installed
    removeStreamListener();

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

  void removeStreamListener() {
    ZegoLoggerService.logInfo(
      'remove stream',
      tag: 'call',
      subTag: 'page manager',
    );

    for (final streamSubscription in _streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  void onLocalSendInvitation({
    required String callID,
    required List<ZegoUIKitUser> invitees,
    required ZegoCallType invitationType,
    required String customData,
    required String code,
    required String message,
    required String invitationID,
    required List<String> errorInvitees,
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
      'invitation id:$invitationID',
      tag: 'call',
      subTag: 'page manager',
    );

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'send invitation error!!! '
        'code:$code, message:$message',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

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
        if (ZegoCallType.voiceCall == _invitationData.type) {
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
      tag: 'call',
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
        tag: 'call',
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
              .joinRoom(invitationData.callID)
              .then((result) async {
            userListStreamSubscriptionInCallingByIOSBackgroundLock?.cancel();
            userListStreamSubscriptionInCallingByIOSBackgroundLock = ZegoUIKit()
                .getUserLeaveStream()
                .listen(onUserLeaveInIOSBackgroundLockCalling);

            if (result.errorCode != 0) {
              ZegoLoggerService.logError(
                'accept call by callkit in background-locked, failed to login room:${result.errorCode},${result.extendedData}',
                tag: 'call',
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
      tag: 'call',
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
      tag: 'call',
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
      tag: 'call',
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
        tag: 'call',
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
      tag: 'call',
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
      tag: 'call',
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
      tag: 'call',
      subTag: 'page manager',
    );

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

    ZegoLoggerService.logInfo(
      'on invitation received, state:${WidgetsBinding.instance.lifecycleState}, '
      '_init:$_init, inviter:$inviter, type:$type, in background: $_appInBackground, '
      'data:$data, params:$params',
      tag: 'call',
      subTag: 'page manager',
    );

    if (_invitationData.callID.isNotEmpty ||
        CallingState.kIdle !=
            (callingMachine?.getPageState() ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'auto refuse this call, because is busy, '
        'is inviting: ${_invitationData.callID.isNotEmpty}, '
        'current state: ${callingMachine?.getPageState() ?? CallingState.kIdle}',
        tag: 'call',
        subTag: 'page manager',
      );
      ZegoUIKit()
          .getSignalingPlugin()
          .refuseInvitation(
            inviterID: inviter.id,
            data: InvitationRejectRequestData(
              reason: CallInvitationProtocolKey.refuseByBusy,
              targetInvitationID: invitationID,
            ).toJson(),
          )
          .then((result) {
        ZegoLoggerService.logInfo(
          'auto refuse result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });

      return;
    }

    final invitationSendRequestData = InvitationSendRequestData.fromJson(data);
    _invitationData
      ..customData = invitationSendRequestData.customData
      ..callID = invitationSendRequestData.callID
      ..invitationID = invitationID
      ..invitees = List.from(invitationSendRequestData.invitees)
      ..inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name)
      ..type = ZegoCallTypeExtension.mapValue[type] ?? ZegoCallType.voiceCall;

    if (_waitCallPageDisposeFlagInIOSCallKit.value) {
      cacheInvitationDataForWaitCallPageDisposeInIOSCallKit(true);
    }

    final callKitCallID = await getOfflineCallKitCallID();
    ZegoLoggerService.logInfo(
      '_waitingCallInvitationReceivedAfterCallKitIncomingAccepted:$_waitingCallInvitationReceivedAfterCallKitIncomingAccepted, '
      'callkit call id:$callKitCallID',
      tag: 'call',
      subTag: 'page manager',
    );
    if (_waitingCallInvitationReceivedAfterCallKitIncomingAccepted ||
        (callKitCallID != null && callKitCallID == _invitationData.callID)) {
      if (Platform.isAndroid ||
          _waitingCallInvitationReceivedAfterCallKitIncomingAccepted) {
        ZegoLoggerService.logInfo(
          'auto agree, cause exist callkit params same as current call or '
          ' waiting invitation received after callkit accept',
          tag: 'call',
          subTag: 'page manager',
        );

        /// todo wait zim sdk fix bug
        if (Platform.isAndroid) {
          clearAllCallKitCalls();
        }

        _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;
        clearOfflineCallKitCallID();
        clearOfflineCallKitParams();

        ZegoUIKit()
            .getSignalingPlugin()
            .acceptInvitation(
              inviterID: _invitationData.inviter?.id ?? '',
              data: '',
              targetInvitationID: invitationID,
            )
            .then((result) {
          onLocalAcceptInvitation(
            result.error?.code ?? '',
            result.error?.message ?? '',
          );
        });
      } else {
        /// only iOS
        if (_waitingCallInvitationReceivedAfterCallKitIncomingRejected) {
          _waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;

          ZegoLoggerService.logInfo(
            'refuse invitation($invitationData) by callkit rejected',
            tag: 'call',
            subTag: 'page manager',
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .refuseInvitation(
                inviterID: invitationData.inviter?.id ?? '',
                data: InvitationRejectRequestData(
                  reason: CallInvitationProtocolKey.refuseByDecline,
                ).toJson(),
              )
              .then((result) {
            onLocalRefuseInvitation(
                result.error?.code ?? '', result.error?.message ?? '');
          });
        } else {
          /// in iOS's callkit, will [onIncomingPushReceived] first,
          /// then [onInvitationReceived] latter
          /// so, deal auto agree login in VoIP Event
          ZegoLoggerService.logInfo(
            'iOS, wait user decide to answer or end in popup window',
            tag: 'call',
            subTag: 'page manager',
          );
          hasCallkitIncomingCauseAppInBackground = true;
        }
      }
    } else {
      final iOSCallKitBackground = Platform.isIOS &&
          AppLifecycleState.inactive == WidgetsBinding.instance.lifecycleState;

      if (_appInBackground || iOSCallKitBackground) {
        ZegoLoggerService.logInfo(
          'app in background, app in background:$_appInBackground, iOS callkit background:$iOSCallKitBackground, create notification',
          tag: 'call',
          subTag: 'page manager',
        );

        hasCallkitIncomingCauseAppInBackground = true;
        if (Platform.isAndroid) {
          // ZegoUIKit().getSignalingPlugin().addLocalCallNotification();
          /// android 先弹prebuilt 呼叫邀请弹框
          _notificationManager?.showInvitationNotification(invitationData);
        } else {
          await getOfflineCallKitCallID().then((offlineCallID) {
            ZegoLoggerService.logInfo(
              'offlineCallID:$offlineCallID, _invitationData.callID:${_invitationData.callID}',
              tag: 'call',
              subTag: 'page manager',
            );

            if (offlineCallID != _invitationData.callID) {
              setOfflineCallKitCallID(_invitationData.callID);

              showCallkitIncoming(
                caller: inviter,
                callType: _invitationData.type,
                invitationSendRequestData: invitationSendRequestData,
                ringtonePath: callInvitationData
                        .notificationConfig.androidNotificationConfig?.sound ??
                    '',
                iOSIconName: callInvitationData.notificationConfig
                    .iOSNotificationConfig?.systemCallingIconName,
              );
            }
          });
        }
      } else {
        showNotificationOnInvitationReceived();
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
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation accepted, invitee:$invitee, data:$data',
      tag: 'call',
      subTag: 'page manager',
    );

    final inviteeIndex = _invitingInvitees
        .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitation accepted, but invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$_invitingInvitees',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    callInvitationData.invitationEvents?.onOutgoingCallAccepted?.call(
      _invitationData.callID,
      ZegoCallUser(invitee.id, invitee.name),
    );

    _invitingInvitees.removeAt(inviteeIndex);

    _callerRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine?.stateOnlineAudioVideo.enter();
  }

  void onInvitationTimeout(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation timeout, inviter:$inviter, data:$data',
      tag: 'call',
      subTag: 'page manager',
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
    final String data = params['data']!; // extended field

    for (final timeoutInvitee in invitees) {
      _invitingInvitees
          .removeWhere((invitee) => timeoutInvitee.id == invitee.id);
    }
    ZegoLoggerService.logInfo(
      'on invitation response timeout, data: $data, '
      'invitees:${invitees.map((e) => e.toString())}, '
      'inviting invitees: ${_invitingInvitees.map((e) => e.toString())}',
      tag: 'call',
      subTag: 'page manager',
    );

    final currentInvitationCallID = _invitationData.callID;
    final currentInvitationCallType = _invitationData.type;
    final currentInvitees =
        invitees.map((user) => ZegoCallUser(user.id, user.name)).toList();

    if (isGroupCall) {
      if (_invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'invitation timeout, all invitee timeout',
          tag: 'call',
          subTag: 'page manager',
        );

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }

    callInvitationData.invitationEvents?.onOutgoingCallTimeout?.call(
      currentInvitationCallID,
      currentInvitees,
      ZegoCallType.videoCall == currentInvitationCallType,
    );
  }

  void onInvitationRefused(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    final inviteeIndex = _invitingInvitees
        .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitation refused, but invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$_invitingInvitees',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    final rejectRequestData = InvitationRejectRequestData.fromJson(data);
    final refusedInvitationID = rejectRequestData.targetInvitationID;
    if (refusedInvitationID.isNotEmpty &&
        _invitationData.invitationID != refusedInvitationID) {
      ZegoLoggerService.logInfo(
        'invitation refused, but invitation id is not current, '
        'current id:${_invitationData.invitationID}, '
        'refused id:$refusedInvitationID',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    if (CallInvitationProtocolKey.refuseByBusy == rejectRequestData.reason) {
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
      'on invitation refused, data: $data, '
      'invitee:$invitee, '
      'inviting invitees: ${_invitingInvitees.map((e) => e.toString())}',
      tag: 'call',
      subTag: 'page manager',
    );

    if (isGroupCall) {
      if (_invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'invitation refuse, all refuse',
          tag: 'call',
          subTag: 'page manager',
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
      'on invitation canceled, inviter:$inviter, data:$data',
      tag: 'call',
      subTag: 'page manager',
    );

    var cancelRequestData = InvitationCancelRequestData.fromJson(data);

    callInvitationData.invitationEvents?.onIncomingCallCanceled?.call(
      _invitationData.callID,
      ZegoCallUser(inviter.id, inviter.name),
      cancelRequestData.customData,
    );

    restoreToIdle();
  }

  void onHangUp({
    bool needPop = true,
  }) {
    ZegoLoggerService.logInfo(
      'on hang up, needPop:$needPop',
      tag: 'call',
      subTag: 'page manager',
    );

    if (isNobodyAccepted) {
      ZegoUIKit()
          .getSignalingPlugin()
          .cancelInvitation(
            invitees: _invitingInvitees.map((user) => user.id).toList(),
            data: const JsonEncoder().convert({
              CallInvitationProtocolKey.callID: _invitationData.callID,
              CallInvitationProtocolKey.operationType:
                  BackgroundMessageType.cancelInvitation.text,
            }),
          )
          .then((result) {
        ZegoLoggerService.logInfo(
          'hang up cancel result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });
    }

    restoreToIdle(needPop: needPop);
  }

  void onPrebuiltCallPageDispose() {
    ZegoLoggerService.logInfo(
      'prebuilt call page dispose',
      tag: 'call',
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
      'invitation page service to be idle, '
      'needPop:$needPop, '
      'needClearCallKit:$needClearCallKit',
      tag: 'call',
      subTag: 'page manager',
    );

    _callerRingtone.stopRing();
    _calleeRingtone.stopRing();

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state()) {
      ZegoUIKit.instance.turnCameraOn(false);
    }

    _notificationManager?.cancelAll();
    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine?.machine.current?.identifier ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'restore to idle, current state:${callingMachine?.machine.current?.identifier}',
        tag: 'call',
        subTag: 'page manager',
      );

      if (needPop) {
        assert(callInvitationData.contextQuery != null);
        try {
          Navigator.of(callInvitationData.contextQuery!.call()).pop();
        } catch (e) {
          ZegoLoggerService.logError(
            'Navigator pop exception:$e, '
            'contextQuery:${callInvitationData.contextQuery}, ',
            tag: 'call',
            subTag: 'page manager',
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
      clearOfflineCallKitParams();
      clearAllCallKitCalls();
    }

    _invitationData = ZegoCallInvitationData.empty();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoCallType.voiceCall == _invitationData.type) {
      callingMachine?.stateCallingWithVoice.enter();
    } else {
      callingMachine?.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    ZegoLoggerService.logInfo(
      'showInvitationTopSheet, '
      'contextQuery:${callInvitationData.contextQuery}, ',
      tag: 'call',
      subTag: 'page manager',
    );

    if (_invitationTopSheetVisibility) {
      return;
    }

    _invitationTopSheetVisibility = true;

    showTopModalSheet(
      callInvitationData.contextQuery?.call(),
      GestureDetector(
        onTap: onInvitationTopSheetEmptyClicked,
        child: ZegoCallInvitationDialog(
          pageManager: this,
          callInvitationConfig: callInvitationData,
          invitationData: _invitationData,
          avatarBuilder:
              callInvitationData.requireConfig(_invitationData).avatarBuilder,
          showDeclineButton: callInvitationData.uiConfig.showDeclineButton,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    ZegoLoggerService.logInfo(
      'hideInvitationTopSheet',
      tag: 'call',
      subTag: 'page manager',
    );

    if (_invitationTopSheetVisibility) {
      assert(callInvitationData.contextQuery != null);
      try {
        Navigator.of(callInvitationData.contextQuery!.call()).pop();
      } catch (e) {
        ZegoLoggerService.logError(
          'Navigator pop exception:$e, '
          'contextQuery:${callInvitationData.contextQuery}, ',
          tag: 'call',
          subTag: 'page manager',
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
      'didChangeAppLifecycleState, '
      'is app in background: previous:$_appInBackground, current: $isAppInBackground, '
      'call machine page state:${callingMachine?.getPageState() ?? CallingState.kIdle}, '
      'invitation data:$_invitationData, '
      'in calling by ios background lock:$inCallingByIOSBackgroundLock, '
      'current room info:${ZegoUIKit().getRoom()}',
      tag: 'call',
      subTag: 'page manager',
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
        tag: 'call',
        subTag: 'page manager',
      );
      if (hasCallkitIncomingCauseAppInBackground) {
        hasCallkitIncomingCauseAppInBackground = false;

        ZegoLoggerService.logInfo(
          'not show notification, will be auto agree until callkit accept event received',
          tag: 'call',
          subTag: 'page manager',
        );

        if (Platform.isAndroid) {
          // && ! is screen lock
          _notificationManager?.cancelAll();

          if (ZegoNotificationManager.hasInvitation) {
            ZegoNotificationManager.hasInvitation = false;

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
              tag: 'call',
              subTag: 'page manager',
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
            tag: 'call',
            subTag: 'page manager',
          );
          showNotificationOnInvitationReceived();
        } else {
          /// if accept by callkit when ios is screen-locked,
          /// room will be enter in callkit
          ZegoLoggerService.logInfo(
            'already in room, now show notification',
            tag: 'call',
            subTag: 'page manager',
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
      'cacheInvitationDataForWaitCallPageDisposeInIOSCallKit $isCache,'
      'data:$_invitationDataOfWaitCallPageDisposeInIOSCallKit',
      tag: 'call',
      subTag: 'page manager',
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
      'setPendingCallPageDisposeFlag:$needWait',
      tag: 'call',
      subTag: 'page manager',
    );
  }
}
