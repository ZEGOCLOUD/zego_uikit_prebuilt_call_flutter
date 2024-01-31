// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'deprecated/deprecated.dart';

/// Configuration for initializing the Call
/// This class is used as the [config] parameter for the constructor of [ZegoUIKitPrebuiltCall].
class ZegoUIKitPrebuiltCallConfig {
  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// you can set by **videoConfig = ZegoUIKitVideoConfig.presetXX()**
  ZegoUIKitVideoConfig video;

  /// Configuration options for audio/video views.
  ZegoCallAudioVideoViewConfig audioVideoView;

  /// Configuration options for the top menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the top menu bar.
  ZegoCallTopMenuBarConfig topMenuBar;

  /// Configuration options for the bottom menu bar (toolbar).
  /// You can use these options to customize the appearance and behavior of the bottom menu bar.
  ZegoCallBottomMenuBarConfig bottomMenuBar;

  /// Configuration related to the bottom member list, including displaying the member list, member list styles, and more.
  ZegoCallMemberListConfig memberList;

  /// advance beauty config
  ZegoBeautyPluginConfig? beauty;

  /// Call timing configuration.
  ZegoCallDurationConfig duration;

  /// Configuration related to the bottom-left message list.
  ZegoCallInRoomChatViewConfig chatView;

  /// Set advanced engine configuration, Used to enable advanced functions.
  /// For details, please consult ZEGO technical support.
  Map<String, String> advanceConfigs;

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
  /// The default value is `false`, but it will be set to `true` if the user is in a group call or video call.
  /// If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.
  bool useSpeakerWhenJoining;

  /// Layout-related configuration. You can choose your layout here.
  ZegoLayout layout;

  /// The foreground of the call.
  ///
  /// If you need to nest some widgets in [ZegoUIKitPrebuiltCall], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltCall]
  Widget? foreground;

  /// The background of the call.
  ///
  /// You can use any Widget as the background of the call, such as a video, a GIF animation, an image, a web page, etc.
  /// If you need to dynamically change the background content, you will need to implement the logic for dynamic modification within the Widget you return.
  ///
  /// ```dart
  ///
  ///  // eg:
  /// ..background = Container(
  ///     width: size.width,
  ///     height: size.height,
  ///     decoration: const BoxDecoration(
  ///       image: DecorationImage(
  ///         fit: BoxFit.fitHeight,
  ///         image: ,
  ///       )));
  /// ```
  Widget? background;

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
  ZegoCallHangUpConfirmDialogInfo? hangUpConfirmDialogInfo;

  /// same as Flutter's Navigator's param
  /// If `rootNavigator` is set to true, the state from the furthest instance of this class is given instead.
  /// Useful for pushing contents above all subsequent instances of [Navigator].
  bool rootNavigator;

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
    this.useSpeakerWhenJoining = false,
    this.rootNavigator = false,
    this.advanceConfigs = const {},
    ZegoUIKitVideoConfig? videoConfig,
    ZegoCallAudioVideoViewConfig? audioVideoViewConfig,
    ZegoCallTopMenuBarConfig? topMenuBarConfig,
    ZegoCallBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoCallMemberListConfig? memberListConfig,
    ZegoCallDurationConfig? durationConfig,
    ZegoCallInRoomChatViewConfig? chatViewConfig,
    ZegoLayout? layout,
    this.foreground,
    this.background,
    this.hangUpConfirmDialogInfo,
    this.avatarBuilder,
    @Deprecated(
        'use audioVideoView.containerBuilder instead$deprecatedTipsV419')
    ZegoCallAudioVideoContainerBuilder? audioVideoContainerBuilder,
  })  : video = videoConfig ?? ZegoUIKitVideoConfig.preset360P(),
        audioVideoView = (audioVideoViewConfig ??
            ZegoCallAudioVideoViewConfig())
          ..containerBuilder = audioVideoContainerBuilder,
        topMenuBar = topMenuBarConfig ?? ZegoCallTopMenuBarConfig(),
        bottomMenuBar = bottomMenuBarConfig ?? ZegoCallBottomMenuBarConfig(),
        memberList = memberListConfig ?? ZegoCallMemberListConfig(),
        duration = durationConfig ?? ZegoCallDurationConfig(),
        chatView = chatViewConfig ?? ZegoCallInRoomChatViewConfig(),
        layout = layout ??
            ZegoLayout.pictureInPicture(
              smallViewPosition: ZegoViewPosition.topRight,
            );
}

