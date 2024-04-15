part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerAudioVideoImplPrivate {
  final _private = ZegoCallControllerAudioVideoImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerAudioVideoImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerAudioVideoImplPrivateImpl {
  ZegoUIKitPrebuiltCallConfig? config;
  ZegoUIKitPrebuiltCallEvents? events;

  final List<StreamSubscription<dynamic>?> _subscriptions = [];
  final Map<String, VoidCallback> remoteCameraExceptionCallbacks = {};
  final Map<String, VoidCallback> remoteMicrophoneExceptionCallbacks = {};

  final _microphone = ZegoCallControllerAudioVideoMicrophoneImpl();
  final _camera = ZegoCallControllerAudioVideoCameraImpl();
  final _audioOutput = ZegoCallControllerAudioVideoAudioOutputImpl();

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
    required ZegoUIKitPrebuiltCallEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.audioVideo.p',
    );

    this.config = config;
    this.events = events;

    _microphone.private.initByPrebuilt(config: config);
    _camera.private.initByPrebuilt(config: config);
    _audioOutput.private.initByPrebuilt(config: config);

    listenDeviceExceptionOccurred();
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.audioVideo.p',
    );

    config = null;

    _microphone.private.uninitByPrebuilt();
    _camera.private.uninitByPrebuilt();
    _audioOutput.private.uninitByPrebuilt();

    stopListenDeviceExceptionOccurred();

    for (var subscription in _subscriptions) {
      subscription?.cancel();
    }
  }

  void listenDeviceExceptionOccurred() {
    /// local user
    ZegoUIKit()
        .getLocalUser()
        .cameraException
        .addListener(onLocalCameraExceptionOccurred);
    ZegoUIKit()
        .getLocalUser()
        .microphoneException
        .addListener(onLocalMicrophoneExceptionOccurred);

    /// remote users
    ZegoUIKit().getRemoteUsers().forEach((user) {
      user.cameraException.addListener(onLocalCameraExceptionOccurred);
      user.microphoneException.addListener(onLocalMicrophoneExceptionOccurred);
    });
    _subscriptions
      ..add(ZegoUIKit().getUserJoinStream().listen(onUserJoin))
      ..add(ZegoUIKit().getUserLeaveStream().listen(onUserLeave));
  }

  void stopListenDeviceExceptionOccurred() {
    /// local user
    ZegoUIKit()
        .getLocalUser()
        .cameraException
        .removeListener(onLocalCameraExceptionOccurred);
    ZegoUIKit()
        .getLocalUser()
        .microphoneException
        .removeListener(onLocalMicrophoneExceptionOccurred);

    /// remote users
    ZegoUIKit().getRemoteUsers().forEach((user) {
      user.cameraException
          .removeListener(remoteCameraExceptionCallbacks[user.id] ?? () {});
      user.microphoneException
          .removeListener(remoteMicrophoneExceptionCallbacks[user.id] ?? () {});
    });
    remoteCameraExceptionCallbacks.clear();
    remoteMicrophoneExceptionCallbacks.clear();
  }

  void onUserJoin(List<ZegoUIKitUser> users) {
    for (var user in users) {
      cameraCallback() {
        events?.audioVideo?.onRemoteCameraExceptionOccurred?.call(
          user,
          user.cameraException.value,
        );
      }

      user.cameraException.addListener(cameraCallback);
      remoteCameraExceptionCallbacks[user.id] = cameraCallback;

      microphoneCallback() {
        events?.audioVideo?.onRemoteMicrophoneExceptionOccurred?.call(
          user,
          user.microphoneException.value,
        );
      }

      user.microphoneException.addListener(microphoneCallback);
      remoteMicrophoneExceptionCallbacks[user.id] = microphoneCallback;
    }
  }

  void onUserLeave(List<ZegoUIKitUser> users) {
    for (var user in users) {
      user.cameraException
          .removeListener(remoteMicrophoneExceptionCallbacks[user.id] ?? () {});
      user.microphoneException
          .removeListener(remoteCameraExceptionCallbacks[user.id] ?? () {});

      remoteCameraExceptionCallbacks.remove(user.id);
      remoteMicrophoneExceptionCallbacks.remove(user.id);
    }
  }

  void onLocalCameraExceptionOccurred() {
    events?.audioVideo?.onLocalCameraExceptionOccurred?.call(
      ZegoUIKit().getLocalUser().cameraException.value,
    );
  }

  void onLocalMicrophoneExceptionOccurred() {
    events?.audioVideo?.onLocalMicrophoneExceptionOccurred?.call(
      ZegoUIKit().getLocalUser().microphoneException.value,
    );
  }
}

/// @nodoc
mixin ZegoCallControllerAudioVideoDeviceImplPrivate {
  final _private = ZegoCallControllerAudioVideoImplDevicePrivateImpl();

  /// Don't call that
  ZegoCallControllerAudioVideoImplDevicePrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerAudioVideoImplDevicePrivateImpl {
  ZegoUIKitPrebuiltCallConfig? config;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.audioVideo.p',
    );

    this.config = config;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltLiveAudioRoom.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.audioVideo.p',
    );

    config = null;
  }
}
