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

class ZegoCallControllerAudioVideoMicrophoneImpl
    with ZegoCallControllerAudioVideoDeviceImplPrivate {
  /// microphone state of local user
  bool get localState => ZegoUIKit()
      .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
      .value;

  /// microphone state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id);

  /// microphone state of [userID]
  bool state(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(userID).value;

  /// microphone state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getMicrophoneStateNotifier(userID);

  /// turn on/off [userID] microphone, if [userID] is empty, then it refers to local user
  void turnOn(bool isOn, {String? userID}) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID microphone,",
      tag: 'call',
      subTag: 'controller-audioVideo',
    );

    return ZegoUIKit().turnMicrophoneOn(
      isOn,
      userID: userID,
    );
  }

  /// switch [userID] microphone state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentMicrophoneState =
        ZegoUIKit().getMicrophoneStateNotifier(targetUserID).value;

    turnOn(!currentMicrophoneState, userID: targetUserID);
  }
}

class ZegoCallControllerAudioVideoCameraImpl
    with ZegoCallControllerAudioVideoDeviceImplPrivate {
  /// camera state of local user
  bool get localState =>
      ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id).value;

  /// camera state notifier of local user
  ValueNotifier<bool> get localStateNotifier =>
      ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id);

  /// camera state of [userID]
  bool state(String userID) => ZegoUIKit().getCameraStateNotifier(userID).value;

  /// camera state notifier of [userID]
  ValueNotifier<bool> stateNotifier(String userID) =>
      ZegoUIKit().getCameraStateNotifier(userID);

  /// turn on/off [userID] camera, if [userID] is empty, then it refers to local user
  void turnOn(bool isOn, {String? userID}) {
    ZegoLoggerService.logInfo(
      "turn ${isOn ? "on" : "off"} $userID camera",
      tag: 'call',
      subTag: 'controller-audioVideo',
    );

    return ZegoUIKit().turnCameraOn(
      isOn,
      userID: userID,
    );
  }

  /// switch [userID] camera state, if [userID] is empty, then it refers to local user
  void switchState({String? userID}) {
    final targetUserID = userID ?? ZegoUIKit().getLocalUser().id;
    final currentCameraState =
        ZegoUIKit().getCameraStateNotifier(targetUserID).value;

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
    return ZegoUIKit().getAudioOutputDeviceNotifier(userID);
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