/// Configuration options for audio/video views.
/// You can use the [ZegoUIKitPrebuiltCallConfig].[audioVideoView] property to set the properties inside this class.
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
/// If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
/// If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.
class ZegoCallAudioVideoViewConfig {
  /// Custom audio/video view.
  /// If you don't want to use the default view components, you can pass a custom component through this parameter.
  ZegoCallAudioVideoContainerBuilder? containerBuilder;

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

  ZegoCallAudioVideoViewConfig({
    this.containerBuilder,
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
/// You can use the [ZegoUIKitPrebuiltCallConfig].[topMenuBar] property to set the properties inside this class.
class ZegoCallTopMenuBarConfig {
  /// Whether to display the top menu bar.
  bool isVisible;

  /// Title of the top menu bar.
  String title;

  /// Whether to automatically collapse the top menu bar after 5 seconds of inactivity.
  bool hideAutomatically;

  /// Whether to collapse the top menu bar when clicking on the blank area.
  bool hideByClick;

  /// Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
  List<ZegoCallMenuBarButtonName> buttons;

  /// Extension buttons that allow you to add your own buttons to the top toolbar.
  /// These buttons will be added to the menu bar in the specified order.
  /// If the limit of [3] is exceeded, additional buttons will be automatically added to the overflow menu.
  List<Widget> extendButtons;

  /// Style of the top menu bar.
  ZegoMenuBarStyle style;

  /// padding for the top menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the top menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the top menu bar.
  Color? backgroundColor;

  /// height for the top menu bar.
  double? height;

  ZegoCallTopMenuBarConfig({
    this.isVisible = true,
    this.title = '',
    this.hideAutomatically = true,
    this.hideByClick = true,
    this.buttons = const [],
    this.extendButtons = const [],
    this.style = ZegoMenuBarStyle.light,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
  });
}

/// Configuration options for the bottom menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltCallConfig].[bottomMenuBar] property to set the properties inside this class.
class ZegoCallBottomMenuBarConfig {
  /// Whether to automatically collapse the top menu bar after 5 seconds of inactivity.

  bool hideAutomatically;

  /// Whether to collapse the top menu bar when clicking on the blank area.
  bool hideByClick;

  /// Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
  List<ZegoCallMenuBarButtonName> buttons;

  /// Controls the maximum number of buttons to be displayed in the menu bar (toolbar).
  /// When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
  /// Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).
  int maxCount;

  /// Button style for the bottom menu bar.
  ZegoMenuBarStyle style;

  /// padding for the bottom menu bar.
  EdgeInsetsGeometry? padding;

  /// margin for the bottom menu bar.
  EdgeInsetsGeometry? margin;

  /// background color for the bottom menu bar.
  Color? backgroundColor;

  /// height for the bottom menu bar.
  double? height;

  /// Extension buttons that allow you to add your own buttons to the top toolbar.
  /// These buttons will be added to the menu bar in the specified order.
  /// If the limit of [maxCount] is exceeded, additional buttons will be automatically added to the overflow menu.
  List<Widget> extendButtons;

  ZegoCallBottomMenuBarConfig({
    this.hideAutomatically = true,
    this.hideByClick = true,
    this.buttons = const [
      ZegoCallMenuBarButtonName.toggleCameraButton,
      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
      ZegoCallMenuBarButtonName.hangUpButton,
      ZegoCallMenuBarButtonName.switchAudioOutputButton,
      ZegoCallMenuBarButtonName.switchCameraButton,
    ],
    this.extendButtons = const [],
    this.maxCount = 5,
    this.style = ZegoMenuBarStyle.light,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
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
/// You can use the [ZegoUIKitPrebuiltCallConfig].[memberList] property to set the properties inside this class.
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
class ZegoCallMemberListConfig {
  /// Whether to show the microphone state of the member. Defaults to true, which means it will be shown.
  bool showMicrophoneState;

  /// Whether to show the camera state of the member. Defaults to true, which means it will be shown.
  bool showCameraState;

  /// Custom member list item view.
  ZegoMemberListItemBuilder? itemBuilder;

  ZegoCallMemberListConfig({
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
  });
}

/// Call timing configuration.
/// You can use the [ZegoUIKitPrebuiltCallConfig].[duration] property to set the properties inside this class.
class ZegoCallDurationConfig {
  /// Whether to display call timing.
  bool isVisible;

  /// Call timing callback function, called every second.
  ///
  /// Example: Set to automatically hang up after 5 minutes.
  /// ..duration.isVisible = true
  /// ..duration.onDurationUpdate = (Duration duration) {
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

/// Control options for the bottom-left message list.
/// This class is used for the [chatView] property of [ZegoUIKitPrebuiltCallConfig].
///
/// If you want to customize chat messages, you can specify the [itemBuilder] in [ZegoInRoomMessageViewConfig].
///
/// Example:
///
/// ZegoInRoomMessageViewConfig(
///   itemBuilder: (BuildContext context, ZegoRoomMessage message) {
///     return ListTile(
///       title: Text(message.message),
///       subtitle: Text(message.user.id),
///     );
///   },
/// );
class ZegoCallInRoomChatViewConfig {
  /// Use this to customize the style and content of each chat message list item.
  /// For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
  ZegoInRoomMessageItemBuilder? itemBuilder;

  ZegoCallInRoomChatViewConfig({
    this.itemBuilder,
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
      layout: isGroup
          ? ZegoLayout.gallery()
          : ZegoLayout.pictureInPicture(
              smallViewPosition: ZegoViewPosition.topRight,
            ),
      topMenuBarConfig: isGroup
          ? ZegoCallTopMenuBarConfig(
              isVisible: true,
              style: ZegoMenuBarStyle.dark,
              buttons: [
                ZegoCallMenuBarButtonName.showMemberListButton,
              ],
            )
          : ZegoCallTopMenuBarConfig(
              isVisible: false,
              buttons: [],
            ),
      bottomMenuBarConfig: isGroup
          ? ZegoCallBottomMenuBarConfig(
              style: ZegoMenuBarStyle.dark,
              buttons: isVideo
                  ? [
                      ZegoCallMenuBarButtonName.toggleCameraButton,
                      ZegoCallMenuBarButtonName.switchCameraButton,
                      ZegoCallMenuBarButtonName.hangUpButton,
                      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
                      ZegoCallMenuBarButtonName.switchAudioOutputButton,
                    ]
                  : [
                      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
                      ZegoCallMenuBarButtonName.hangUpButton,
                      ZegoCallMenuBarButtonName.switchAudioOutputButton,
                    ],
            )
          : ZegoCallBottomMenuBarConfig(
              style: ZegoMenuBarStyle.light,
              buttons: isVideo
                  ? [
                      ZegoCallMenuBarButtonName.toggleCameraButton,
                      ZegoCallMenuBarButtonName.switchCameraButton,
                      ZegoCallMenuBarButtonName.hangUpButton,
                      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
                      ZegoCallMenuBarButtonName.switchAudioOutputButton,
                    ]
                  : [
                      ZegoCallMenuBarButtonName.toggleMicrophoneButton,
                      ZegoCallMenuBarButtonName.hangUpButton,
                      ZegoCallMenuBarButtonName.switchAudioOutputButton,
                    ],
            ),
      audioVideoViewConfig: ZegoCallAudioVideoViewConfig(
        useVideoViewAspectFill: !isGroup,
      ),
      memberListConfig: ZegoCallMemberListConfig(),
    );
  }
}
