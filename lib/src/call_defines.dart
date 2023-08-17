/// Predefined buttons that can be added to the top or bottom toolbar.
/// By configuring these options, users can customize their own top menu bar or bottom toolbar.
/// This enum type is used in ZegoUIKitPrebuiltCallConfig.bottomMenuBarConfig and ZegoUIKitPrebuiltCallConfig.topMenuBarConfig.
///
/// For example, if you don't want the minimize button, you can exclude the minimizingButton from ZegoBottomMenuBarConfig.buttons.
enum ZegoMenuBarButtonName {
  /// Button for controlling the camera switch.
  toggleCameraButton,

  /// Button for controlling the microphone switch.
  toggleMicrophoneButton,

  /// Button for hanging up the current call.
  hangUpButton,

  /// Button for switching between front and rear cameras.
  switchCameraButton,

  /// Button for switching audio output.
  /// You can switch to the speaker, or to Bluetooth, headphones, and earbuds.
  switchAudioOutputButton,

  /// Button for controlling the visibility of the member list.
  showMemberListButton,

  /// Button for toggling screen sharing.
  toggleScreenSharingButton,

  /// Button for minimizing the current [ZegoUIKitPrebuiltCall] widget within the app.
  /// When clicked, the [ZegoUIKitPrebuiltCall] widget will shrink into a small draggable widget within the app.
  minimizingButton,

  /// Button for controlling the display or hiding of the beauty effect adjustment panel.
  beautyEffectButton,

  /// Button to open/hide the chat UI.
  chatButton,
}

/// Sound wave effect types.
enum SoundWaveType {
  /// Hide the sound wave effect.
  none,

  /// Display sound wave animation around the avatar based on the volume.
  aroundAvatar,
}
