// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_overlay_machine.dart';

/// Configuration for initializing the Call
/// This class is used as the [config] parameter for the constructor of [ZegoUIKitPrebuiltCall].
class ZegoUIKitPrebuiltCallConfig {
  /// Default initialization parameters for the group video call.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltCallConfig.groupVideoCall()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  factory ZegoUIKitPrebuiltCallConfig.groupVideoCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
        isGroup: true,
        isVideo: true,
      );

  /// Default initialization parameters for the group voice call.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  factory ZegoUIKitPrebuiltCallConfig.groupVoiceCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
        isGroup: true,
        isVideo: false,
      );

  /// Default initialization parameters for the one-on-one video call.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  factory ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
        isGroup: false,
        isVideo: true,
      );

  /// Default initialization parameters for the one-on-one voice call.
  /// If a configuration item does not meet your expectations, you can directly override its value.
  ///
  /// Example:
  ///
  /// ```dart
  /// ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
  /// ..turnOnMicrophoneWhenJoining = false
  /// ```
  factory ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
        isGroup: false,
        isVideo: false,
      );

  ZegoUIKitPrebuiltCallConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    ZegoPrebuiltAudioVideoViewConfig? audioVideoViewConfig,
    ZegoTopMenuBarConfig? topMenuBarConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoMemberListConfig? memberListConfig,
    ZegoCallDurationConfig? durationConfig,
    this.layout,
    this.hangUpConfirmDialogInfo,
    this.onHangUpConfirmation,
    this.onHangUp,
    this.onOnlySelfInRoom,
    this.avatarBuilder,
    this.audioVideoContainerBuilder,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoPrebuiltAudioVideoViewConfig(),
        topMenuBarConfig = topMenuBarConfig ?? ZegoTopMenuBarConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig(),
        memberListConfig = memberListConfig ?? ZegoMemberListConfig(),
        durationConfig = durationConfig ?? ZegoCallDurationConfig() {
    layout ??= ZegoLayout.pictureInPicture();
  }

  /// Whether to open the camera when joining the call.
  ///
  /// If you want to join the call with your camera closed, set this value to false;
  /// if you want to join the call with your camera open, set this value to true.
  /// The default value is `true`.
  bool turnOnCameraWhenJoining;

  /// Whether to open the microphone when joining the call.
  ///
  /// If you want to join the call with your microphone closed, set this value to false;
  /// if you want to join the call with your microphone open, set this value to true.
  /// The default value is `true`.
  bool turnOnMicrophoneWhenJoining;

  /// Whether to use the speaker to play audio when joining the call.
  /// The default value is `true`.
  /// If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.
  bool useSpeakerWhenJoining;

  /// Configuration options for audio/video views.
  ZegoPrebuiltAudioVideoViewConfig audioVideoViewConfig;

  /// Configuration options for the top menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the top menu bar.
  ZegoTopMenuBarConfig topMenuBarConfig;

  /// Configuration options for the bottom menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the bottom menu bar.
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// Configuration related to the bottom member list, including displaying the member list, member list styles, and more.
  ZegoMemberListConfig memberListConfig;

  /// Layout-related configuration. You can choose your layout here.
  ZegoLayout? layout;

  /// Custom audio/video view.
  /// If you don't want to use the default view components, you can pass a custom component through this parameter.
  Widget Function(BuildContext, List<ZegoUIKitUser> allUsers,
      List<ZegoUIKitUser> audioVideoUsers)? audioVideoContainerBuilder;

  /// Use this to customize the avatar, and replace the default avatar with it.
  ///
  /// Example：
  ///
  /// ```dart
  ///
  ///  // eg:
  ///  avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
  ///    return user != null
  ///        ? Container(
  ///            decoration: BoxDecoration(
  ///              shape: BoxShape.circle,
  ///              image: DecorationImage(
  ///                image: NetworkImage(
  ///                  'https://your_server/app/avatar/${user.id}.png',
  ///                ),
  ///              ),
  ///            ),
  ///          )
  ///        : const SizedBox();
  ///  },
  ///
  /// ```
  ///
  ZegoAvatarBuilder? avatarBuilder;

  /// Confirmation dialog information when hang up the call.
  /// If not set, clicking the exit button will directly exit the call.
  /// If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
  ZegoHangUpConfirmDialogInfo? hangUpConfirmDialogInfo;

  /// Confirmation callback method before hang up the call.
  ///
  /// If you want to perform more complex business logic before exiting the call, such as updating some records to the backend, you can use the [onLeaveConfirmation] parameter to set it.
  /// This parameter requires you to provide a callback method that returns an asynchronous result.
  /// If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
  Future<bool?> Function(BuildContext context)? onHangUpConfirmation;

  /// This callback is triggered after hang up the call.
  /// You can perform business-related prompts or other actions in this callback.
  /// For example, you can perform custom logic during the hang-up operation, such as recording log information, stopping recording, etc.
  VoidCallback? onHangUp;

  /// Callback function triggered when you are alone in the room.
  /// You can use this callback function to destroy the preset page and return to the previous page.
  void Function(BuildContext context)? onOnlySelfInRoom;

  /// Call timing configuration.
  ZegoCallDurationConfig durationConfig;
}

