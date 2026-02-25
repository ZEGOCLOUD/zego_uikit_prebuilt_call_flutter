part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerAudioVideo {
  final _audioVideoImpl = ZegoCallControllerAudioVideoImpl();

  ZegoCallControllerAudioVideoImpl get audioVideo => _audioVideoImpl;
}

/// Here are the APIs related to audio video.
class ZegoCallControllerAudioVideoImpl
    with ZegoCallControllerAudioVideoImplPrivate {
  /// microphone series APIs
  ZegoCallControllerAudioVideoMicrophoneImpl get microphone =>
      private._microphone;

  /// camera series APIs
  ZegoCallControllerAudioVideoCameraImpl get camera => private._camera;

  /// audio output series APIs
  ZegoCallControllerAudioVideoAudioOutputImpl get audioOutput =>
      private._audioOutput;
}

/// 麦克风控制器 - 控制麦克风开关和状态查询
class ZegoCallControllerAudioVideoMicrophoneImpl
    with ZegoCallControllerAudioVideoDeviceImplPrivate {
  /// microphone state of local user
  bool get localState => ZegoUIKit()
      .getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          ZegoUIKit().getLocalUser().id)
      .value;

  /// microphone state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          ZegoUIKit().getLocalUser().id);

  /// Get microphone state for a specific user.
  ///
  /// [userID] The ID of the user whose microphone state to retrieve.
  bool state(String userID) => ZegoUIKit()
      .getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID)
      .value;

  /// Get microphone state notifier for a specific user.
  ///
  /// [userID] The ID of the user whose microphone state notifier to retrieve.
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID);

  /// Turn on/off microphone.
  ///
  /// [isOn] Whether to turn the microphone on or off.
  /// [userID] The ID of the user whose microphone to control. If null, controls the local user.
  Future<void> turnOn(bool isOn, {String? userID}) async {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID microphone,",
      tag: 'call',
      subTag: 'controller-audioVideo',
    );

    await ZegoUIKit().turnMicrophoneOn(
      targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
      isOn,
      userID: userID,
    );
  }

  /// Switch microphone state (toggle on/off).
  ///
  /// [userID] The ID of the user whose microphone to switch. If null, switches the local user's microphone.
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentMicrophoneState = ZegoUIKit()
        .getMicrophoneStateNotifier(
            targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
            targetUserID)
        .value;

    turnOn(!currentMicrophoneState, userID: targetUserID);
  }
}

/// 摄像头控制器 - 控制摄像头开关、前后摄像头切换、镜像模式等
class ZegoCallControllerAudioVideoCameraImpl
    with ZegoCallControllerAudioVideoDeviceImplPrivate {
  /// camera state of local user
  bool get localState => ZegoUIKit()
      .getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          ZegoUIKit().getLocalUser().id)
      .value;

  /// camera state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          ZegoUIKit().getLocalUser().id);

  /// Get camera state for a specific user.
  ///
  /// [userID] The ID of the user whose camera state to retrieve.
  bool state(String userID) => ZegoUIKit()
      .getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID)
      .value;

  /// Get camera state notifier for a specific user.
  ///
  /// [userID] The ID of the user whose camera state notifier to retrieve.
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID);

  /// Turn on/off camera.
  ///
  /// [isOn] Whether to turn the camera on or off.
  /// [userID] The ID of the user whose camera to control. If null, controls the local user.
  Future<void> turnOn(bool isOn, {String? userID}) async {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID camera",
      tag: 'call',
      subTag: 'controller-audioVideo',
    );

    await ZegoUIKit().turnCameraOn(
      targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
      isOn,
      userID: userID,
    );
  }

  /// Switch camera state (toggle on/off).
  ///
  /// [userID] The ID of the user whose camera to switch. If null, switches the local user's camera.
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentCameraState = ZegoUIKit()
        .getCameraStateNotifier(
            targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
            targetUserID)
        .value;

    turnOn(!currentCameraState, userID: targetUserID);
  }

  /// Switch between front and back camera.
  ///
  /// [isFrontFacing] Whether to use the front-facing camera.
  void switchFrontFacing(bool isFrontFacing) {
    ZegoLoggerService.logInfo(
      'switchFrontFacing, isFrontFacing:$isFrontFacing, ',
      tag: 'call',
      subTag: 'controller.audioVideo',
    );

    ZegoUIKit().useFrontFacingCamera(isFrontFacing);
  }

  /// Switch video mirror mode.
  ///
  /// [isVideoMirror] Whether to enable video mirroring.
  void switchVideoMirroring(bool isVideoMirror) {
    ZegoLoggerService.logInfo(
      'switchVideoMirroring, isVideoMirror:$isVideoMirror, ',
      tag: 'call',
      subTag: 'controller.audioVideo',
    );

    ZegoUIKit().enableVideoMirroring(isVideoMirror);
  }
}

class ZegoCallControllerAudioVideoAudioOutputImpl
    with ZegoCallControllerAudioVideoDeviceImplPrivate {
  /// Get local audio output device notifier.
  ValueNotifier<ZegoUIKitAudioRoute> get localNotifier =>
      notifier(ZegoUIKit().getLocalUser().id);

  /// Get audio output device notifier for a specific user.
  ///
  /// [userID] The ID of the user whose audio output notifier to retrieve.
  ValueNotifier<ZegoUIKitAudioRoute> notifier(
    String userID,
  ) {
    return ZegoUIKit().getAudioOutputDeviceNotifier(
        targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID, userID);
  }

  /// Switch audio output to speaker or earpiece.
  ///
  /// [isSpeaker] Whether to switch to speaker (true) or earpiece (false).
  void switchToSpeaker(bool isSpeaker) {
    ZegoLoggerService.logInfo(
      'switchToSpeaker, isSpeaker:$isSpeaker, ',
      tag: 'call',
      subTag: 'controller.audioVideo',
    );

    ZegoUIKit().setAudioOutputToSpeaker(isSpeaker);
  }
}
