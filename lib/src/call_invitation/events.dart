// Project imports:
import 'defines.dart';

class ZegoUIKitPrebuiltCallInvitationEvents {
  /// receive this callback when decline button pressed in incoming call
  Function()? onIncomingCallDeclineButtonPressed;

  /// receive this callback when accept button pressed in incoming call
  Function()? onIncomingCallAcceptButtonPressed;

  /// receive this callback when receive a call
  Function(String callID, ZegoCallUser caller, ZegoCallType callType,
      List<ZegoCallUser> callees)? onIncomingCallReceived;

  /// This callback will be triggered when the caller cancels the call invitation.
  Function(String callID, ZegoCallUser caller)? onIncomingCallCanceled;

  /// The callee will receive a notification through this callback when the callee doesn't respond to the call invitation after a timeout duration.
  Function(String callID, ZegoCallUser caller)? onIncomingCallTimeout;

  /// This callback will be triggered when the Cancel button is pressed (the caller cancels the call invitation).
  Function()? onOutgoingCallCancelButtonPressed;

  /// The caller will receive a notification through this callback when the callee accepts the call invitation.
  Function(String callID, ZegoCallUser callee)? onOutgoingCallAccepted;

  /// The caller will receive a notification through this callback when the callee rejects the call invitation (the callee is busy).
  Function(String callID, ZegoCallUser callee)? onOutgoingCallRejectedCauseBusy;

  /// The caller will receive a notification through this callback when the callee declines the call invitation actively.
  Function(String callID, ZegoCallUser callee)? onOutgoingCallDeclined;

  /// The caller will receive a notification through this callback when the call invitation didn't get responses after a timeout duration.
  Function(String callID, List<ZegoCallUser> callees)? onOutgoingCallTimeout;

  ZegoUIKitPrebuiltCallInvitationEvents({
    this.onIncomingCallDeclineButtonPressed,
    this.onIncomingCallAcceptButtonPressed,
    this.onIncomingCallReceived,
    this.onIncomingCallCanceled,
    this.onIncomingCallTimeout,
    this.onOutgoingCallCancelButtonPressed,
    this.onOutgoingCallAccepted,
    this.onOutgoingCallRejectedCauseBusy,
    this.onOutgoingCallDeclined,
    this.onOutgoingCallTimeout,
  });
}
