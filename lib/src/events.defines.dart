// Flutter imports:
import 'package:flutter/cupertino.dart';

typedef ZegoCallEndCallback = void Function(
  ZegoCallEndEvent event,

  /// defaultAction to return to the previous page
  VoidCallback defaultAction,
);

typedef ZegoCallHangUpConfirmationCallback = Future<bool> Function(
  ZegoCallHangUpConfirmationEvent event,

  /// defaultAction to **return to the previous page** or **hide the minimize page**
  ///
  /// If you do not execute defaultAction and want to control the end time of the call yourself, then:
  /// when [event.isFromMinimizing] is false, just call **Navigator.pop()** or **ZegoUIKitPrebuiltCallController().hangUp()**to return to the previous page
  /// when [event.isFromMinimizing] is true, just hide the minimize page by call **ZegoUIKitPrebuiltCallController().minimize.hide()**
  Future<bool> Function() defaultAction,
);

/// The default behavior is to return to the previous page.
///
/// If you override this callback, you must perform the page navigation
/// yourself to return to the previous page!!!
/// otherwise the user will remain on the current call page !!!!!
enum ZegoCallEndReason {
  /// the call ended due to a local hang-up
  localHangUp,

  /// the call ended when the remote user hung up, leaving only one local user in the call
  remoteHangUp,

  /// the call ended due to being kicked out
  kickOut,

  /// Due to some reasons, the call is automatically hung up by local
  /// such as [ZegoCallParticipantConfig.requiredParticipants] is not in call
  abandoned,
}

class ZegoCallEndEvent {
  /// current call id
  String callID;

  /// the user ID of who kick you out
  /// same user login if value is empty
  String? kickerUserID;

  /// end reason
  ZegoCallEndReason reason;

  /// The [isFromMinimizing] it means that the user left the call
  /// while it was in a minimized state.
  ///
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// If you do not execute defaultAction, just hide the minimize page by
  /// [ZegoUIKitPrebuiltCallController().minimize.hide()].
  ///
  /// On the other hand, if the value of the parameter is false, it means
  /// that the user left the call while it was not minimized.
  /// If you do not execute defaultAction, you are responsible to return to the previous page.
  /// call [ZegoUIKitPrebuiltCallController().hangUp()] or Navigator.pop().
  bool isFromMinimizing;

  ZegoCallEndEvent({
    required this.callID,
    required this.reason,
    required this.isFromMinimizing,
    this.kickerUserID,
  });

  @override
  String toString() {
    return 'ZegoCallEndEvent{'
        'callID:$callID, '
        'kickerUserID:$kickerUserID,'
        ' reason:$reason, '
        '}';
  }
}

class ZegoCallHangUpConfirmationEvent {
  BuildContext context;

  ZegoCallHangUpConfirmationEvent({
    required this.context,
  });

  @override
  String toString() {
    return 'ZegoCallHangUpConfirmationEvent{'
        'context:$context, mounted:${context.mounted}, '
        '}';
  }
}
