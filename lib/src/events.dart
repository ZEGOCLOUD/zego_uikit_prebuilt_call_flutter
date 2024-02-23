// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';

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
  ///     ZegoCallEndEvent event,
  ///     /// defaultAction to return to the previous page
  ///     VoidCallback defaultAction,
  /// ) {
  ///   debugPrint('onCallEnd, do whatever you want');
  ///
  ///   /// you can call this defaultAction to return to the previous page,
  ///   defaultAction.call();
  /// }
  /// ```
  ///
  /// so if you override this callback, you MUST perform the page navigation
  /// yourself to return to the previous page(easy way is call defaultAction.call())!!!
  /// otherwise the user will remain on the current call page !!!!!
  ///
  /// You can perform business-related prompts or other actions in this callback.
  /// For example, you can perform custom logic during the hang-up operation, such as recording log information, stopping recording, etc.
  ZegoCallEndCallback? onCallEnd;

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
  ///     ZegoCallHangUpConfirmationEvent event,
  ///     /// defaultAction to return to the previous page
  ///     Future<bool> Function() defaultAction,
  /// ) {
  ///   debugPrint('onHangUpConfirmation, do whatever you want');
  ///
  ///   /// you can call this defaultAction to return to the previous page,
  ///   return defaultAction.call();
  /// }
  /// ```
  ZegoCallHangUpConfirmationCallback? onHangUpConfirmation;

  /// events about user
  ZegoCallUserEvents? user;

  /// events about room
  ZegoCallRoomEvents? room;

  /// events about audio video
  ZegoCallAudioVideoEvents? audioVideo;

  @override
  String toString() {
    return 'ZegoUIKitPrebuiltCallEvents:{'
        'onCallEnd:$onCallEnd, '
        'onHangUpConfirmation:$onHangUpConfirmation, '
        'onError:$onError, '
        'user:$user, '
        'room:$room, '
        'audioVideo:$audioVideo, '
        '}';
  }
}

/// events about audio-video
class ZegoCallAudioVideoEvents {
  /// This callback is triggered when camera state changed
  void Function(bool)? onCameraStateChanged;

  /// This callback is triggered when front camera state changed
  void Function(bool)? onFrontFacingCameraStateChanged;

  /// This callback is triggered when microphone state changed
  void Function(bool)? onMicrophoneStateChanged;

  /// This callback is triggered when audio output device changed
  void Function(ZegoUIKitAudioRoute)? onAudioOutputChanged;

  ZegoCallAudioVideoEvents({
    this.onCameraStateChanged,
    this.onFrontFacingCameraStateChanged,
    this.onMicrophoneStateChanged,
    this.onAudioOutputChanged,
  });

  @override
  String toString() {
    return 'ZegoCallAudioVideoEvents:{'
        'onCameraStateChanged:$onCameraStateChanged, '
        'onFrontFacingCameraStateChanged:$onFrontFacingCameraStateChanged, '
        'onMicrophoneStateChanged:$onMicrophoneStateChanged, '
        'onAudioOutputChanged:$onAudioOutputChanged, '
        '}';
  }
}

/// events about user
class ZegoCallUserEvents {
  /// This callback is triggered when user enter
  void Function(ZegoUIKitUser)? onEnter;

  /// This callback is triggered when user leave
  void Function(ZegoUIKitUser)? onLeave;

  ZegoCallUserEvents({
    this.onEnter,
    this.onLeave,
  });

  @override
  String toString() {
    return 'ZegoCallUserEvents:{'
        'onEnter:$onEnter, '
        'onLeave:$onLeave, '
        '}';
  }
}

/// events about room
class ZegoCallRoomEvents {
  void Function(ZegoUIKitRoomState)? onStateChanged;

  ZegoCallRoomEvents({
    this.onStateChanged,
  });

  @override
  String toString() {
    return 'ZegoCallRoomEvents:{'
        'onStateChanged:$onStateChanged, '
        '}';
  }
}
