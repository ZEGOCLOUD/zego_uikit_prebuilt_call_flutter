part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServiceAPI {
  final _invitation = ZegoCallInvitationServiceAPIImpl();
}

/// Here are the APIs related to invitation.
class ZegoCallInvitationServiceAPIImpl
    with ZegoCallInvitationServiceAPIPrivate {
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
      return private._checkInCalling()
          ? private._addInvitation(
              callees: invitees,
              isVideoCall: isVideoCall,
              callID: callID,
              invitationID: ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .currentCallInvitationData
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
        subTag: 'service, invitation',
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

  Future<bool> reject({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'reject call invitation',
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

    if (private._checkInCalling()) {
      return false;
    }

    if (!private._checkInInvitation()) {
      return false;
    }

    return private._rejectInvitation(
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
    );
  }

  Future<bool> accept({
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'accept call invitation',
      tag: 'call-invitation',
      subTag: 'service, invitation',
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

    if (private._checkInCalling()) {
      return false;
    }

    if (!private._checkInInvitation()) {
      return false;
    }

    return private._acceptInvitation(
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
    );
  }
}