/// Configuration options for audio/video views.
/// You can use the [ZegoUIKitPrebuiltCallConfig].[audioVideoViewConfig] property to set the properties inside this class.
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
/// If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
/// If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.
class ZegoPrebuiltAudioVideoViewConfig {
  /// Whether to mirror the displayed video captured by the camera.
  /// This mirroring effect only applies to the front-facing camera.
  /// Set it to true to enable mirroring, which flips the image horizontally.
  bool isVideoMirror;

  /// Whether to display the microphone status on the audio/video view.
  /// Set it to false if you don't want to show the microphone status on the audio/video view.
  bool showMicrophoneStateOnView;

  /// Whether to display the camera status on the audio/video view.
  /// Set it to false if you don't want to show the camera status on the audio/video view.
  bool showCameraStateOnView;

  /// Whether to display the username on the audio/video view.
  /// Set it to false if you don't want to show the username on the audio/video view.
  bool showUserNameOnView;

  /// You can customize the foreground of the audio/video view, which refers to the widget positioned on top of the view.
  /// You can return any widget, and we will place it at the top of the audio/video view.
  ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// Background for the audio/video windows in a call.
  /// You can use any widget as the background for the audio/video windows. This can be a video, a GIF animation, an image, a web page, or any other widget.
  /// If you need to dynamically change the background content, you should implement the logic for dynamic modification within the widget you return.
  ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// Video view mode.
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  bool useVideoViewAspectFill;

  /// Whether to display user avatars in audio mode.
  /// Set it to false if you don't want to show user avatars in audio mode.
  bool showAvatarInAudioMode;

  /// Whether to display sound waveforms in audio mode.
  /// Set it to false if you don't want to show sound waveforms in audio mode.
  bool showSoundWavesInAudioMode;

  ZegoPrebuiltAudioVideoViewConfig({
    this.isVideoMirror = true,
    this.showMicrophoneStateOnView = true,
    this.showCameraStateOnView = false,
    this.showUserNameOnView = true,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.useVideoViewAspectFill = false,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
  });
}

/// Configuration options for the top menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltCallConfig].[topMenuBarConfig] property to set the properties inside this class.
class ZegoTopMenuBarConfig {
  /// Whether to display the top menu bar.
  bool isVisible;

  /// Title of the top menu bar.
  String title;

  /// Whether to automatically collapse the top menu bar after 5 seconds of inactivity.
  bool hideAutomatically;

  /// Whether to collapse the top menu bar when clicking on the blank area.
  bool hideByClick;

  /// Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
  List<ZegoMenuBarButtonName> buttons;

  /// Style of the top menu bar.
  ZegoMenuBarStyle style;

  /// Extension buttons that allow you to add your own buttons to the top toolbar.
  /// These buttons will be added to the menu bar in the specified order.
  /// If the limit of [3] is exceeded, additional buttons will be automatically added to the overflow menu.
  List<Widget> extendButtons;

