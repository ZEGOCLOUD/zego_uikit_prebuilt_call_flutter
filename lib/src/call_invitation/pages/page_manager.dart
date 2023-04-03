// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_inviataion_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/invitation_notify.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoInvitationPageManager {
  ZegoCallInvitationConfig callInvitationConfig;
  ZegoNotificationManager notificationManager;

  ZegoInvitationPageManager({
    required this.callInvitationConfig,
    required this.notificationManager,
  });

  final _defaultPackagePrefix = 'packages/zego_uikit_prebuilt_call/';
  final _callerRingtone = ZegoRingtone();
  final _calleeRingtone = ZegoRingtone();

  late ZegoCallingMachine callingMachine;
  bool _invitationTopSheetVisibility = false;
  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  bool _appInBackground = false;

  ZegoCallInvitationData _invitationData = ZegoCallInvitationData.empty();
  List<ZegoUIKitUser> _invitingInvitees = []; //  only change by inviter

  ZegoCallInvitationData get invitationData => _invitationData;

  bool get isGroupCall => _invitationData.invitees.length > 1;

  /// still ring mean nobody accept this invitation
  bool get isNobodyAccepted => _callerRingtone.isRingTimerRunning;

  Future<void> init({
    required ZegoRingtoneConfig ringtoneConfig,
  }) async {
    listenStream();

    callingMachine = ZegoCallingMachine(
      pageManager: this,
      callInvitationConfig: callInvitationConfig,
    );
    callingMachine.init();

    initRing(ringtoneConfig);

    ZegoUIKitPrebuiltCallMiniOverlayMachine()
        .listenStateChanged(onMiniOverlayMachineStateChanged);

    ZegoLoggerService.logInfo(
      'init, appID:${callInvitationConfig.appID}, '
      'appSign:${callInvitationConfig.appSign},'
      'userID:${callInvitationConfig.userID}, '
      'userName: ${callInvitationConfig.userName}',
      tag: 'call',
      subTag: 'page manager',
    );
  }

  void uninit() {
    ZegoUIKitPrebuiltCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);

    removeStreamListener();
  }

  void updateInvitationConfig(
    bool showDeclineButton,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
    ZegoCallInvitationInnerText? innerText,
  ) {
    callInvitationConfig
      ..showDeclineButton = showDeclineButton
      ..androidNotificationConfig = androidNotificationConfig
      ..invitationEvents = invitationEvents
      ..innerText = innerText;
  }

  void initRing(ZegoRingtoneConfig ringtoneConfig) {
    if (ringtoneConfig.incomingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset caller ring, source path:${ringtoneConfig.incomingCallPath}',
        tag: 'call',
        subTag: 'page manager',
      );
      _callerRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.incomingCallPath!,
        isVibrate: false,
      );
    } else {
      _callerRingtone.init(
        prefix: _defaultPackagePrefix,
        sourcePath: 'assets/invitation/audio/outgoing.mp3',
        isVibrate: false,
      );
    }
    if (ringtoneConfig.outgoingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset callee ring, source path:${ringtoneConfig.outgoingCallPath}',
        tag: 'call',
        subTag: 'page manager',
      );
      _calleeRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.outgoingCallPath!,
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
    // check plugin installed

    _streamSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationReceivedStream()
          .listen(onInvitationReceived))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationAcceptedStream()
          .listen(onInvitationAccepted))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationTimeoutStream()
          .listen(onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationResponseTimeoutStream()
          .listen(onInvitationResponseTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationRefusedStream()
          .listen(onInvitationRefused))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationCanceledStream()
          .listen(onInvitationCanceled));
  }

  void removeStreamListener() {
    for (final streamSubscription in _streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  void onLocalSendInvitation(
    String callID,
    List<ZegoUIKitUser> invitees,
    ZegoCallType invitationType,
    String code,
    String message,
    String invitationID,
    List<String> errorInvitees,
  ) {
    ZegoLoggerService.logInfo(
      'local send invitation, call id:$callID, invitees:$invitees, '
      'type: $invitationType, code:$code, message:$message, '
      'error invitees:$errorInvitees, invitation id:$invitationID',
      tag: 'call',
      subTag: 'page manager',
    );

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'send invitation error!!! code:$code, message:$message',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    _invitingInvitees = List.from(invitees);
    _invitingInvitees
        .removeWhere((invitee) => errorInvitees.contains(invitee.id));

    _invitationData
      ..callID = callID
      ..invitationID = invitationID
      ..inviter = ZegoUIKit().getLocalUser()
      ..invitees = List.from(invitees)
      ..type = invitationType;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (_invitingInvitees.isNotEmpty) {
      _callerRingtone.startRing();

      if (isGroupCall) {
        /// group call, enter room directly
        callingMachine.stateOnlineAudioVideo.enter();
      } else {
        /// single call
        if (ZegoCallType.voiceCall == _invitationData.type) {
          callingMachine.stateCallingWithVoice.enter();
        } else {
          if (callInvitationConfig
              .prebuiltConfigQuery(_invitationData)
              .turnOnCameraWhenJoining) {
            ZegoUIKit.instance.turnCameraOn(true);
          }

          callingMachine.stateCallingWithVideo.enter();
        }
      }
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation(String code, String message) {
    ZegoLoggerService.logInfo(
      'local accept invitation, code:$code, message:$message',
      tag: 'call',
      subTag: 'page manager',
    );

    callInvitationConfig.invitationEvents?.onIncomingCallAcceptButtonPressed
        ?.call();

    _calleeRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onLocalRefuseInvitation(String code, String message) {
    ZegoLoggerService.logInfo(
      'local refuse invitation, code:$code, message:$message',
      tag: 'call',
      subTag: 'page manager',
    );

    callInvitationConfig.invitationEvents?.onIncomingCallDeclineButtonPressed
        ?.call();

    restoreToIdle();
  }

  void onLocalCancelInvitation(
      String code, String message, List<String> errorInvitees) {
    ZegoLoggerService.logInfo(
      'local cancel invitation, code:$code, message:$message, error invitees, $errorInvitees',
      tag: 'call',
      subTag: 'page manager',
    );

    callInvitationConfig.invitationEvents?.onOutgoingCallCancelButtonPressed
        ?.call();

    _invitingInvitees.clear();

    restoreToIdle();
  }

  ///
  void onInvitationReceived(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!; // call type
    final String data = params['data']!; // extended field

    /// zim call id
    final invitationID = params['invitation_id'] as String? ?? '';

    ZegoLoggerService.logInfo(
      'on invitation received, data:${inviter.toString()}, $type $data',
      tag: 'call',
      subTag: 'page manager',
    );

    if (_invitationData.callID.isNotEmpty ||
        CallingState.kIdle != callingMachine.getPageState()) {
      ZegoLoggerService.logInfo(
        'auto refuse this call, because is busy, '
        'is inviting: ${_invitationData.callID.isNotEmpty}, '
        'current state: ${callingMachine.getPageState()}',
        tag: 'call',
        subTag: 'page manager',
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .refuseInvitation(
              inviterID: inviter.id,
              data: const JsonEncoder().convert({
                'reason': 'busy',
                'invitation_id': invitationID,
              }))
          .then((result) {
        ZegoLoggerService.logInfo(
          'auto refuse result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });

      return;
    }

    final invitationInternalData = InvitationInternalData.fromJson(data);
    _invitationData
      ..customData = invitationInternalData.customData
      ..callID = invitationInternalData.callID
      ..invitationID = invitationID
      ..invitees = List.from(invitationInternalData.invitees)
      ..inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name)
      ..type = ZegoCallTypeExtension.mapValue[type] as ZegoCallType;

    if (_appInBackground) {
      ZegoLoggerService.logInfo(
        'app in background, create notification',
        tag: 'call',
        subTag: 'page manager',
      );

      if (Platform.isAndroid) {
        _calleeRingtone.startRing(); //  ios will crash
      }

      notificationManager.createNotification(_invitationData);
    } else {
      showNotificationOnInvitationReceived();
    }
  }

  void showNotificationOnInvitationReceived() {
    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    _calleeRingtone.startRing();

    callInvitationConfig.invitationEvents?.onIncomingCallReceived?.call(
        _invitationData.callID,
        ZegoCallUser(
          _invitationData.inviter?.id ?? '',
          _invitationData.inviter?.name ?? '',
        ),
        _invitationData.type,
        _invitationData.invitees
            .map((user) => ZegoCallUser(user.id, user.name))
            .toList());

    showInvitationTopSheet();
  }

  void onInvitationAccepted(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation accepted, data:${invitee.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    final inviteeIndex =
        _invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
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

    callInvitationConfig.invitationEvents?.onOutgoingCallAccepted
        ?.call(_invitationData.callID, ZegoCallUser(invitee.id, invitee.name));

    _invitingInvitees.removeAt(inviteeIndex);

    _callerRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onInvitationTimeout(Map<String, dynamic> params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation timeout, data:${inviter.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    callInvitationConfig.invitationEvents?.onIncomingCallTimeout
        ?.call(_invitationData.callID, ZegoCallUser(inviter.id, inviter.name));

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

    callInvitationConfig.invitationEvents?.onOutgoingCallTimeout?.call(
      currentInvitationCallID,
      currentInvitees,
      ZegoCallType.videoCall == currentInvitationCallType,
    );
  }

  void onInvitationRefused(Map<String, dynamic> params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    final inviteeIndex =
        _invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
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

    final dict = jsonDecode(data) as Map<String, dynamic>;
    final refusedInvitationID = dict['invitation_id'] as String? ?? '';
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

    if ('busy' == (dict['reason'] as String)) {
      callInvitationConfig.invitationEvents?.onOutgoingCallRejectedCauseBusy
          ?.call(
              _invitationData.callID, ZegoCallUser(invitee.id, invitee.name));
    } else {
      /// "decline"
      callInvitationConfig.invitationEvents?.onOutgoingCallDeclined?.call(
          _invitationData.callID, ZegoCallUser(invitee.id, invitee.name));
    }

    _invitingInvitees.removeAt(inviteeIndex);

    ZegoLoggerService.logInfo(
      'on invitation refused, data: $data, '
      'invitee:${invitee.toString()}, '
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
      'on invitation canceled, data:${inviter.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    callInvitationConfig.invitationEvents?.onIncomingCallCanceled
        ?.call(_invitationData.callID, ZegoCallUser(inviter.id, inviter.name));

    if (_appInBackground) {
      /// clear notifications
      AwesomeNotifications().cancelAll();
    }

    restoreToIdle();
  }

  void onHangUp() {
    ZegoLoggerService.logInfo(
      'on hang up',
      tag: 'call',
      subTag: 'page manager',
    );

    if (isNobodyAccepted) {
      ZegoUIKit()
          .getSignalingPlugin()
          .cancelInvitation(
              invitees: _invitingInvitees.map((user) => user.id).toList(),
              data: '')
          .then((result) {
        ZegoLoggerService.logInfo(
          'hang up cancel result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });
    }

    restoreToIdle();
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

  void restoreToIdle({bool needPop = true}) {
    ZegoLoggerService.logInfo(
      'invitation page service to be idle',
      tag: 'call',
      subTag: 'page manager',
    );

    _callerRingtone.stopRing();
    _calleeRingtone.stopRing();

    if (PrebuiltCallMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
      ZegoUIKit.instance.turnCameraOn(false);
    }

    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine.machine.current?.identifier ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'restore to idle, current state:${callingMachine.machine.current?.identifier}',
        tag: 'call',
        subTag: 'page manager',
      );

      if (needPop) {
        assert(callInvitationConfig.contextQuery != null);
        Navigator.of(callInvitationConfig.contextQuery!.call()).pop();
      }

      callingMachine.stateIdle.enter();
    }

    _invitationData = ZegoCallInvitationData.empty();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoCallType.voiceCall == _invitationData.type) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    if (_invitationTopSheetVisibility) {
      return;
    }

    _invitationTopSheetVisibility = true;

    showTopModalSheet(
      callInvitationConfig.contextQuery!.call(),
      GestureDetector(
        onTap: onInvitationTopSheetEmptyClicked,
        child: ZegoCallInvitationDialog(
          pageManager: this,
          callInvitationConfig: callInvitationConfig,
          invitationData: _invitationData,
          avatarBuilder: callInvitationConfig
              .prebuiltConfigQuery(_invitationData)
              .avatarBuilder,
          showDeclineButton: callInvitationConfig.showDeclineButton,
          appDesignSize: callInvitationConfig.appDesignSize,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    if (_invitationTopSheetVisibility) {
      assert(callInvitationConfig.contextQuery != null);
      Navigator.of(callInvitationConfig.contextQuery!.call()).pop();

      _invitationTopSheetVisibility = false;
    }
  }

  void didChangeAppLifecycleState(bool isAppInBackground) {
    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState, '
      'is app in background: previous:$_appInBackground, current: $isAppInBackground, '
      'call machine page state:${callingMachine.getPageState()}, '
      'invitation data:${_invitationData.toString()}',
      tag: 'call',
      subTag: 'page manager',
    );

    final hasReceivedInvitation = _invitationData.callID.isNotEmpty &&
        _invitationData.inviter?.id != ZegoUIKit().getLocalUser().id;
    if (CallingState.kIdle == callingMachine.getPageState() &&
        _appInBackground &&
        !isAppInBackground &&
        hasReceivedInvitation) {
      ZegoLoggerService.logInfo(
        'had invitation in background before, show notification now',
        tag: 'call',
        subTag: 'page manager',
      );
      showNotificationOnInvitationReceived();
    }

    if (!isAppInBackground) {
      /// clear notifications
      AwesomeNotifications().cancelAll();
    }

    _appInBackground = isAppInBackground;
  }

  void onMiniOverlayMachineStateChanged(
      PrebuiltCallMiniOverlayPageState state) {
    if (PrebuiltCallMiniOverlayPageState.calling == state) {
      callingMachine.stateOnlineAudioVideo.enter();
    }
  }
}
