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

  /// microphone state of [userID]
  bool state(String userID) => ZegoUIKit()
      .getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID)
      .value;

  /// microphone state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID);

  /// turn on/off [userID] microphone, if [userID] is empty, then it refers to local user
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

  /// switch [userID] microphone state, if [userID] is empty, then it refers to local user
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

  /// camera state of [userID]
  bool state(String userID) => ZegoUIKit()
      .getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID)
      .value;

  /// camera state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getCameraStateNotifier(
          targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
          userID);

  /// turn on/off [userID] camera, if [userID] is empty, then it refers to local user
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

  /// switch [userID] camera state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentCameraState = ZegoUIKit()
        .getCameraStateNotifier(
            targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
            targetUserID)
        .value;

    turnOn(!currentCameraState, userID: targetUserID);
  }

  /// local use front facing camera or back
  void switchFrontFacing(bool isFrontFacing) {
    ZegoLoggerService.logInfo(
      'switchFrontFacing, isFrontFacing:$isFrontFacing, ',
      tag: 'call',
      subTag: 'controller.audioVideo',
    );

    ZegoUIKit().useFrontFacingCamera(isFrontFacing);
  }

  /// switch video mirror mode
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
  /// local audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> get localNotifier =>
      notifier(ZegoUIKit().getLocalUser().id);

  /// get audio output device notifier
  ValueNotifier<ZegoUIKitAudioRoute> notifier(
    String userID,
  ) {
    return ZegoUIKit().getAudioOutputDeviceNotifier(
        targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID, userID);
  }

  /// set audio output to speaker or earpiece(telephone receiver)
  void switchToSpeaker(bool isSpeaker) {
    ZegoLoggerService.logInfo(
      'switchToSpeaker, isSpeaker:$isSpeaker, ',
      tag: 'call',
      subTag: 'controller.audioVideo',
    );

    ZegoUIKit().setAudioOutputToSpeaker(isSpeaker);
  }
}