  ZegoTopMenuBarConfig({
    this.isVisible = true,
    this.hideAutomatically = true,
    this.hideByClick = true,
    this.buttons = const [],
    this.style = ZegoMenuBarStyle.light,
    this.extendButtons = const [],
    this.title = '',
  });
}

/// Configuration options for the bottom menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltCallConfig].[bottomMenuBarConfig] property to set the properties inside this class.
class ZegoBottomMenuBarConfig {
  /// Whether to automatically collapse the top menu bar after 5 seconds of inactivity.

  bool hideAutomatically;

  /// Whether to collapse the top menu bar when clicking on the blank area.
  bool hideByClick;

  /// Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
  List<ZegoMenuBarButtonName> buttons;

  /// Controls the maximum number of buttons to be displayed in the menu bar (toolbar).
  /// When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
  /// Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).
  int maxCount;

  /// Button style for the bottom menu bar.
  ZegoMenuBarStyle style;

  /// Extension buttons that allow you to add your own buttons to the top toolbar.
  /// These buttons will be added to the menu bar in the specified order.
  /// If the limit of [maxCount] is exceeded, additional buttons will be automatically added to the overflow menu.
  List<Widget> extendButtons;

  ZegoBottomMenuBarConfig({
    this.hideAutomatically = true,
    this.hideByClick = true,
    this.buttons = const [
      ZegoMenuBarButtonName.toggleCameraButton,
      ZegoMenuBarButtonName.toggleMicrophoneButton,
      ZegoMenuBarButtonName.hangUpButton,
      ZegoMenuBarButtonName.switchAudioOutputButton,
      ZegoMenuBarButtonName.switchCameraButton,
    ],
    this.maxCount = 5,
    this.style = ZegoMenuBarStyle.light,
    this.extendButtons = const [],
  });
}

/// This enum consists of two style options: light and dark. T
/// he light style represents a light theme with a transparent background,
/// while the dark style represents a dark theme with a black background.
/// You can use these options to set the desired theme style for the menu bar.
enum ZegoMenuBarStyle {
  /// Light theme with transparent background
  light,

  /// Dark theme with black background
  dark,
}

/// Configuration for the member list.
/// You can use the [ZegoUIKitPrebuiltCallConfig].[memberListConfig] property to set the properties inside this class.
///
/// If you want to use a custom member list item view, you can set the `itemBuilder` property in `ZegoMemberListConfig`
/// and pass your custom view's builder function to it.
/// For example, suppose you have implemented a `CustomMemberListItem` component that can render a member list item view based on the user information. You can set it up like this:
///
/// ZegoMemberListConfig(
///   showMicrophoneState: true,
///   showCameraState: false,
///   itemBuilder: (BuildContext context, Size size, ZegoUIKitUser user, Map<String, dynamic> extraInfo) {
///     return CustomMemberListItem(user: user);
///   },
/// );
///
/// In this example, we set `showMicrophoneState` to true, so the microphone state will be displayed in the member list item.
/// `showCameraState` is set to false, so the camera state will not be displayed.
/// Finally, we pass the builder function of the custom view, `CustomMemberListItem`, to the `itemBuilder` property so that the member list item will be rendered using the custom component.
class ZegoMemberListConfig {
  /// Whether to show the microphone state of the member. Defaults to true, which means it will be shown.
  bool showMicrophoneState;

  /// Whether to show the camera state of the member. Defaults to true, which means it will be shown.
  bool showCameraState;

  /// Custom member list item view.
  ZegoMemberListItemBuilder? itemBuilder;

  ZegoMemberListConfig({
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
  });
}

///  the configuration for the hang-up confirmation dialog
/// You can use the [ZegoUIKitPrebuiltCallConfig].[hangUpConfirmDialogInfo] property to set the properties inside this class.
class ZegoHangUpConfirmDialogInfo {
  /// The title of the dialog
  String title;

  /// The message content of the dialog
  String message;

  /// The text for the cancel button
  String cancelButtonName;

