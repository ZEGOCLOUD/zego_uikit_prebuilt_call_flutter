// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/deprecated/deprecated.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

/// Invitation-related event notifications and callbacks.
/// You can listen to events that you are interested in here.
///
/// "incoming" represents an incoming call, indicating that someone is calling you.
/// "outgoing" represents an outgoing call, indicating that you are calling someone else.
class ZegoUIKitPrebuiltCallInvitationEvents {
  /// Error callback for invitation-related errors.
  Function(ZegoUIKitError)? onError;

  /// This callback will be triggered to **caller** or **callee** in current
  /// calling inviting when the other calling member accepts, rejects,
  /// or exits, or the response times out.
  ///
  /// If the user is not the inviter who initiated this call invitation or is not online, the callback will not be received.
  Function(List<ZegoSignalingPluginInvitationUserInfo>)?
      onInvitationUserStateChanged;

  /// This callback will be triggered to **callee** when callee click decline button in incoming call
  Function()? onIncomingCallDeclineButtonPressed;

  /// This callback will be triggered to **callee** when callee click accept button in incoming call
  Function()? onIncomingCallAcceptButtonPressed;

  /// This callback will be triggered to **callee** when callee receive a call
  Function(
    String callID,
    ZegoCallUser caller,
    ZegoCallInvitationType callType,
    List<ZegoCallUser> callees,
    String customData,
  )? onIncomingCallReceived;

  /// This callback will be triggered to **callee** when the caller cancels the call invitation.
  Function(
    String callID,
    ZegoCallUser caller,
    String customData,
  )? onIncomingCallCanceled;

  /// The **callee** will receive a notification through this callback when the callee doesn't respond to the call invitation after a timeout duration.
  /// missed call callback
  Function(String callID, ZegoCallUser caller)? onIncomingCallTimeout;

  /// This callback will be triggered to **callee** when callee click the
  /// missed call notification
  ///
  /// ```dart
  ///  onIncomingMissedCallClicked: (
  ///    String callID,
  ///    ZegoCallUser caller,
  ///    ZegoCallInvitationType callType,
  ///    List<ZegoCallUser> callees,
  ///    String customData,
  ///
  ///    /// defaultAction is redial the missed call
  ///    Future<void> Function() defaultAction,
  ///  ) async {
  ///    /// do some other logic
  ///
  ///    await defaultAction.call();
  ///  },
  /// ```
  Future<void> Function(
    String callID,
    ZegoCallUser caller,
    ZegoCallInvitationType callType,
    List<ZegoCallUser> callees,
    String customData,

    /// defaultAction is redial the missed call
    Future<void> Function() defaultAction,
  )? onIncomingMissedCallClicked;

  /// missed call dial back failed
  Function()? onIncomingMissedCallDialBackFailed;

  /// This callback will be triggered to **caller** when caller send a call
  Function(
    String callID,
    ZegoCallUser caller,
    ZegoCallInvitationType callType,
    List<ZegoCallUser> callees,
    String customData,
  )? onOutgoingCallSent;

  /// This callback will be triggered to **caller** when caller cancels the call invitation by click the cancel button
  Function()? onOutgoingCallCancelButtonPressed;

  /// The **caller** will receive a notification through this callback when the callee accepts the call invitation.
  Function(String callID, ZegoCallUser callee)? onOutgoingCallAccepted;

  /// The **caller** will receive a notification through this callback when the callee rejects the call invitation (the callee is busy).
  Function(
    String callID,
    ZegoCallUser callee,
    String customData,
  )? onOutgoingCallRejectedCauseBusy;

  /// The **caller** will receive a notification through this callback when the callee declines the call invitation actively.
  Function(
    String callID,
    ZegoCallUser callee,
    String customData,
  )? onOutgoingCallDeclined;

  /// The **caller** will receive a notification through this callback when the call invitation didn't get responses after a timeout duration.
  Function(
    String callID,
    List<ZegoCallUser> callees,
    bool isVideoCall,
  )? onOutgoingCallTimeout;

  ZegoUIKitPrebuiltCallInvitationEvents({
    /// Error callback for invitation-related errors.
    this.onError,

    /// Callback triggered when the invitation user state changes.
    this.onInvitationUserStateChanged,

    /// Callback triggered when the callee clicks the decline button for an incoming call.
    this.onIncomingCallDeclineButtonPressed,

    /// Callback triggered when the callee clicks the accept button for an incoming call.
    this.onIncomingCallAcceptButtonPressed,

    /// Callback triggered when an incoming call is received.
    this.onIncomingCallReceived,

    /// Callback triggered when an incoming call is cancelled.
    this.onIncomingCallCanceled,

    /// Callback triggered when an incoming call times out.
    this.onIncomingCallTimeout,

    /// Callback triggered when the callee clicks on a missed call notification.
    this.onIncomingMissedCallClicked,
    @Deprecated(
        'use onIncomingMissedCallDialBackFailed instead$deprecatedTipsV4152')
    Function()? onIncomingMissedCallReCallFailed,

    /// Callback triggered when dialing back a missed call fails.
    this.onIncomingMissedCallDialBackFailed,

    /// Callback triggered when the caller clicks the cancel button for an outgoing call.
    this.onOutgoingCallCancelButtonPressed,

    /// Callback triggered when an outgoing call is sent.
    this.onOutgoingCallSent,

    /// Callback triggered when an outgoing call is accepted.
    this.onOutgoingCallAccepted,

    /// Callback triggered when an outgoing call is rejected because the callee is busy.
    this.onOutgoingCallRejectedCauseBusy,

    /// Callback triggered when an outgoing call is declined.
    this.onOutgoingCallDeclined,

    /// Callback triggered when an outgoing call times out.
    this.onOutgoingCallTimeout,
  }) {
    if (null != onIncomingMissedCallReCallFailed &&
        null == onIncomingMissedCallDialBackFailed) {
      onIncomingMissedCallDialBackFailed = onIncomingMissedCallReCallFailed;
    }
  }
}
