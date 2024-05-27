part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServiceAPIPrivate {
  final _private = ZegoCallInvitationServiceAPIPrivateImpl();

  /// Don't call that
  ZegoCallInvitationServiceAPIPrivateImpl get private => _private;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoCallInvitationServiceAPIPrivateImpl {
  ZegoCallInvitationPageManager? get _pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoUIKitPrebuiltCallInvitationData? get _callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationData;

  ZegoCallInvitationInnerText? _innerText;

  ZegoUIKitPrebuiltCallEvents? get events => _events;
  ZegoUIKitPrebuiltCallEvents? _events;

  //
  // /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void init({
    required ZegoCallInvitationInnerText? innerText,
    required ZegoUIKitPrebuiltCallEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    _events = events;
    _innerText = innerText;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninit() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    _innerText = null;
    _events = null;
  }

  Future<bool> _sendInvitation({
    required List<ZegoCallUser> callees,
    required bool isVideoCall,
    required String callID,
    String customData = '',
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) {
    ZegoLoggerService.logInfo(
      'cancel call invitation, '
      'callees:$callees, '
      'isVideoCall:$isVideoCall, '
      'callID:$callID, '
      'customData:$customData, '
      'resourceID:$resourceID, '
      'notificationTitle:$notificationTitle, '
      'notificationMessage:$notificationMessage, '
      'timeoutSeconds:$timeoutSeconds',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: callees.map((user) {
            return user.id;
          }).toList(),
          timeout: timeoutSeconds,
          type: ZegoCallTypeExtension(
            isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
          ).value,
          data: ZegoCallInvitationSendRequestProtocol(
            callID: callID,
            invitees: callees
                .map((invitee) => ZegoUIKitUser(
                      id: invitee.id,
                      name: invitee.name,
                    ))
                .toList(),
            timeout: timeoutSeconds,
            customData: customData,
          ).toJson(),
          zegoNotificationConfig: ZegoNotificationConfig(
            notifyWhenAppIsInTheBackgroundOrQuit: true,
            resourceID: resourceID ?? '',
            title: notificationTitle ??
                (isVideoCall
                        ? ((callees.length > 1
                                ? _innerText?.incomingGroupVideoCallDialogTitle
                                : _innerText?.incomingVideoCallDialogTitle) ??
                            param_1)
                        : ((callees.length > 1
                                ? _innerText?.incomingGroupVoiceCallDialogTitle
                                : _innerText?.incomingVoiceCallDialogTitle) ??
                            param_1))
                    .replaceFirst(param_1, ZegoUIKit().getLocalUser().name),
            message: notificationMessage ??
                (isVideoCall
                    ? ((callees.length > 1
                            ? _innerText?.incomingGroupVideoCallDialogMessage
                            : _innerText?.incomingVideoCallDialogMessage) ??
                        'Incoming video call...')
                    : ((callees.length > 1
                            ? _innerText?.incomingGroupVoiceCallDialogMessage
                            : _innerText?.incomingVoiceCallDialogMessage) ??
                        'Incoming voice call...')),
          ),
        )
        .then((result) {
      _pageManager?.onLocalSendInvitation(
        callID: callID,
        invitees: callees
            .map((invitee) => ZegoUIKitUser(
                  id: invitee.id,
                  name: invitee.name,
                ))
            .toList(),
        invitationType:
            isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
        customData: customData,
        code: result.error?.code ?? '',
        message: result.error?.message ?? '',
        invitationID: result.invitationID,
        errorInvitees: result.errorInvitees.keys.toList(),
      );

      return result.error?.code.isNotEmpty ?? true;
    });
  }

  Future<bool> _cancelInvitation({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'cancel call invitation, callees:$callees',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .cancelInvitation(
          invitees: callees.map((e) => e.id).toList(),
          data: ZegoCallInvitationCancelRequestProtocol(
            callID: _pageManager?.currentCallID ?? '',
            customData: customData,
          ).toJson(),
        )
        .then((result) async {
      _pageManager?.onLocalCancelInvitation(
        result.error?.code ?? '',
        result.error?.message ?? '',
        result.errorInvitees,
      );

      return result.error?.code.isNotEmpty ?? true;
    });
  }

  Future<bool> _rejectInvitation({
    required String callerID,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'reject call invitation, callerID:$callerID',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    _pageManager?.hideInvitationTopSheet();

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: callerID,
          data: ZegoCallInvitationRejectRequestProtocol(
            reason: ZegoCallInvitationProtocolKey.refuseByDecline,
            customData: customData,
          ).toJson(),
        )
        .then((result) {
      _pageManager?.onLocalRefuseInvitation(
        result.error?.code ?? '',
        result.error?.message ?? '',
      );

      return result.error?.code.isNotEmpty ?? true;
    });
  }

  Future<bool> _acceptInvitation({
    required String callerID,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'accept call invitation, callerID:$callerID',
      tag: 'call',
      subTag: 'controller.invitation.p',
    );

    _pageManager?.hideInvitationTopSheet();

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(
          inviterID: callerID,
          data: ZegoCallInvitationAcceptRequestProtocol(
            customData: customData,
          ).toJson(),
        )
        .then((result) {
      _pageManager?.onLocalAcceptInvitation(
        result.error?.code ?? '',
        result.error?.message ?? '',
      );

      return result.error?.code.isNotEmpty ?? true;
    });
  }

  /// Waits until the specified condition is met.
  Future<int> _waitUntil(
    bool Function() test, {
    final int maxIterations = 100,
    final Duration step = const Duration(milliseconds: 10),
  }) async {
    var iterations = 0;
    for (; iterations < maxIterations; iterations++) {
      await Future.delayed(step);
      if (test()) {
        break;
      }
    }
    if (iterations >= maxIterations) {
      return iterations;
    }
    return iterations;
  }

  bool _checkParamValid() {
    if (null == _pageManager || null == _callInvitationConfig) {
      ZegoLoggerService.logInfo(
        'param is invalid, page manager:$_pageManager, invitation config:$_callInvitationConfig',
        tag: 'call',
        subTag: 'controller.invitation.p',
      );

      return false;
    }

    return true;
  }

  bool _checkSignalingPlugin() {
    if (ZegoSignalingPluginConnectionState.connected !=
        ZegoUIKit().getSignalingPlugin().getConnectionState()) {
      ZegoLoggerService.logError(
        'signaling is not connected:${ZegoUIKit().getSignalingPlugin().getConnectionState()}',
        tag: 'call',
        subTag: 'controller.invitation.p',
      );
      return false;
    }

    return true;
  }

  bool _checkInInvitation() {
    final isInInvitation =
        _pageManager?.invitationData.callID.isNotEmpty ?? false;

    if (!isInInvitation) {
      ZegoLoggerService.logInfo(
        'not in invitation, '
        'invitationData:${_pageManager?.invitationData}',
        tag: 'call',
        subTag: 'controller.invitation',
      );
    }

    return isInInvitation;
  }

  bool _checkInCalling() {
    final currentState =
        _pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kIdle != currentState) {
      ZegoLoggerService.logInfo(
        'in calling now, $currentState',
        tag: 'call',
        subTag: 'controller.invitation.p',
      );
      return false;
    }

    return true;
  }

  bool _checkInNotCalling() {
    final currentState =
        _pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kCallingWithVoice != currentState &&
        CallingState.kCallingWithVideo != currentState &&
        CallingState.kOnlineAudioVideo != currentState) {
      ZegoLoggerService.logInfo(
        'not in calling now, $currentState',
        tag: 'call',
        subTag: 'controller.invitation.p',
      );
      return false;
    }

    return true;
  }
}
