part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltCallControllerPrivate {
  /// Screen sharing related interfaces.
  final screenSharingViewController = ZegoScreenSharingViewController();

  /// Whether the call hang-up operation is in progress
  /// such as clicking the close button in the upper right corner or calling the `hangUp` function of the controller.
  /// If it is not handled completely, it is considered as in progress.
  final ValueNotifier<bool> isHangUpRequestingNotifier =
      ValueNotifier<bool>(false);

  /// ZegoUIKitPrebuiltCall's config
  ZegoUIKitPrebuiltCallConfig? get prebuiltConfig => _prebuiltConfig;

  ZegoUIKitPrebuiltCallConfig? _prebuiltConfig;

  ZegoInvitationPageManager? get _pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoCallInvitationConfig? get _callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationConfig;

  ZegoCallInvitationInnerText? get _innerText =>
      _callInvitationConfig?.innerText;

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
      subTag: 'controller_p',
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
          data: InvitationInternalData(
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
        callID,
        callees
            .map((invitee) => ZegoUIKitUser(
                  id: invitee.id,
                  name: invitee.name,
                ))
            .toList(),
        isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
        result.error?.code ?? '',
        result.error?.message ?? '',
        result.invitationID,
        result.errorInvitees.keys.toList(),
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
      subTag: 'controller_p',
    );

    return ZegoUIKit()
        .getSignalingPlugin()
        .cancelInvitation(
          invitees: callees.map((e) => e.id).toList(),
          data: const JsonEncoder().convert({
            'call_id': _pageManager?.currentCallID ?? '',
            messageTypePayloadKey: BackgroundMessageType.cancelInvitation.text,
            'custom_data': customData,
          }),
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
      subTag: 'controller_p',
    );

    _pageManager?.hideInvitationTopSheet();

    return ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: callerID,
          data: const JsonEncoder().convert({
            'reason': 'decline',
            'custom_data': customData,
          }),
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
      subTag: 'controller_p',
    );

    _pageManager?.hideInvitationTopSheet();

    return ZegoUIKit()
        .getSignalingPlugin()
        .acceptInvitation(
          inviterID: callerID,
          data: const JsonEncoder().convert({
            'custom_data': customData,
          }),
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
        subTag: 'controller',
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
        subTag: 'controller',
      );
      return false;
    }

    return true;
  }

  bool _checkInCalling() {
    final currentState =
        _pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kIdle != currentState) {
      ZegoLoggerService.logInfo(
        'in calling now, $currentState',
        tag: 'call',
        subTag: 'controller',
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
        subTag: 'controller',
      );
      return false;
    }

    return true;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({required ZegoUIKitPrebuiltCallConfig prebuiltConfig}) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller_p',
    );

    _prebuiltConfig = prebuiltConfig;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller_p',
    );

    isHangUpRequestingNotifier.value = false;

    _prebuiltConfig = null;
  }
}
