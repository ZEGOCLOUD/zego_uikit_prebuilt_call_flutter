import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';

/// During a calling, configuration items that may change for the caller/callee
/// need to be refresh the [ZegoUIKitPrebuiltCallConfig] when entering [ZegoUIKitPrebuiltCall],
///
/// Variables meaning are all same as [ZegoUIKitPrebuiltCallConfig]
class ZegoUIKitPrebuiltCallingConfig {
  /// Whether to open the camera when joining the call.
  ///
  /// If you want to join the call with your camera closed, set this value to false;
  /// if you want to join the call with your camera open, set this value to true.
  /// The default value is `true`.
  bool? turnOnCameraWhenJoining;

  /// Whether to use the front camera when joining the call.
  ///
  /// The default value is `true`.
  bool? useFrontCameraWhenJoining;

  /// Whether to open the microphone when joining the call.
  ///
  /// If you want to join the call with your microphone closed, set this value to false;
  /// if you want to join the call with your microphone open, set this value to true.
  /// The default value is `true`.
  bool? turnOnMicrophoneWhenJoining;

  /// Whether to use the speaker to play audio when joining the call.
  /// The default value is `false`, but it will be set to `true` if the user is in a group call or video call.
  /// If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.
  bool? useSpeakerWhenJoining;

  void sync(
    ZegoUIKitPrebuiltCallConfig config,
    ZegoCallInvitationInviterUIConfig? inviter,
    ZegoCallInvitationInviteeUIConfig? invitee, {
    required bool localUserIsInviter,
  }) {
    config.turnOnCameraWhenJoining = turnOnCameraWhenJoining ??
        (localUserIsInviter
            ? inviter?.defaultCameraOn
            : invitee?.defaultCameraOn) ??
        config.turnOnCameraWhenJoining;
    config.useFrontCameraWhenJoining =
        useFrontCameraWhenJoining ?? config.useFrontCameraWhenJoining;

    config.turnOnMicrophoneWhenJoining = turnOnMicrophoneWhenJoining ??
        (localUserIsInviter
            ? inviter?.defaultMicrophoneOn
            : invitee?.defaultMicrophoneOn) ??
        config.turnOnMicrophoneWhenJoining;

    config.useSpeakerWhenJoining =
        useSpeakerWhenJoining ?? config.useSpeakerWhenJoining;
  }

  void reset() {
    turnOnCameraWhenJoining = null;
    useFrontCameraWhenJoining = null;

    turnOnMicrophoneWhenJoining = null;

    useSpeakerWhenJoining = null;
  }
}
