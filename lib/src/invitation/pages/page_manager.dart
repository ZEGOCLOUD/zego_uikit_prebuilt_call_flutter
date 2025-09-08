// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/cache/cache.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/entry_point.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/callkit_incoming.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_ring.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/invitation_notify.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../notification/defines.dart';
import 'calling/config.dart';

/// @nodoc
class ZegoCallInvitationPageManager {
  ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  ZegoCallInvitationNotificationManager? _notificationManager;

  ZegoCallInvitationPageManager({
    required this.callInvitationData,
  });

  final _defaultPackageName = 'packages/zego_uikit_prebuilt_call/';

  final _callerRingtone = ZegoRingtone();
  final _calleeRingtone = ZegoRingtone();

  bool _init = false;
  var callingConfig = ZegoUIKitPrebuiltCallingConfig();
  ZegoCallingMachine? callingMachine;
  bool _invitationTopSheetVisibility = false;
  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  bool _appInBackground = false;
  bool inCallPage = false;

  ///  App (main) hasn't started yet when android offline handler received.
  ///  At this time, if you accept it, it will initialize express engine and
  ///  enter the room in advance.
  ///  here record this status, and there is no need to re-initialize express
  ///  and enter the room in prebuilt.
  ///  when entering the call page and exiting, the state will be reset in
  ///  restoreToIdle
  bool isCurrentInvitationFromAcceptedAndroidOffline = false;

  ///  Due to some time-consuming and waiting operations such as data loading
  /// and user login in the App, it cannot be directly navigate to call page in
  /// the service.
  ///  When service init, the behavior which jump to the call page will be
  ///  overwritten by the app's jump behavior). Here, manually jump to the
  ///  call page by the API through the App
  bool isWaitingEnterAcceptedOfflineCall = false;

  ///
  bool isHidingInvitationTopSheetDuringSheetEmptyClicked = false;

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

  ///iOS bug, accept calls under lock screen, sometimes receive CallKit's performAnswerCallAction first, then receive ZIM's onCallInvitationReceived
  ///At this time, you need to agree directly onCallInvitationReceived
  /// todo wait zim sdk fix bug
  bool _hasCallkitIncomingCauseAppInBackground = false;

  /// First click the Agree button in the offline pop-up, and then receive the invitation event later
  bool _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;

  /// First click the Reject button in the offline pop-up, and then receive the invitation event later
  bool _waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;

  Timer? _remoteReceivedTimeoutGuard;
  Timer? _localSendTimeoutGuard;

  ZegoCallInvitationData _invitationData = ZegoCallInvitationData.empty();
  List<ZegoUIKitUser> _invitingInvitees = []; //  only change by inviter
  ZegoCallInvitationLocalParameter _localInvitationParameter =
      ZegoCallInvitationLocalParameter.empty();

  bool get appInBackground => _appInBackground;

  ZegoCallInvitationData get invitationData => _invitationData;

  bool get isAdvanceInvitationMode =>
      ZegoUIKitPrebuiltCallInvitationService().private.isAdvanceInvitationMode;

  bool get isGroupCall => _invitationData.invitees.length > 1;

  String get currentCallID => _invitationData.callID;

  List<ZegoUIKitUser> get invitingInvitees => _invitingInvitees;

  ZegoCallInvitationLocalParameter get localInvitationParameter =>
      _localInvitationParameter;

  /// still ring mean nobody accept this invitation
  bool get isNobodyAccepted => _callerRingtone.isRingTimerRunning;

