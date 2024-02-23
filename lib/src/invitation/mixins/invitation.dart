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
      tag: 'call',
      subTag: 'controller.invitation',
    );

    if (!private._checkParamValid()) {
      return false;
    }

    if (!private._checkSignalingPlugin()) {
      return false;
    }

    if (!private._checkInCalling()) {
      return false;
    }

    final currentCallID = callID ??
        'call_${ZegoUIKit().getLocalUser().id}_${DateTime.now().millisecondsSinceEpoch}';
    if (private._pageManager?.callingMachine?.isPagePushed ?? false) {
      return private._waitUntil(() {
        if (null == private._pageManager?.callingMachine) {
          return true;
        }
        return private._pageManager!.callingMachine!.isPagePushed;
      }).then((value) {
        return private._sendInvitation(
          callees: invitees,
          isVideoCall: isVideoCall,
          callID: currentCallID,
          customData: customData,
          resourceID: resourceID,
          timeoutSeconds: timeoutSeconds,
          notificationTitle: notificationTitle,
          notificationMessage: notificationMessage,
        );
      });
    }

    return private._sendInvitation(
      callees: invitees,
      isVideoCall: isVideoCall,
      callID: currentCallID,
      customData: customData,
      resourceID: resourceID,
      timeoutSeconds: timeoutSeconds,
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
    );
  }

  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    ZegoLoggerService.logInfo(
      'cancel call invitation',
      tag: 'call',
      subTag: 'controller.invitation',
    );

    if (!private._checkParamValid()) {
      return false;
    }

    if (!private._checkSignalingPlugin()) {
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
      tag: 'call',
      subTag: 'controller.invitation',
    );

    if (!private._checkParamValid()) {
      return false;
    }

    if (!private._checkSignalingPlugin()) {
      return false;
    }

    if (!private._checkInCalling()) {
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
      tag: 'call',
      subTag: 'controller.invitation',
    );

    if (!private._checkParamValid()) {
      return false;
    }

    if (!private._checkSignalingPlugin()) {
      return false;
    }

    if (!private._checkInCalling()) {
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
