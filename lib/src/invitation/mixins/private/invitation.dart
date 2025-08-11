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

  bool get _isAdvanceInvitationMode =>
      ZegoUIKitPrebuiltCallInvitationService().private.isAdvanceInvitationMode;

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
      tag: 'call-invitation',
      subTag: 'service.p',
    );

    _events = events;
    _innerText = innerText;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninit() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call-invitation',
      subTag: 'service.p',
    );

    _innerText = null;
    _events = null;
  }

  Future<bool> _addInvitation({
    required List<ZegoCallUser> callees,
    required bool isVideoCall,
    required String callID,
    required String invitationID,
    String customData = '',
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) async {
    ZegoLoggerService.logInfo(
      'callees:$callees, '
      'isVideoCall:$isVideoCall, '
      'callID:$callID, '
      'customData:$customData, '
      'resourceID:$resourceID, '
      'notificationTitle:$notificationTitle, '
      'notificationMessage:$notificationMessage, '
      'timeoutSeconds:$timeoutSeconds',
      tag: 'call-invitation',
      subTag: 'service.p, add call invitation',
    );

    if (!_isAdvanceInvitationMode) {
      ZegoLoggerService.logError(
        'please set {ZegoCallInvitationConfig.inCalling.canInvitingInCalling} or {ZegoCallInvitationConfig.missedCall.enableDialBack} to be true',
        tag: 'call-invitation',
        subTag: 'service.p, add call invitation',
      );

      // return false;
    }

    final localInvitingInviteeIDs = ZegoUIKitPrebuiltCallInvitationService()
        .private
        .localInvitingUsersNotifier
        .value
        .map((e) => e.id)
        .toList();
    callees
        .removeWhere((callee) => localInvitingInviteeIDs.contains(callee.id));
    ZegoLoggerService.logInfo(
      'clear inviting invitee id, '
      'localInvitingInviteeIDs:$localInvitingInviteeIDs, '
      'now callee is:$callees, ',
      tag: 'call-invitation',
      subTag: 'service.p, add call invitation',
    );

    if (callees.isEmpty) {
      ZegoLoggerService.logInfo(
        'callees is empty',
        tag: 'call-invitation',
        subTag: 'service.p, add call invitation',
      );

      return false;
    }

    ZegoUIKitPrebuiltCallInvitationService().private.updateLocalInvitingUsers([
      ...ZegoUIKitPrebuiltCallInvitationService()
          .private
          .localInvitingUsersNotifier
          .value,
      ...callees,
    ]);

    return ZegoUIKit()
        .getSignalingPlugin()
        .addAdvanceInvitation(
          inviterID: ZegoUIKit().getLocalUser().id,
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: callees.map((user) {
            return user.id;
          }).toList(),
          invitationID: invitationID,
          type: ZegoCallTypeExtension(
            isVideoCall
                ? ZegoCallInvitationType.videoCall
                : ZegoCallInvitationType.voiceCall,
          ).value,
          data: ZegoCallInvitationSendRequestProtocol(
            callID: callID,
            inviterName: ZegoUIKit().getLocalUser().name,
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
            title: getNotificationTitle(
              defaultTitle: notificationTitle,
              callees: callees,
              isVideoCall: isVideoCall,
              innerText: _innerText,
            ),
            message: getNotificationMessage(
              defaultMessage: notificationMessage,
              callees: callees,
              isVideoCall: isVideoCall,
              innerText: _innerText,
            ),
          ),
        )
        .then((result) {
      _pageManager?.onLocalAddInvitation(
        callID: callID,
        invitees: callees
            .map((invitee) => ZegoUIKitUser(
                  id: invitee.id,
                  name: invitee.name,
                ))
            .toList(),
        invitationType: isVideoCall
            ? ZegoCallInvitationType.videoCall
            : ZegoCallInvitationType.voiceCall,
        customData: customData,
        code: result.error?.code ?? '',
        message: result.error?.message ?? '',
        invitationID: result.invitationID,
        errorInvitees: result.errorInvitees.keys.toList(),
      );

      return result.error?.code.isEmpty ?? true;
    });
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
      'callees:$callees, '
      'isVideoCall:$isVideoCall, '
      'callID:$callID, '
      'customData:$customData, '
      'resourceID:$resourceID, '
      'notificationTitle:$notificationTitle, '
      'notificationMessage:$notificationMessage, '
      'timeoutSeconds:$timeoutSeconds',
      tag: 'call-invitation',
      subTag: 'service.p, send call invitation',
    );

    ZegoUIKitPrebuiltCallInvitationService().private.updateLocalInvitingUsers(
          List.from(callees),
        );

    final sendProtocol = ZegoCallInvitationSendRequestProtocol(
      callID: callID,
      inviterName: ZegoUIKit().getLocalUser().name,
      invitees: callees
          .map((invitee) => ZegoUIKitUser(
                id: invitee.id,
                name: invitee.name,
              ))
          .toList(),
      timeout: timeoutSeconds,
      customData: customData,
    ).toJson();
    final sendInvitationType = ZegoCallTypeExtension(
      isVideoCall
          ? ZegoCallInvitationType.videoCall
          : ZegoCallInvitationType.voiceCall,
    ).value;
    final sendNotificationConfig = ZegoNotificationConfig(
      notifyWhenAppIsInTheBackgroundOrQuit: true,
      resourceID: resourceID ?? '',
      title: getNotificationTitle(
        defaultTitle: notificationTitle,
        callees: callees,
        isVideoCall: isVideoCall,
        innerText: _innerText,
      ),
      message: getNotificationMessage(
        defaultMessage: notificationMessage,
        callees: callees,
        isVideoCall: isVideoCall,
        innerText: _innerText,
      ),
    );

    Future<bool> sendInvitationCallback(
      ZegoSignalingPluginSendInvitationResult result,
    ) async {
      ZegoUIKit().reporter().report(
        event: ZegoCallReporter.eventSendInvitation,
        params: {
          ZegoUIKitSignalingReporter.eventKeyInvitationID: result.invitationID,
          ZegoCallReporter.eventKeyInvitationSource:
              ZegoCallReporter.eventKeyInvitationSourceAPI,
        },
      );

      await _pageManager?.onLocalSendInvitation(
        callID: callID,
        invitees: callees
            .map((invitee) => ZegoUIKitUser(
                  id: invitee.id,
                  name: invitee.name,
                ))
            .toList(),
        invitationType: isVideoCall
            ? ZegoCallInvitationType.videoCall
            : ZegoCallInvitationType.voiceCall,
        customData: customData,
        code: result.error?.code ?? '',
        message: result.error?.message ?? '',
        invitationID: result.invitationID,
        errorInvitees: result.errorInvitees.keys.toList(),
        localConfig: ZegoCallInvitationLocalParameter(
          resourceID: resourceID,
          notificationTitle: notificationTitle,
          notificationMessage: notificationMessage,
          timeoutSeconds: timeoutSeconds,
        ),
      );

      return result.error?.code.isEmpty ?? true;
    }

    if (_isAdvanceInvitationMode) {
      return ZegoUIKit()
          .getSignalingPlugin()
          .sendAdvanceInvitation(
            inviterID: ZegoUIKit().getLocalUser().id,
            inviterName: ZegoUIKit().getLocalUser().name,
            invitees: callees.map((user) {
              return user.id;
            }).toList(),
            timeout: timeoutSeconds,
            type: sendInvitationType,
            data: sendProtocol,
            zegoNotificationConfig: sendNotificationConfig,
          )
          .then(sendInvitationCallback);
    } else {
      return ZegoUIKit()
          .getSignalingPlugin()
          .sendInvitation(
            inviterID: ZegoUIKit().getLocalUser().id,
            inviterName: ZegoUIKit().getLocalUser().name,
            invitees: callees.map((user) {
              return user.id;
            }).toList(),
            timeout: timeoutSeconds,
            type: sendInvitationType,
            data: sendProtocol,
            zegoNotificationConfig: sendNotificationConfig,
          )
          .then(sendInvitationCallback);
    }
  }

  Future<bool> _cancelInvitation({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'callees:$callees',
      tag: 'call-invitation',
      subTag: 'service.p, cancel call invitation',
    );

    Future<bool> callback(
      ZegoSignalingPluginCancelInvitationResult result,
    ) async {
      _pageManager?.onLocalCancelInvitation(
        result.invitationID,
        result.error?.code ?? '',
        result.error?.message ?? '',
        result.errorInvitees,
      );

      return result.error?.code.isEmpty ?? true;
    }

    if (_isAdvanceInvitationMode) {
      return ZegoUIKit()
          .getSignalingPlugin()
          .cancelAdvanceInvitation(
            invitees: callees.map((e) => e.id).toList(),
            data: ZegoCallInvitationCancelRequestProtocol(
              callID: _pageManager?.currentCallID ?? '',
              customData: customData,
            ).toJson(),
            invitationID: _pageManager?.invitationData.invitationID ?? '',
          )
          .then(callback);
    } else {
      return ZegoUIKit()
          .getSignalingPlugin()
          .cancelInvitation(
            invitees: callees.map((e) => e.id).toList(),
            data: ZegoCallInvitationCancelRequestProtocol(
              callID: _pageManager?.currentCallID ?? '',
              customData: customData,
            ).toJson(),
          )
          .then(callback);
    }
  }

  Future<bool> _rejectInvitation({
    required String callerID,
    String customData = '',
    bool needHideInvitationTopSheet = true,
  }) async {
    ZegoLoggerService.logInfo(
      'callerID:$callerID, '
      'customData:$customData, '
      'needHideInvitationTopSheet:$needHideInvitationTopSheet, ',
      tag: 'call-invitation',
      subTag: 'service.p, reject call invitation',
    );

    if (needHideInvitationTopSheet) {
      _pageManager?.hideInvitationTopSheet();
    }

    Future<bool> callback(
      ZegoSignalingPluginResponseInvitationResult result,
    ) async {
      _pageManager
          ?.onLocalRefuseInvitation(
        result.invitationID,
        result.error?.code ?? '',
        result.error?.message ?? '',
        needHideInvitationTopSheet: needHideInvitationTopSheet,
      )
          .then((_) {
        ZegoLoggerService.logInfo(
          'callerID:$callerID, '
          'customData:$customData, '
          'needHideInvitationTopSheet:$needHideInvitationTopSheet, '
          'onLocalRefuseInvitation done',
          tag: 'call-invitation',
          subTag: 'service.p, reject call invitation',
        );
      });

      return result.error?.code.isEmpty ?? true;
    }

    if (_isAdvanceInvitationMode) {
      return ZegoUIKit()
          .getSignalingPlugin()
          .refuseAdvanceInvitation(
            inviterID: callerID,
            data: ZegoCallInvitationRejectRequestProtocol(
              reason: ZegoCallInvitationProtocolKey.refuseByDecline,
              customData: customData,
            ).toJson(),
            invitationID: _pageManager?.invitationData.invitationID ?? '',
          )
          .then(callback);
    } else {
      return ZegoUIKit()
          .getSignalingPlugin()
          .refuseInvitation(
            inviterID: callerID,
            data: ZegoCallInvitationRejectRequestProtocol(
              reason: ZegoCallInvitationProtocolKey.refuseByDecline,
              customData: customData,
            ).toJson(),
          )
          .then(callback);
    }
  }

  Future<bool> _acceptInvitation({
    required String callerID,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'callerID:$callerID',
      tag: 'call-invitation',
      subTag: 'service.p, accept call invitation',
    );

    _pageManager?.hideInvitationTopSheet();

    Future<bool> callback(
      ZegoSignalingPluginResponseInvitationResult result,
    ) async {
      _pageManager?.onLocalAcceptInvitation(
        result.invitationID,
        result.error?.code ?? '',
        result.error?.message ?? '',
      );

      return result.error?.code.isEmpty ?? true;
    }

    if (_isAdvanceInvitationMode) {
      return ZegoUIKit()
          .getSignalingPlugin()
          .acceptAdvanceInvitation(
            inviterID: callerID,
            data: ZegoCallInvitationAcceptRequestProtocol(
              customData: customData,
            ).toJson(),
            invitationID: _pageManager?.invitationData.invitationID ?? '',
          )
          .then(callback);
    } else {
      return ZegoUIKit()
          .getSignalingPlugin()
          .acceptInvitation(
            inviterID: callerID,
            data: ZegoCallInvitationAcceptRequestProtocol(
              customData: customData,
            ).toJson(),
          )
          .then(callback);
    }
  }

  Future<bool> _joinInvitation({
    required String invitationID,
    String? customData = '',
  }) {
    return ZegoUIKit()
        .getSignalingPlugin()
        .joinAdvanceInvitation(
          invitationID: invitationID,
          data: ZegoCallInvitationAcceptRequestProtocol(
            customData: customData ?? '',
          ).toJson(),
        )
        .then((result) {
      return result.error?.code.isEmpty ?? true;
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
      ZegoLoggerService.logWarn(
        'param is invalid, page manager:$_pageManager, invitation config:$_callInvitationConfig',
        tag: 'call-invitation',
        subTag: 'service.p',
      );

      return false;
    }

    return true;
  }

  bool _checkSignalingPlugin() {
    if (ZegoSignalingPluginConnectionState.connected !=
        ZegoUIKit().getSignalingPlugin().getConnectionState()) {
      ZegoLoggerService.logError(
        'signaling is not connected:${ZegoUIKit().getSignalingPlugin().getConnectionState()}, '
        'ZegoUIKitPrebuiltCallInvitationService is init: ${ZegoUIKitPrebuiltCallInvitationService().isInit}'
        'please call ZegoUIKitPrebuiltCallInvitationService.init with ZegoUIKitSignalingPlugin first',
        tag: 'call-invitation',
        subTag: 'service.p',
      );

      return false;
    }

    return true;
  }

  bool _checkInInvitation() {
    final isInInvitation =
        _pageManager?.invitationData.callID.isNotEmpty ?? false;

    if (!isInInvitation) {
      ZegoLoggerService.logWarn(
        'not in invitation, '
        'invitationData:${_pageManager?.invitationData}',
        tag: 'call-invitation',
        subTag: 'service.p',
      );
    }

    return isInInvitation;
  }

  bool _checkInCall() {
    final currentState =
        _pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kOnlineAudioVideo == currentState) {
      ZegoLoggerService.logWarn(
        'in call now, $currentState',
        tag: 'call-invitation',
        subTag: 'service.p',
      );
      return true;
    }

    return false;
  }

  bool _checkInNotCalling() {
    final currentState =
        _pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kCallingWithVoice != currentState &&
        CallingState.kCallingWithVideo != currentState &&
        CallingState.kOnlineAudioVideo != currentState) {
      ZegoLoggerService.logWarn(
        'not in calling now, $currentState',
        tag: 'call-invitation',
        subTag: 'service.p',
      );
      return false;
    }

    return true;
  }
}