  set invitationTopSheetVisibility(value) {
    ZegoLoggerService.logInfo(
      'set invitationTopSheetVisibility:$value',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _invitationTopSheetVisibility = value;
  }

  bool get hasCallkitIncomingCauseAppInBackground =>
      _hasCallkitIncomingCauseAppInBackground;

  set hasCallkitIncomingCauseAppInBackground(value) {
    ZegoLoggerService.logInfo(
      'set hasCallkitIncomingCauseAppInBackground:$value',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _hasCallkitIncomingCauseAppInBackground = value;
  }

  bool get waitingCallInvitationReceivedAfterCallKitIncomingAccepted =>
      _waitingCallInvitationReceivedAfterCallKitIncomingAccepted;

  set waitingCallInvitationReceivedAfterCallKitIncomingAccepted(value) {
    ZegoLoggerService.logInfo(
      'set waitingCallInvitationReceivedAfterCallKitIncomingAccepted:$value',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _waitingCallInvitationReceivedAfterCallKitIncomingAccepted = value;
  }

  bool get waitingCallInvitationReceivedAfterCallKitIncomingRejected =>
      _waitingCallInvitationReceivedAfterCallKitIncomingRejected;

  set waitingCallInvitationReceivedAfterCallKitIncomingRejected(value) {
    ZegoLoggerService.logInfo(
      'set waitingCallInvitationReceivedAfterCallKitIncomingRejected:$value',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    _waitingCallInvitationReceivedAfterCallKitIncomingRejected = value;
  }

  bool get isInCalling {
    final pageState = callingMachine?.getPageState() ?? CallingState.kIdle;

    ZegoLoggerService.logInfo(
      'check is in calling, '
      'state:$pageState, '
      'inCallingByIOSBackgroundLock:$inCallingByIOSBackgroundLock, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    return (CallingState.kCallingWithVoice == pageState ||
            CallingState.kCallingWithVideo == pageState) ||
        inCallingByIOSBackgroundLock;
  }

  bool get isInCall {
    final pageState = callingMachine?.getPageState() ?? CallingState.kIdle;

    ZegoLoggerService.logInfo(
      'check is in call, '
      'state:$pageState, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    return CallingState.kOnlineAudioVideo == pageState;
  }

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
    hasCallkitIncomingCauseAppInBackground = false;
    waitingCallInvitationReceivedAfterCallKitIncomingAccepted = false;
    waitingCallInvitationReceivedAfterCallKitIncomingRejected = false;
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
        prefix: _defaultPackageName,
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
        prefix: _defaultPackageName,
        sourcePath: 'assets/invitation/audio/incoming.mp3',
        isVibrate: true,
      );
    }
  }

  bool invitationStreamCallTypeFilter(Map<String, dynamic> params) =>
      ZegoCallTypeExtension.isCallType((params['type'] as int?) ?? -1);

  void listenStream() {
    ZegoLoggerService.logInfo(
      'listen stream, '
      'isAdvanceInvitationMode:$isAdvanceInvitationMode, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    removeStreamListener();

    /// advance invitation events
    _streamSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationUserStateChangedStream()
          .where((event) => ZegoCallTypeExtension.isCallType(event.type))
          .listen(onInvitationUserStateChanged))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationReceivedStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationReceived))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationTimeoutStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationCanceledStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationCanceled))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationEndedStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationEnded));

    /// normal invitation events
    _streamSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationUserStateChangedStream()
          .listen(onInvitationUserStateChanged))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationReceivedStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationReceived))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationTimeoutStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationResponseTimeoutStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationResponseTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationAcceptedStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationAccepted))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationRefusedStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationRefused))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationCanceledStream()
          .where(invitationStreamCallTypeFilter)
          .listen(onInvitationCanceled));
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

  Future<void> onLocalSendInvitation({
    required String callID,
    required List<ZegoUIKitUser> invitees,
    required ZegoCallInvitationType invitationType,
    required String customData,
    required String code,
    required String message,
    required String invitationID,
    required List<String> errorInvitees,
    required ZegoCallInvitationLocalParameter localConfig,
  }) async {
    ZegoLoggerService.logInfo(
      'local send invitation, '
      'call id:$callID, '
      'invitees:${invitees.ids}, '
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
        'local send invitation, '
        'send invitation error!!! '
        'code:$code, message:$message',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      return;
    }

    callInvitationData.invitationEvents?.onOutgoingCallSent?.call(
      callID,
      ZegoCallUser.fromUIKit(ZegoUIKit().getLocalUser()),
      invitationType,
      invitees.map((e) => ZegoCallUser.fromUIKit(e)).toList(),
      customData,
    );

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
      ..timeoutSeconds = localConfig.timeoutSeconds
      ..customData = customData;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (_invitingInvitees.isNotEmpty) {
      _callerRingtone.startRing(testPlayRingtone: true);

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
            ZegoUIKit().updateVideoViewMode(
              callInvitationData.uiConfig.inviter.useVideoViewAspectFill,
            );
            ZegoUIKit().turnCameraOn(true);
          }

          callingMachine?.stateCallingWithVideo.enter();
        }
      }

      _localSendTimeoutGuard?.cancel();
      _localSendTimeoutGuard = Timer.periodic(
        Duration(seconds: localConfig.timeoutSeconds),
        (_) {
          if (ZegoUIKit().getNetworkState() == ZegoUIKitNetworkState.offline &&
              !_invitationData.isEmpty) {
            ZegoLoggerService.logInfo(
              'local send invitation, '
              'invitation timeout on offline network, '
              '_invitationData:$_invitationData',
              tag: 'call-invitation',
              subTag: 'page manager',
            );

            onInvitationResponseTimeout(
              {
                'invitees': invitees,
                'data': customData,
              },
            );
          }
        },
      );
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation(
    String invitationID,
    String code,
    String message,
  ) {
    ZegoLoggerService.logInfo(
      'local accept invitation, code:$code, message:$message, '
      'app in background:$_appInBackground',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionAccept,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

    callInvitationData.invitationEvents?.onIncomingCallAcceptButtonPressed
        ?.call();

    _calleeRingtone.stopRing();

    ///  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'local accept invitation is failed, ignore',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      return;
    }

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
        ZegoLoggerService.logInfo(
          'in calling by ios background lock, update to $inCallingByIOSBackgroundLock',
          tag: 'call-invitation',
          subTag: 'page manager, inCallingByIOSBackgroundLock',
        );

        /// At this point, when answering a CallKit call on iOS lock screen,
        /// the audio-video view interface not be rendered properly, causing the normal in-room logic to not run.
        /// Therefore, it is necessary to manually enter the room at this point.

        ZegoUIKit().login(
          callInvitationData.userID,
          callInvitationData.userName,
        );

        bool playingStreamInPIPUnderIOS = false;
        if (Platform.isIOS) {
          playingStreamInPIPUnderIOS =
              callInvitationData.config.pip.iOS.support;

          if (playingStreamInPIPUnderIOS) {
            final systemVersion = ZegoUIKit().getMobileSystemVersion();
            if (systemVersion.major < 15) {
              ZegoLoggerService.logInfo(
                'not support pip smaller than 15',
                tag: 'call-invitation',
                subTag: 'page manager',
              );

              playingStreamInPIPUnderIOS = false;
            }
          }
        }
        ZegoUIKit()
            .init(
          appID: callInvitationData.appID,
          appSign: callInvitationData.appSign,
          enablePlatformView: playingStreamInPIPUnderIOS,
          playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
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

  Future<void> onLocalRefuseInvitation(
    String invitationID,
    String code,
    String message, {
    bool needClearCallKit = true,
    bool needHideInvitationTopSheet = true,
  }) async {
    ZegoLoggerService.logInfo(
      'local refuse invitation, code:$code, message:$message, lifecycleState:${WidgetsBinding.instance.lifecycleState}',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionRefuse,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

    callInvitationData.invitationEvents?.onIncomingCallDeclineButtonPressed
        ?.call();

    await restoreToIdle(
      needClearCallKit: needClearCallKit,
      needHideInvitationTopSheet: needHideInvitationTopSheet,
    ).then((_) {
      ZegoLoggerService.logInfo(
        'local refuse invitation, restore idle done',
        tag: 'call-invitation',
        subTag: 'page manager',
      );
    });
  }

  void onLocalCancelInvitation(
    String invitationID,
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    ZegoLoggerService.logInfo(
      'local cancel invitation, code:$code, message:$message, error invitees, $errorInvitees',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionCancel,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

    callInvitationData.invitationEvents?.onOutgoingCallCancelButtonPressed
        ?.call();

    ZegoUIKitPrebuiltCallInvitationService().private.updateLocalInvitingUsers(
      [],
    );
    _invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationUserStateChanged(
    ZegoSignalingPluginInvitationUserStateChangedEvent event,
  ) {
    if (event.invitationID != _invitationData.invitationID) {
      ZegoLoggerService.logInfo(
        'on invitation user state changed, '
        'invitation id is not equal, {'
        'current:${_invitationData.invitationID}, '
        'event:${event.invitationID}}',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'on invitation user state changed, event:$event',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

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
          final index = _invitingInvitees
              .indexWhere((invitee) => invitee.id == userInfo.userID);
          if (-1 != index) {
            onInvitationResponseTimeout(
              {
                'invitees': [
                  ZegoUIKitUser(id: userInfo.userID, name: ''),
                ],
                'data': userInfo.extendedData,
              },
            );
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
        ZegoUIKitPrebuiltCallInvitationService()
            .private
            .removeUserFromLocalInvitingUsers([userInfo.userID]);
      }
    }

    callInvitationData.invitationEvents?.onInvitationUserStateChanged
        ?.call(event.callUserList);
  }

  void onAndroidOfflineInvitationAccepted(
    ZegoCallInvitationOfflineCallKitCacheParameterProtocol protocol,
  ) {
    ZegoLoggerService.logInfo(
      'on android offline invitation received, '
      'protocol:${protocol.dict}',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    /// call protocol
    final sendRequestProtocol =
        ZegoCallInvitationSendRequestProtocol.fromJson(protocol.payloadData);

    _invitationData
      ..customData = sendRequestProtocol.customData
      ..callID = sendRequestProtocol.callID
      ..invitationID = protocol.invitationID
      ..invitees = List.from(sendRequestProtocol.invitees)
      ..inviter = protocol.inviter
      ..timeoutSeconds = protocol.timeoutSeconds
      ..type = protocol.callType;

    isCurrentInvitationFromAcceptedAndroidOffline = true;
    isWaitingEnterAcceptedOfflineCall = true;
  }

  void enterAcceptedOfflineCall() {
    if (!isWaitingEnterAcceptedOfflineCall) {
      ZegoLoggerService.logInfo(
        'enterAcceptedOfflineCall, '
        'not waiting enter',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'enterAcceptedOfflineCall, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    ZegoUIKitPrebuiltCallInvitationService()
        .private
        .waitingEnterAcceptedOfflineCallWhenInitNotDone = false;

    isWaitingEnterAcceptedOfflineCall = false;
    callingMachine?.stateOnlineAudioVideo.enter();
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
    /// call inviter
    var inviter = ZegoUIKitUser.empty();
    if (params['inviter'] is ZegoUIKitUser) {
      inviter = params['inviter']!;
    } else if (params['inviter'] is Map<String, dynamic>) {
      inviter =
          ZegoUIKitUser.fromJson(params['inviter'] as Map<String, dynamic>);
    }

    /// call type
    final int type = params['type']!;

    /// call extended field
    final String data = params['data']!;

    /// zim call id
    final invitationID = params['invitation_id'] as String? ?? '';
    final timeoutSecond = params['timeout_second'] as int? ?? 60;

    ZegoLoggerService.logInfo(
      'on invitation received, '
      'is init:$_init, '
      'network state:${ZegoUIKit().getNetworkState()}, '
      'in background: $_appInBackground, '
      'state:${WidgetsBinding.instance.lifecycleState}, '
      'page state:${callingMachine?.getPageState()}, '
      'current invitation call id:${_invitationData.callID}, '
      'local inviting users: ${ZegoUIKitPrebuiltCallInvitationService().private.localInvitingUsersNotifier.value}, '
      'params:$params',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventReceivedInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: invitationID,
        ZegoUIKitSignalingReporter.eventKeyInviter: inviter.id,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
        ZegoCallReporter.eventKeyExtendedData: data,
      },
    );

    final currentInvitationIDSameAsRecived =
        invitationID == _invitationData.invitationID;
    final hasInvitationAlready = ZegoUIKitPrebuiltCallInvitationService()
            .private
            .localInvitingUsersNotifier
            .value
            .isNotEmpty ||
        _invitationData.callID.isNotEmpty ||
        CallingState.kIdle !=
            (callingMachine?.getPageState() ?? CallingState.kIdle);
    if (hasInvitationAlready && !currentInvitationIDSameAsRecived) {
      ZegoLoggerService.logInfo(
        'auto refuse data: '
        'localInvitingUsers:${ZegoUIKitPrebuiltCallInvitationService().private.localInvitingUsersNotifier.value}, '
        'invitationData.callID:${_invitationData.callID}, '
        'invitationData.invitationID:${_invitationData.invitationID}, '
        'page state:${callingMachine?.getPageState()}',
        tag: 'call-invitation',
        subTag: 'page manager',
      );

      refuseInCallingOnInvitationReceived(
        inviter: inviter,
        invitationID: invitationID,
      );

      return;
    }

    /// call protocol
    final sendRequestProtocol =
        ZegoCallInvitationSendRequestProtocol.fromJson(data);
    final callInvitationType = ZegoCallTypeExtension.mapValue[type] ??
        ZegoCallInvitationType.voiceCall;

    updateInvitationData(
      sendRequestProtocol,
      invitationID,
      inviter,
      callInvitationType,
    );

    _remoteReceivedTimeoutGuard?.cancel();
    _remoteReceivedTimeoutGuard = Timer.periodic(
      Duration(seconds: timeoutSecond),
      (_) {
        if (ZegoUIKit().getNetworkState() == ZegoUIKitNetworkState.offline &&
            !_invitationData.isEmpty) {
          ZegoLoggerService.logInfo(
            'on invitation received, '
            'invitation timeout on offline network, '
            '_invitationData:$_invitationData',
            tag: 'call-invitation',
            subTag: 'page manager',
          );

          onInvitationTimeout(
            {
              'inviter': _invitationData.inviter,
              'data': data,
            },
          );
        }
      },
    );

    if (_waitCallPageDisposeFlagInIOSCallKit.value) {
      cacheInvitationDataForWaitCallPageDisposeInIOSCallKit(true);
    }

    final callKitCallID = await ZegoUIKitCallCache().offlineCallKit.getCallID();
    ZegoLoggerService.logInfo(
      '_waitingCallInvitationReceivedAfterCallKitIncomingAccepted:$_waitingCallInvitationReceivedAfterCallKitIncomingAccepted, '
      'callkit call id:$callKitCallID',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (ZegoCallInvitationType.videoCall == callInvitationType &&
        callInvitationData.uiConfig.invitee.showVideoOnCalling) {
      if (callInvitationData
          .requireConfig(_invitationData)
          .turnOnCameraWhenJoining) {
        ZegoUIKit().updateVideoViewMode(
          callInvitationData.uiConfig.invitee.useVideoViewAspectFill,
        );
        ZegoUIKit().turnCameraOn(true);
      }
    }

    if (Platform.isAndroid) {
      /// android
      if (_appInBackground) {
        ZegoLoggerService.logInfo(
          'app in background, create notification',
          tag: 'call-invitation',
          subTag: 'page manager',
        );

        callInvitationEventsOnIncomingCallReceived();

        hasCallkitIncomingCauseAppInBackground = true;
        _notificationManager
            ?.showInvitationNotification(invitationData)
            .then((bool hadShow) {
          if (!hadShow) {
            ZegoLoggerService.logWarn(
              'app in background, '
              'but has not system alert window permission, '
              'so can not display callkit window',
              tag: 'call-invitation',
              subTag: 'page manager',
            );

            ///  not system aler window permission
            ///  acitvie app in foregorund and show top sheet
            ZegoUIKit().activeAppToForeground().then((_) {
              showNotificationOnInvitationReceived();
            });
          }
        });
      } else {
        ///  in foregorund
        showNotificationOnInvitationReceived();
      }
    } else {
      /// ios

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
                invitationData.inviter?.id ?? '',
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
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
                result.invitationID,
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
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

          await ZegoUIKitCallCache()
              .offlineCallKit
              .getCallID()
              .then((offlineCallID) {
            ZegoLoggerService.logInfo(
              'offlineCallID:$offlineCallID, _invitationData.callID:${_invitationData.callID}',
              tag: 'call-invitation',
              subTag: 'page manager',
            );

            if (offlineCallID != _invitationData.callID) {
              callInvitationEventsOnIncomingCallReceived();

              ZegoUIKitCallCache()
                  .offlineCallKit
                  .setCallID(_invitationData.callID);

              showCallkitIncoming(
                caller: inviter,
                callType: _invitationData.type,
                callID: sendRequestProtocol.callID,
                timeoutSeconds: sendRequestProtocol.timeout,
                callChannelName: callInvitationData.notificationConfig
                        .androidNotificationConfig?.callChannel.channelName ??
                    defaultCallChannelName,
                missedCallChannelName: callInvitationData
                        .notificationConfig
                        .androidNotificationConfig
                        ?.missedCallChannel
                        .channelName ??
                    defaultMissedCallChannelName,
                ringtonePath: callInvitationData.notificationConfig
                        .androidNotificationConfig?.callChannel.sound ??
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

  void updateInvitationData(
    ZegoCallInvitationSendRequestProtocol sendRequestProtocol,
    String invitationID,
    ZegoUIKitUser inviter,
    ZegoCallInvitationType type,
  ) {
    _invitationData
      ..customData = sendRequestProtocol.customData
      ..callID = sendRequestProtocol.callID
      ..invitationID = invitationID
      ..invitees = List.from(sendRequestProtocol.invitees)
      ..inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name)
      ..type = type;

    ZegoLoggerService.logInfo(
      'update invitation data:$_invitationData',
      tag: 'call-invitation',
      subTag: 'page manager',
    );
  }

  void refuseInCallingOnInvitationReceived({
    required ZegoUIKitUser inviter,
    required String invitationID,
  }) {
    /// in calling, busy reject
    ZegoLoggerService.logInfo(
      'auto refuse this call, because is busy, '
      'is inviting: ${_invitationData.callID.isNotEmpty}, '
      'current state: ${callingMachine?.getPageState() ?? CallingState.kIdle}, '
      'local inviting users: ${ZegoUIKitPrebuiltCallInvitationService().private.localInvitingUsersNotifier.value}, ',
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
  }

  void showNotificationOnInvitationReceived() {
    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    _calleeRingtone.startRing(testPlayRingtone: false);

    callInvitationEventsOnIncomingCallReceived();

    showInvitationTopSheet();
  }

  void callInvitationEventsOnIncomingCallReceived() {
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
  }

  /// Handles the event when an invitation is accepted by the invitee
  /// This method is called when the remote user accepts the call invitation
  ///
  /// [params] Contains the invitation acceptance data including:
  ///   - 'invitee': The user who accepted the invitation
  ///   - 'data': Extended data from the invitation
  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;

    /// TODO: Get invitee's name from data
    final String data =
        params['data']!; // Extended field containing custom data

    ZegoLoggerService.logInfo(
      'invitee:$invitee, '
      'data:$data, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation accepted',
    );

    final inviteeIndex = _invitingInvitees
        .indexWhere((invitingInvitee) => invitingInvitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitee is not in list, '
        'invitee:${invitee.id}, '
        'list:${_invitingInvitees.ids}',
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

    if (isInCalling) {
      callingMachine?.stateOnlineAudioVideo.enter();
    }
  }

  Future<void> onInvitationTimeout(Map<String, dynamic> params) async {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'inviter:$inviter, '
      'data:$data, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation timeout',
    );

    if (_invitationData.isEmpty) {
      ZegoLoggerService.logInfo(
        'local invitation data is empty, ',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation timeout',
      );

      return;
    }

    callInvitationData.invitationEvents?.onIncomingCallTimeout?.call(
      _invitationData.callID,
      ZegoCallUser(inviter.id, inviter.name),
    );

    _invitingInvitees.clear();

    await restoreToIdle();

    if (callInvitationData.config.missedCall.enabled) {
      /// 这里会卡主，如果没开启system alert window
      await _notificationManager?.addMissedCallNotification(
        _invitationData,
        onMissedCallNotificationClicked,
      );
    } else {
      ZegoLoggerService.logInfo(
        'missed-call not enabled, please check on {config.missedCall.enabled}',
        tag: 'call-invitation',
        subTag: 'page manager, missed call notification click',
      );
    }
  }

  Future<void> onMissedCallNotificationClicked(
    ZegoCallInvitationData invitationData,
  ) async {
    if (!callInvitationData.config.missedCall.enableDialBack) {
      ZegoLoggerService.logInfo(
        'redial not enabled, please check on {config.missedCall.enableDialBack}',
        tag: 'call-invitation',
        subTag: 'page manager, missed call notification click',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'missed-call clicked, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, missed call notification click',
    );
//
    if (invitationData.invitees.length > 1) {
      /// group call, join in invitation directly
      await ZegoUIKitPrebuiltCallInvitationService()
          .private
          .invitationImpl
          ?.join(
            invitationID: invitationData.invitationID,
            customData: invitationData.customData,
          )
          .then((result) {
        if (!result) {
          ZegoLoggerService.logError(
            'join failed',
            tag: 'call-invitation',
            subTag: 'page manager, missed call notification click',
          );

          callInvitationData
              .invitationEvents?.onIncomingMissedCallDialBackFailed
              ?.call();

          return;
        }

        try {
          ZegoLoggerService.logInfo(
            'push from missed call, ',
            tag: 'call',
            subTag: 'page manager, missed call notification click, Navigator',
          );

          final currentContext = callInvitationData.contextQuery?.call();
          if (currentContext != null && currentContext.mounted) {
            Navigator.of(currentContext).push(
              MaterialPageRoute(
                builder: (context) => ZegoUIKitPrebuiltCall(
                  appID: callInvitationData.appID,
                  appSign: callInvitationData.appSign,
                  token: callInvitationData.token,
                  callID: invitationData.callID,
                  userID: callInvitationData.userID,
                  userName: callInvitationData.userName,
                  config: callInvitationData.requireConfig(
                    invitationData,
                  ),
                  events: callInvitationData.events,
                  plugins: callInvitationData.plugins,
                ),
              ),
            );
          }
        } catch (e) {
          ZegoLoggerService.logError(
            'Navigator push exception:$e, '
            'contextQuery:${callInvitationData.contextQuery}, ',
            tag: 'call-invitation',
            subTag: 'page manager, missed call notification click',
          );
        }
      });
    } else {
      /// 1v1 call, send same invitation to inviter of missed call
      await ZegoUIKitPrebuiltCallInvitationService().send(
        invitees: [
          ZegoCallUser.fromUIKit(
            invitationData.inviter ?? ZegoUIKitUser.empty(),
          ),
        ],
        isVideoCall: ZegoCallInvitationType.videoCall == invitationData.type,
        customData: invitationData.customData,
        callID: invitationData.callID,
        resourceID: callInvitationData.config.missedCall.resourceID,
        notificationTitle:
            callInvitationData.config.missedCall.notificationTitle?.call(),
        notificationMessage:
            callInvitationData.config.missedCall.notificationMessage?.call(),
        timeoutSeconds: callInvitationData.config.missedCall.timeoutSeconds,
      ).then((result) {
        if (!result) {
          ZegoLoggerService.logError(
            'send failed',
            tag: 'call-invitation',
            subTag: 'page manager, missed call notification click',
          );

          callInvitationData
              .invitationEvents?.onIncomingMissedCallDialBackFailed
              ?.call();

          return;
        }
      });
    }
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

    for (final timeoutInvitee in invitees) {
      _invitingInvitees
          .removeWhere((invitee) => timeoutInvitee.id == invitee.id);
    }
    ZegoUIKitPrebuiltCallInvitationService()
        .private
        .removeUserFromLocalInvitingUsers(invitees.map((e) => e.id).toList());

    ZegoLoggerService.logInfo(
      'data: ${params['data']}, '
      'invitees:${invitees.map((e) => e.toString())}, '
      'inviting invitees: ${_invitingInvitees.ids}, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation response timeout',
    );

    final currentInvitationCallID = _invitationData.callID;
    final currentInvitationCallType = _invitationData.type;
    final currentInvitees =
        invitees.map((user) => ZegoCallUser(user.id, user.name)).toList();

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID:
            _invitationData.invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionTimeout,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

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
        'invitee:{${invitee.id}}, '
        'list:${_invitingInvitees.ids}, '
        'network state:${ZegoUIKit().getNetworkState()}, ',
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
      ZegoUIKit().reporter().report(
        event: ZegoCallReporter.eventCalleeRespondInvitation,
        params: {
          ZegoUIKitSignalingReporter.eventKeyInvitationID:
              rejectRequestData.targetInvitationID,
          ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionBusy,
          ZegoUIKitReporter.eventKeyAppState:
              ZegoUIKitReporter.currentAppState(),
        },
      );

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
      'invitee:$invitee, '
      'inviting invitees: ${_invitingInvitees.ids}, '
      'data: $data, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation refused',
    );

    var restoreCauseByRefused = false;
    if (isGroupCall) {
      if (_invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'all refuse',
          tag: 'call-invitation',
          subTag: 'page manager, on invitation refused',
        );

        restoreCauseByRefused = true;
      }
    } else {
      restoreCauseByRefused = true;
    }

    if (restoreCauseByRefused) {
      ZegoUIKitPrebuiltCallInvitationService().private.updateLocalInvitingUsers(
        [],
      );

      restoreToIdle();

      if (ZegoCallMiniOverlayPageState.minimizing ==
          ZegoCallMiniOverlayMachine().state()) {
        _callerRingtone.stopRing();
        _calleeRingtone.stopRing();

        ZegoUIKitPrebuiltCallController().minimize.hide();
      }
    }
  }

  Future<void> onInvitationCanceled(Map<String, dynamic> params) async {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String eventInvitationID = params['invitation_id'] ?? '';
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'params:$params, '
      'inviter:$inviter, '
      'data:$data, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation canceled',
    );

    if (_invitationData.isEmpty) {
      ZegoLoggerService.logInfo(
        'local invitation data is empty, ',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation canceled',
      );

      return;
    }

    var cancelRequestData =
        ZegoCallInvitationCancelRequestProtocol.fromJson(data);

    if (cancelRequestData.callID != _invitationData.callID &&

        /// Kill the app of inviter that in calling, and then open it again.
        /// ZIM will automatically send the cancel event.
        /// At this time, the data is empty and needs to be judged based on the invitation id
        eventInvitationID != _invitationData.invitationID) {
      ZegoLoggerService.logInfo(
        'is not current call, '
        'data call id:${cancelRequestData.callID}, '
        'event invitation id:$eventInvitationID, '
        'current call id:${_invitationData.callID}, '
        'current invitation id:${_invitationData.invitationID}',
        tag: 'call-invitation',
        subTag: 'page manager, on invitation canceled',
      );

      return;
    }

    callInvitationData.invitationEvents?.onIncomingCallCanceled?.call(
      _invitationData.callID,
      ZegoCallUser(inviter.id, inviter.name),
      cancelRequestData.customData,
    );

    await restoreToIdle();
  }

  void onInvitationEnded(Map<String, dynamic> params) {
    ZegoLoggerService.logInfo(
      'params:$params, '
      'inCallPage:$inCallPage, '
      'network state:${ZegoUIKit().getNetworkState()}, ',
      tag: 'call-invitation',
      subTag: 'page manager, on invitation ended',
    );

    // final ZegoUIKitUser inviter = params['inviter'] ?? ZegoUIKitUser.empty();
    final String invitationID = params['invitation_id'] ?? '';

    if (inCallPage) {
      if (_invitationData.invitationID == invitationID) {
        restoreToIdle();
      }
    }
  }

  void onPrebuiltCallPageDispose() {
    ZegoLoggerService.logInfo(
      'prebuilt call page dispose, ',
      tag: 'call-invitation',
      subTag: 'page manager',
    );

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoCallMiniOverlayMachine().state()) {
      _invitingInvitees.clear();
    }

    restoreToIdle(needPop: false);
  }

  Future<void> restoreToIdle({
    bool needPop = true,
    bool needClearCallKit = true,
    bool needHideInvitationTopSheet = true,
  }) async {
    ZegoLoggerService.logInfo(
      'needPop:$needPop, '
      'needHideInvitationTopSheet:$needHideInvitationTopSheet, '
      'needClearCallKit:$needClearCallKit',
      tag: 'call-invitation',
      subTag: 'page manager, restore to idle',
    );

    isCurrentInvitationFromAcceptedAndroidOffline = false;

    callingConfig.reset();

    _localSendTimeoutGuard?.cancel();
    _remoteReceivedTimeoutGuard?.cancel();
    await _callerRingtone.stopRing();
    await _calleeRingtone.stopRing();

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoCallMiniOverlayMachine().state()) {
      ZegoUIKit.instance.turnCameraOn(false);
    }

    ZegoLoggerService.logInfo(
      'cancelInvitationNotification',
      tag: 'call-invitation',
      subTag: 'page manager, restore to idle',
    );
    await _notificationManager?.cancelInvitationNotification();

    if (null != iOSIncomingPushUUID) {
      ZegoUIKit().getSignalingPlugin().reportCallEnded(
            ZegoSignalingPluginCXCallEndedReason.callEndedReasonRemoteEnded,
            iOSIncomingPushUUID!,
          );
      iOSIncomingPushUUID = null;
    }

    if (needClearCallKit) {
      ZegoLoggerService.logInfo(
        'clear callkit infos',
        tag: 'call-invitation',
        subTag: 'page manager, restore to idle',
      );

      await ZegoUIKitCallCache().offlineCallKit.clearCallID();
      await clearAllCallKitCalls();

      ZegoLoggerService.logInfo(
        'clear callkit infos done',
        tag: 'call-invitation',
        subTag: 'page manager, restore to idle',
      );
    }

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoCallMiniOverlayMachine().state()) {
      _invitationData = ZegoCallInvitationData.empty();
    }

    if (needHideInvitationTopSheet) {
      hideInvitationTopSheet();
    }

    if (CallingState.kIdle !=
        (callingMachine?.machine.current?.identifier ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'restore to idle, '
        'current state:${callingMachine?.machine.current?.identifier}, '
        'inCallPage:$inCallPage',
        tag: 'call-invitation',
        subTag: 'page manager, restore to idle',
      );

      if (needPop) {
        assert(callInvitationData.contextQuery != null);

        inCallPage = false;

        try {
          ZegoLoggerService.logInfo(
            'push from restore to idle, ',
            tag: 'call',
            subTag: 'page manager, restore to idle, Navigator',
          );
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

      ZegoLoggerService.logInfo(
        'done',
        tag: 'call-invitation',
        subTag: 'page manager, restore to idle',
      );
    }
  }

  void onInvitationTopSheetEmptyClicked() {
    ZegoLoggerService.logInfo(
      'start',
      tag: 'call-invitation',
      subTag: 'page manager, onInvitationTopSheetEmptyClicked',
    );

    isHidingInvitationTopSheetDuringSheetEmptyClicked = true;

    hideInvitationTopSheet();

    isHidingInvitationTopSheetDuringSheetEmptyClicked = false;

    ZegoLoggerService.logInfo(
      'end',
      tag: 'call-invitation',
      subTag: 'page manager, onInvitationTopSheetEmptyClicked',
    );

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

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventDisplayInvitationNotification,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID:
            _invitationData.invitationID,
        ZegoUIKitReporter.eventKeyAppState: ZegoUIKitReporter.currentAppState(),
      },
    );

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
        ZegoLoggerService.logInfo(
          'push from hideInvitationTopSheet, ',
          tag: 'call',
          subTag: 'page manager, hideInvitationTopSheet, Navigator',
        );
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
          _notificationManager?.cancelInvitationNotification();

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

      ZegoLoggerService.logInfo(
        'in calling by ios background lock, update to $inCallingByIOSBackgroundLock',
        tag: 'call-invitation',
        subTag: 'page manager, inCallingByIOSBackgroundLock',
      );
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
