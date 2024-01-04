part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerInvitation {
  final _invitation = ZegoCallControllerInvitationImpl();

  ZegoCallControllerInvitationImpl get invitation => _invitation;
}

/// Here are the APIs related to invitation.
class ZegoCallControllerInvitationImpl
    with ZegoCallControllerInvitationPrivate {
  /// This function is used to send call invitations to one or more specified users.
  ///
  /// You can provide a list of target users [invitees] and specify whether it is a video call [isVideoCall]. If it is not a video call, it defaults to an audio call.
  /// You can also pass additional custom data [customData] to the invitees.
  /// Additionally, you can specify the call ID [callID]. If not provided, the system will generate one automatically based on certain rules.
  /// If you want to set a ringtone for offline call invitations, set [resourceID] to a value that matches the push resource ID in the ZEGOCLOUD management console.
  /// Note that the [resourceID] setting will only take effect when [notifyWhenAppRunningInBackgroundOrQuit] is true.
  /// You can also set the notification title [notificationTitle] and message [notificationMessage].
  /// If the call times out, the call will automatically hang up after the specified timeout duration [timeoutSeconds] (in seconds).
  ///
  /// Note that this function behaves the same as [ZegoSendCallInvitationButton].
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

  ///  To cancel the invitation for [callees] in a call, you can include your
  ///  cancellation reason using the [customData].
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

  /// To reject the current call invitation, you can use the [customData]
  /// parameter if you need to provide a reason for the rejection to the other party.
  ///
  /// Additionally, the inviting party can receive notifications of the
  /// rejection by listening to [onOutgoingCallRejectedCauseBusy] or
  /// [onOutgoingCallDeclined] when the other party declines the call invitation.
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

    return private._rejectInvitation(
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
    );
  }

  /// To accept the current call invitation, you can use the [customData]
  /// parameter if you need to provide a reason for the acceptance to the other party.
  ///
  /// Additionally, the inviting party can receive notifications by listening
  /// to [onOutgoingCallAccepted] when the other party accepts the call invitation.
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

    return private._acceptInvitation(
      callerID: private._pageManager?.invitationData.inviter?.id ?? '',
      customData: customData,
    );
  }
}