  /// The text for the confirm button
  String confirmButtonName;

  ZegoHangUpConfirmDialogInfo({
    this.title = 'Hangup Confirmation',
    this.message = 'Do you want to hangup?',
    this.cancelButtonName = 'Cancel',
    this.confirmButtonName = 'OK',
  });
}

/// Call timing configuration.
/// You can use the [ZegoUIKitPrebuiltCallConfig].[durationConfig] property to set the properties inside this class.
class ZegoCallDurationConfig {
  /// Whether to display call timing.
  bool isVisible;

  /// Call timing callback function, called every second.
  ///
  /// Example: Set to automatically hang up after 5 minutes.
  /// ..durationConfig.isVisible = true
  /// ..durationConfig.onDurationUpdate = (Duration duration) {
  ///   if (duration.inSeconds >= 5 * 60) {
  ///     callController?.hangUp(context);
  ///   }
  /// }
  void Function(Duration)? onDurationUpdate;

  ZegoCallDurationConfig({
    this.isVisible = true,
    this.onDurationUpdate,
  });
}

/// @nodoc
extension ZegoUIKitPrebuiltCallConfigExtension on ZegoUIKitPrebuiltCallConfig {
  static ZegoUIKitPrebuiltCallConfig generate({
    required bool isGroup,
    required bool isVideo,
  }) {
    return ZegoUIKitPrebuiltCallConfig(
        turnOnCameraWhenJoining: isVideo,
        turnOnMicrophoneWhenJoining: true,
        useSpeakerWhenJoining: isGroup || isVideo,
        layout: isGroup ? ZegoLayout.gallery() : ZegoLayout.pictureInPicture(),
        topMenuBarConfig: isGroup
            ? ZegoTopMenuBarConfig(
                isVisible: true,
                style: ZegoMenuBarStyle.dark,
                buttons: [
                  ZegoMenuBarButtonName.showMemberListButton,
                ],
              )
            : ZegoTopMenuBarConfig(
                isVisible: false,
                buttons: [],
              ),
        bottomMenuBarConfig: isGroup
            ? ZegoBottomMenuBarConfig(
                style: ZegoMenuBarStyle.dark,
                buttons: isVideo
                    ? const [
                        ZegoMenuBarButtonName.toggleCameraButton,
                        ZegoMenuBarButtonName.switchCameraButton,
                        ZegoMenuBarButtonName.hangUpButton,
                        ZegoMenuBarButtonName.toggleMicrophoneButton,
                        ZegoMenuBarButtonName.switchAudioOutputButton,
                      ]
                    : const [
                        ZegoMenuBarButtonName.toggleMicrophoneButton,
                        ZegoMenuBarButtonName.hangUpButton,
                        ZegoMenuBarButtonName.switchAudioOutputButton,
                      ],
              )
            : ZegoBottomMenuBarConfig(
                style: ZegoMenuBarStyle.light,
                buttons: isVideo
                    ? const [
                        ZegoMenuBarButtonName.toggleCameraButton,
                        ZegoMenuBarButtonName.switchCameraButton,
                        ZegoMenuBarButtonName.hangUpButton,
                        ZegoMenuBarButtonName.toggleMicrophoneButton,
                        ZegoMenuBarButtonName.switchAudioOutputButton,
                      ]
                    : const [
                        ZegoMenuBarButtonName.toggleMicrophoneButton,
                        ZegoMenuBarButtonName.hangUpButton,
                        ZegoMenuBarButtonName.switchAudioOutputButton,
                      ],
              ),
        audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
          useVideoViewAspectFill: !isGroup,
        ),
        memberListConfig: ZegoMemberListConfig(),
        onOnlySelfInRoom: isGroup
            ? null
            : (context) {
                if (PrebuiltCallMiniOverlayPageState.idle !=
                    ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
                  ZegoUIKitPrebuiltCallMiniOverlayMachine()
                      .changeState(PrebuiltCallMiniOverlayPageState.idle);
                } else {
                  Navigator.of(context).pop();
                }
              });
  }
}
