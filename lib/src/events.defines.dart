// Flutter imports:
import 'package:flutter/cupertino.dart';

typedef ZegoCallEndCallback = void Function(
  ZegoCallEndEvent event,

  /// defaultAction to return to the previous page
  VoidCallback defaultAction,
);

typedef ZegoCallHangUpConfirmationCallback = Future<bool> Function(
  ZegoCallHangUpConfirmationEvent event,

  /// defaultAction to return to the previous page
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
}

class ZegoCallEndEvent {
  /// the user ID of who kick you out
  String? kickerUserID;

  /// end reason
  ZegoCallEndReason reason;

  /// The [isFromMinimizing] it means that the user left the live streaming
  /// while it was in a minimized state.
  ///
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// just hide the minimize page by [ZegoUIKitPrebuiltCallController().minimize.hide()]
  ///
  /// On the other hand, if the value of the parameter is false, it means
  /// that the user left the live streaming while it was not minimized.
  bool isFromMinimizing;

  ZegoCallEndEvent({
    required this.reason,
    required this.isFromMinimizing,
    this.kickerUserID,
  });

  @override
  String toString() {
    return 'ZegoCallEndEvent{'
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
