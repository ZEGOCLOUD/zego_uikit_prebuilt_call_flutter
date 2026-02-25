part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServiceAPI {
  final _invitation = ZegoCallInvitationServiceAPIImpl();
}

/// Here are the APIs related to invitation.
class ZegoCallInvitationServiceAPIImpl
    with ZegoCallInvitationServiceAPIPrivate {
  /// Send a call invitation to one or more users.
  ///
  /// [invitees] List of users to invite.
  /// [isVideoCall] Whether this is a video call.
  /// [customData] Custom data to send with the invitation.
  /// [callID] Custom call ID. If not provided, a unique ID will be generated.
  /// [resourceID] Resource ID for offline push notification.
  /// [notificationTitle] Custom notification title for offline push.
  /// [notificationMessage] Custom notification message for offline push.
  /// [timeoutSeconds] Timeout in seconds for the invitation (default 60).
  Future<bool> send({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) async {
    ZegoLoggerService.logInfo(
      'send call invitation',
      tag: 'call-invitation',
      subTag: 'service, send',
    );

    if (!private._checkParamValid()) {
      ZegoLoggerService.logInfo(
        'parameter is not valid',
        tag: 'call-invitation',
        subTag: 'service, send',
      );

      return false;
    }

    if (!private._checkSignalingPlugin()) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag: 'service, send',
      );

      return false;
    }

    sendInvitationFunc(callID) {
      /// todo: incall 替换为 是否同一个call id
      final isSameCall = callID == private._pageManager?.invitationData.callID;
      final isInCall = private._checkInCall();
      ZegoLoggerService.logInfo(
        'isInCall:${private._checkInCall()}, '
        'previous call id:${private._pageManager?.invitationData.callID}, '
        'call id:$callID, '
        'isSameCall:$isSameCall, ',
        tag: 'call-invitation',
        subTag: 'service, send',
      );

      return isInCall
          ? private._addInvitation(
              callees: invitees,
              isVideoCall: isVideoCall,
              callID: callID,
              invitationID: ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .currentCallInvitationDataSafe
                  .invitationID,
              customData: customData,
              resourceID: resourceID,
              timeoutSeconds: timeoutSeconds,
              notificationTitle: notificationTitle,
              notificationMessage: notificationMessage,
            )
          : private._sendInvitation(
              callees: invitees,
              isVideoCall: isVideoCall,
              callID: callID,
              customData: customData,
              resourceID: resourceID,
              timeoutSeconds: timeoutSeconds,
              notificationTitle: notificationTitle,
              notificationMessage: notificationMessage,
            );
    }

    final currentCallID = callID ??
        'call_${ZegoUIKit().getLocalUser().id}_${DateTime.now().millisecondsSinceEpoch}';
    if ((callID?.isNotEmpty ?? false) && currentCallID != callID) {
      ZegoLoggerService.logWarn(
        'callID($callID) is not valid, replace by $currentCallID',
        tag: 'call-invitation',
        subTag: 'service, send',
      );
    }
    if (private._pageManager?.callingMachine?.isPagePushed ?? false) {
      return private._waitUntil(() {
        if (null == private._pageManager?.callingMachine) {
          return true;
        }
        return private._pageManager!.callingMachine!.isPagePushed;
      }).then((value) {
        return sendInvitationFunc(currentCallID);
      });
    }

    return sendInvitationFunc(currentCallID);
  }

  /// Cancel an outgoing call invitation.
  ///
  /// [callees] List of callees to cancel the invitation for.
  /// [customData] Custom data to send with the cancellation.
  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'cancel call invitation',
      tag: 'call-invitation',
      subTag: 'service, invitation',
    );

    if (!private._checkParamValid()) {
      ZegoLoggerService.logInfo(
        'parameter is not valid',
        tag: 'call-invitation',
        subTag: 'service, cancel',
      );

      return false;
    }

    if (!private._checkSignalingPlugin()) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag: 'service, cancel',
      );

      return false;
    }

    if (!private._checkInNotCalling()) {
      return false;
    }

    return private._cancelInvitation(
      callees: callees,
      customData: customData,
    );
  }

  /// Reject an incoming call invitation.
  ///
  /// [customData] Custom data to send with the rejection.
  /// [needHideInvitationTopSheet] Whether to hide the invitation top sheet after rejection.
  Future<bool> reject({
    String customData = '',
    bool needHideInvitationTopSheet = true,
  }) async {
    ZegoLoggerService.logInfo(
      'refuse call invitation, '
      'customData:$customData, '
      'needHideInvitationTopSheet:$needHideInvitationTopSheet, ',
      tag: 'call-invitation',
      subTag: 'service, invitation',
    );

    if (!private._checkParamValid()) {
      ZegoLoggerService.logInfo(
        'parameter is not valid',
        tag: 'call-invitation',
        subTag: 'service, reject',
      );

      return false;
    }

    if (!private._checkSignalingPlugin()) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag: 'service, reject',
      );

      return false;
    }

    if (private._checkInCall()) {
      return false;
    }

    if (!private._checkInInvitation()) {
      return false;
    }

    ZegoLoggerService.logInfo(
      'invitationData:${private._pageManager?.invitationData}',
      tag: 'call-invitation',
      subTag: 'service, reject',
    );
    return private._rejectInvitation(
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
      needHideInvitationTopSheet: needHideInvitationTopSheet,
    );
  }

  /// Accept an incoming call invitation.
  ///
  /// [customData] Custom data to send with the acceptance.
  Future<bool> accept({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'accept call invitation',
      tag: 'call-invitation',
      subTag: 'service, accept',
    );

    if (!private._checkParamValid()) {
      ZegoLoggerService.logInfo(
        'parameter is not valid',
        tag: 'call-invitation',
        subTag: 'service, accept',
      );

      return false;
    }

    if (!private._checkSignalingPlugin()) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag: 'service, accept',
      );

      return false;
    }

    if (private._checkInCall()) {
      return false;
    }

    if (!private._checkInInvitation()) {
      return false;
    }

    return private._acceptInvitation(
      callID: private._pageManager?.invitationData.callID ?? '',
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
    );
  }

  /// Join an existing call by invitation ID.
  ///
  /// [invitationID] The ID of the invitation to join.
  /// [customData] Custom data to send when joining.
  Future<bool> join({
    required String invitationID,
    String? customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'send call invitation',
      tag: 'call-invitation',
      subTag: 'service, join',
    );

    if (!private._checkParamValid()) {
      ZegoLoggerService.logInfo(
        'parameter is not valid',
        tag: 'call-invitation',
        subTag: 'service, join',
      );

      return false;
    }

    if (!private._checkSignalingPlugin()) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag: 'service, join',
      );

      return false;
    }

    return private._joinInvitation(
      invitationID: invitationID,
      customData: customData,
    );
  }
}
