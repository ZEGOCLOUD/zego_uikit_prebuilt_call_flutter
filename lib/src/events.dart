// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
typedef CallEndCallback = void Function(
  ZegoUIKitCallEndEvent event,

  /// defaultAction to return to the previous page
  VoidCallback defaultAction,
);

/// @nodoc
typedef CallHangUpConfirmationCallback = Future<bool> Function(
  ZegoUIKitCallHangUpConfirmationEvent event,

  /// defaultAction to return to the previous page
  Future<bool> Function() defaultAction,
);

class ZegoUIKitPrebuiltCallEvents {
  ZegoUIKitPrebuiltCallEvents({
    this.onCallEnd,
    this.onHangUpConfirmation,
    this.onError,
    this.user,
    this.room,
    this.audioVideo,
  });

  /// error stream
  Function(ZegoUIKitError)? onError;

  /// This callback is triggered when call end, you can differentiate the
  /// reasons for call end by using the [event.reason], if the call
  /// end reason is due to being kicked, you can determine who initiated the
  /// kick by using the variable [event.kickerUserID].
  ///
  /// The default behavior is to return to the previous page like following:
  /// ``` dart
  /// onCallEnd: (
  ///     ZegoUIKitCallEndEvent event,
  ///     /// defaultAction to return to the previous page
  ///     VoidCallback defaultAction,
  /// ) {
  ///   debugPrint('onCallEnd, do whatever you want');
  ///
  ///   /// you can call this defaultAction to return to the previous page,
  ///   defaultAction.call();
  ///
  ///   /// OR perform the page navigation yourself to return to the previous page.
  ///   /// if (PrebuiltCallMiniOverlayPageState.idle !=
  ///   ///     ZegoUIKitPrebuiltCallController.instance.minimize.state) {
  ///   ///   /// now is minimizing state, not need to navigate, just hide
  ///   ///   ZegoUIKitPrebuiltCallController.instance.minimize.hide();
  ///   /// } else {
  ///   ///   Navigator.of(context).pop();
  ///   /// }
  /// }
  /// ```
  ///
  /// so if you override this callback, you MUST perform the page navigation
  /// yourself to return to the previous page(easy way is call defaultAction.call())!!!
  /// otherwise the user will remain on the current call page !!!!!
  ///
  /// You can perform business-related prompts or other actions in this callback.
  /// For example, you can perform custom logic during the hang-up operation, such as recording log information, stopping recording, etc.
  CallEndCallback? onCallEnd;

  /// Confirmation callback method before hang up the call.
  ///
  /// If you want to perform more complex business logic before exiting the call, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  /// This parameter requires you to provide a callback method that returns an asynchronous result.
  /// If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
  ///
  /// Sample Code:
  ///
  /// ``` dart
  /// onHangUpConfirmation: (
  ///     ZegoUIKitCallHangUpConfirmationEvent event,
  ///     /// defaultAction to return to the previous page
  ///     Future<bool> Function() defaultAction,
  /// ) {
  ///   debugPrint('onHangUpConfirmation, do whatever you want');
  ///
  ///   /// you can call this defaultAction to return to the previous page,
  ///   return defaultAction.call();
  /// }
  /// ```
  CallHangUpConfirmationCallback? onHangUpConfirmation;

  /// events about user
  ZegoUIKitPrebuiltCallUserEvents? user;

  /// events about room
  ZegoUIKitPrebuiltCallRoomEvents? room;

  /// events about audio video
  ZegoUIKitPrebuiltCallAudioVideoEvents? audioVideo;
}

/// events about audio-video
class ZegoUIKitPrebuiltCallAudioVideoEvents {
  /// This callback is triggered when camera state changed
  void Function(bool)? onCameraStateChanged;

  /// This callback is triggered when front camera state changed
  void Function(bool)? onFrontFacingCameraStateChanged;

  /// This callback is triggered when microphone state changed
  void Function(bool)? onMicrophoneStateChanged;

  /// This callback is triggered when audio output device changed
  void Function(ZegoUIKitAudioRoute)? onAudioOutputChanged;

  ZegoUIKitPrebuiltCallAudioVideoEvents({
    this.onCameraStateChanged,
    this.onFrontFacingCameraStateChanged,
    this.onMicrophoneStateChanged,
    this.onAudioOutputChanged,
  });
}

/// events about user
class ZegoUIKitPrebuiltCallUserEvents {
  /// This callback is triggered when user enter
  void Function(ZegoUIKitUser)? onEnter;

  /// This callback is triggered when user leave
  void Function(ZegoUIKitUser)? onLeave;

  ZegoUIKitPrebuiltCallUserEvents({
    this.onEnter,
    this.onLeave,
  });
}

/// events about room
class ZegoUIKitPrebuiltCallRoomEvents {
  void Function(ZegoUIKitRoomState)? onStateChanged;

  ZegoUIKitPrebuiltCallRoomEvents({
    this.onStateChanged,
  });
}

/// The default behavior is to return to the previous page.
///
/// If you override this callback, you must perform the page navigation
/// yourself to return to the previous page!!!
/// otherwise the user will remain on the current call page !!!!!
enum ZegoUIKitCallEndReason {
  /// the call ended due to a local hang-up
  localHangUp,

  /// the call ended when the remote user hung up, leaving only one local user in the call
  remoteHangUp,

  /// the call ended due to being kicked out
  kickOut,
}

class ZegoUIKitCallHangUpConfirmationEvent {
  BuildContext context;

  ZegoUIKitCallHangUpConfirmationEvent({
    required this.context,
  });

  @override
  String toString() {
    return 'ZegoUIKitCallHangUpConfirmationEvent{'
        'context:$context, mounted:${context.mounted}, '
        '}';
  }
}

class ZegoUIKitCallEndEvent {
  /// the user ID of who kick you out
  String? kickerUserID;

  /// end reason
  ZegoUIKitCallEndReason reason;

  /// The [isFromMinimizing] it means that the user left the live streaming
  /// while it was in a minimized state.
  ///
  /// You **can not** return to the previous page while it was **in a minimized state**!!!
  /// just hide the minimize page by [ZegoUIKitPrebuiltCallController().minimize.hide()]
  ///
  /// On the other hand, if the value of the parameter is false, it means
  /// that the user left the live streaming while it was not minimized.
  bool isFromMinimizing;

  ZegoUIKitCallEndEvent({
    required this.reason,
    required this.isFromMinimizing,
    this.kickerUserID,
  });

  @override
  String toString() {
    return 'ZegoUIKitCallEndEvent{'
        'kickerUserID:$kickerUserID,'
        ' reason:$reason, '
        '}';
  }
}
