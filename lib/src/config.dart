// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/inner_text.dart';

/// Configuration for initializing the Call
/// This class is used as the [config] parameter for the constructor of [ZegoUIKitPrebuiltCall].
class ZegoUIKitPrebuiltCallConfig {
  /// configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate..
  /// you can set by **video = ZegoUIKitVideoConfig.presetXX()**
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

  ZegoCallHangUpConfirmDialogConfig hangUpConfirmDialog;

  /// Configuration options for voice changer and reverberation effects.
  ZegoCallAudioEffectConfig audioEffect;

  /// Set advanced engine configuration, Used to enable advanced functions.
  /// For details, please consult ZEGO technical support.
  Map<String, String> advanceConfigs;

  /// config about users.
  ZegoCallUserConfig user;

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

  /// Configuration options for modifying all calling page's text content on the UI.
  /// All visible text content on the UI can be modified using this single property.
  ZegoUIKitPrebuiltCallInnerText translationText;

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
    ZegoCallHangUpConfirmDialogConfig? hangUpConfirmDialog,
    ZegoCallUserConfig? userConfig,
    ZegoLayout? layout,
    this.foreground,
    this.background,
    this.avatarBuilder,
    ZegoUIKitPrebuiltCallInnerText? translationText,
    ZegoCallAudioEffectConfig? audioEffect,
  })  : video = videoConfig ?? ZegoUIKitVideoConfig.preset360P(),
        audioVideoView = audioVideoViewConfig ?? ZegoCallAudioVideoViewConfig(),
        topMenuBar = topMenuBarConfig ?? ZegoCallTopMenuBarConfig(),
        bottomMenuBar = bottomMenuBarConfig ?? ZegoCallBottomMenuBarConfig(),
        memberList = memberListConfig ?? ZegoCallMemberListConfig(),
        duration = durationConfig ?? ZegoCallDurationConfig(),
        chatView = chatViewConfig ?? ZegoCallInRoomChatViewConfig(),
        user = userConfig ?? ZegoCallUserConfig(),
        hangUpConfirmDialog =
            hangUpConfirmDialog ?? ZegoCallHangUpConfirmDialogConfig(),
        layout = layout ??
            ZegoLayout.pictureInPicture(
              smallViewPosition: ZegoViewPosition.topRight,
            ),
        translationText = translationText ?? ZegoUIKitPrebuiltCallInnerText(),
        audioEffect = audioEffect ?? ZegoCallAudioEffectConfig();

  @override
  String toString() {
    return 'ZegoUIKitPrebuiltCallConfig:{'
        'video:$video, '
        'audioVideoView:$audioVideoView, '
        'topMenuBar:$topMenuBar, '
        'bottomMenuBar:$bottomMenuBar, '
        'memberList:$memberList, '
        'duration:$duration, '
        'chatView:$chatView, '
        'user:$user, '
        'layout:$layout, '
        'turnOnCameraWhenJoining:$turnOnCameraWhenJoining, '
        'turnOnMicrophoneWhenJoining:$turnOnMicrophoneWhenJoining, '
        'useSpeakerWhenJoining:$useSpeakerWhenJoining, '
        'rootNavigator:$rootNavigator, '
        'advanceConfigs:$advanceConfigs, '
        'foreground:$foreground, '
        'background:$background, '
        'hangUpConfirmDialog:$hangUpConfirmDialog, '
        'avatarBuilder:$avatarBuilder, '
        '}';
  }
}

/// Configuration options for audio/video views.
/// You can use the [ZegoUIKitPrebuiltCallConfig.audioVideoView] property to set the properties inside this class.
/// These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
/// If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
/// If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.
class ZegoCallAudioVideoViewConfig {
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

  /// When inviting in calling, the invited user window will appear on the
  /// invitation side, if you want to hide this view, set it to false.
  /// you can cancel the invitation for this user in this view.
  bool showWaitingCallAcceptAudioVideoView;

  /// When inviting in calling, the invited user window will appear on the invitation side,
  /// and you can customize the foreground at this time.
  ZegoAudioVideoViewForegroundBuilder? waitingCallAcceptForegroundBuilder;

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

  /// Custom audio/video view.
  /// If you don't want to use the default view components, you can pass a custom component through this parameter.
  /// and if return null, will be display the default view
  ZegoCallAudioVideoContainerBuilder? containerBuilder;

  /// Specify the rect of the audio & video container.
  /// If not specified, it defaults to display full.
  Rect Function()? containerRect;

  ZegoCallAudioVideoViewConfig({
    this.isVideoMirror = true,
    this.showMicrophoneStateOnView = true,
    this.showCameraStateOnView = false,
    this.showUserNameOnView = true,
    this.useVideoViewAspectFill = false,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.showWaitingCallAcceptAudioVideoView = true,
    this.foregroundBuilder,
    this.waitingCallAcceptForegroundBuilder,
    this.backgroundBuilder,
    this.containerBuilder,
    this.containerRect,
  });

  @override
  toString() {
    return 'ZegoCallAudioVideoViewConfig:{'
        'containerBuilder:$containerBuilder, '
        'isVideoMirror:$isVideoMirror, '
        'showMicrophoneStateOnView:$showMicrophoneStateOnView, '
        'showCameraStateOnView:$showCameraStateOnView, '
        'showUserNameOnView:$showUserNameOnView, '
        'foregroundBuilder:$foregroundBuilder, '
        'backgroundBuilder:$backgroundBuilder, '
        'useVideoViewAspectFill:$useVideoViewAspectFill, '
        'showAvatarInAudioMode:$showAvatarInAudioMode, '
        'showSoundWavesInAudioMode:$showSoundWavesInAudioMode, '
        '}';
  }
}

/// Configuration options for the top menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltCallConfig.topMenuBar] property to set the properties inside this class.
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
  ZegoCallMenuBarStyle style;

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
    this.style = ZegoCallMenuBarStyle.light,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
  });

  @override
  String toString() {
    return 'ZegoCallTopMenuBarConfig:{'
        'isVisible:$isVisible, '
        'title:$title, '
        'hideAutomatically:$hideAutomatically, '
        'hideByClick:$hideByClick, '
        'buttons:$buttons, '
        'extendButtons:$extendButtons, '
        'style:$style, '
        'padding:$padding, '
        'margin:$margin, '
        'backgroundColor:$backgroundColor, '
        'height:$height, '
        '}';
  }
}

/// Configuration options for the bottom menu bar (toolbar).
/// You can use the [ZegoUIKitPrebuiltCallConfig.bottomMenuBar] property to set the properties inside this class.
class ZegoCallBottomMenuBarConfig {
  /// Whether to display the bottom menu bar.
  bool isVisible;

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
  ZegoCallMenuBarStyle style;

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
    this.isVisible = true,
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
    this.style = ZegoCallMenuBarStyle.light,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.height,
  });

  @override
  String toString() {
    return 'ZegoCallBottomMenuBarConfig:{'
        'hideAutomatically:$hideAutomatically, '
        'hideByClick:$hideByClick, '
        'buttons:$buttons, '
        'extendButtons:$extendButtons, '
        'maxCount:$maxCount, '
        'style:$style, '
        'padding:$padding, '
        'margin:$margin, '
        'backgroundColor:$backgroundColor, '
        'height:$height, '
        '}';
  }
}

/// This enum consists of two style options: light and dark. T
/// he light style represents a light theme with a transparent background,
/// while the dark style represents a dark theme with a black background.
/// You can use these options to set the desired theme style for the menu bar.
enum ZegoCallMenuBarStyle {
  /// Light theme with transparent background
  light,

  /// Dark theme with black background
  dark,
}

/// Configuration for the member list.
/// You can use the [ZegoUIKitPrebuiltCallConfig.memberList] property to set the properties inside this class.
///
/// If you want to use a custom member list item view, you can set the `itemBuilder` property in `ZegoCallMemberListConfig`
/// and pass your custom view's builder function to it.
/// For example, suppose you have implemented a `CustomMemberListItem` component that can render a member list item view based on the user information. You can set it up like this:
///
/// ZegoCallMemberListConfig(
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

  @override
  String toString() {
    return 'ZegoCallMemberListConfig:{'
        'showMicrophoneState:$showMicrophoneState, '
        'showCameraState:$showCameraState, '
        'itemBuilder:$itemBuilder, '
        '}';
  }
}

/// Call timing configuration.
/// You can use the [ZegoUIKitPrebuiltCallConfig.duration] property to set the properties inside this class.
class ZegoCallDurationConfig {
  /// Whether to display call timing.
  bool isVisible;

  /// Call timing callback function, called every second.
  ///
  /// Example: Set to automatically hang up after 5 minutes.
  ///
  /// ``` dart
  /// ..duration.isVisible = true
  /// ..duration.onDurationUpdate = (Duration duration) {
  ///   if (duration.inSeconds >= 5 * 60) {
  ///     callController?.hangUp(context);
  ///   }
  /// }
  /// ```
  void Function(Duration)? onDurationUpdate;

  ZegoCallDurationConfig({
    this.isVisible = true,
    this.onDurationUpdate,
  });

  @override
  String toString() {
    return 'ZegoCallDurationConfig:{'
        'isVisible:$isVisible, '
        'onDurationUpdate:$onDurationUpdate, '
        '}';
  }
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

  @override
  String toString() {
    return 'ZegoCallInRoomChatViewConfig:{'
        'itemBuilder:$itemBuilder, '
        '}';
  }
}

/// Confirmation dialog when hang up the call.
class ZegoCallHangUpConfirmDialogConfig {
  /// dialog information
  /// If not set, clicking the exit button will directly exit the call.
  /// If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
  ZegoCallHangUpConfirmDialogInfo? info;
  TextStyle? titleStyle;
  TextStyle? contentStyle;
  TextStyle? actionTextStyle;
  Brightness? backgroundBrightness;

  ZegoCallHangUpConfirmDialogConfig({
    this.info,
    this.titleStyle,
    this.contentStyle,
    this.actionTextStyle,
    this.backgroundBrightness,
  });

  @override
  String toString() {
    return 'ZegoCallHangUpConfirmDialogConfig:{'
        'info:$info, '
        'titleStyle:$titleStyle, '
        'contentStyle:$contentStyle, '
        'actionTextStyle:$actionTextStyle, '
        'backgroundBrightness:$backgroundBrightness, '
        '}';
  }
}

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
              style: ZegoCallMenuBarStyle.dark,
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
              style: ZegoCallMenuBarStyle.dark,
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
              style: ZegoCallMenuBarStyle.light,
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

/// Configuration options for voice changer, beauty effects and reverberation effects.
///
/// This class is used for the [ZegoUIKitPrebuiltCallConfig.effect] property.
///
/// If you want to replace icons and colors to sheet or slider, some of our widgets also provide modification options.
///
/// Example:
///
/// ```dart
/// ZegoCallAudioEffectConfig(
///   backgroundColor: Colors.black.withOpacity(0.5),
///   backIcon: Icon(Icons.arrow_back),
///   sliderTextBackgroundColor: Colors.black.withOpacity(0.5),
/// );
/// ```
class ZegoCallAudioEffectConfig {
  /// List of voice changer effects.
  /// If you don't want a certain effect, simply remove it from the list.
  List<VoiceChangerType> voiceChangeEffect;

  /// List of revert effects types.
  /// If you don't want a certain effect, simply remove it from the list.
  List<ReverbType> reverbEffect;

  /// the background color of the sheet.
  Color? backgroundColor;

  /// the text style of the head title sheet.
  TextStyle? headerTitleTextStyle;

  /// back button icon on the left side of the title.
  Widget? backIcon;

  /// reset button icon on the right side of the title.
  Widget? resetIcon;

  /// color of the icons in the normal (unselected) state.
  Color? normalIconColor;

  /// color of the icons in the highlighted (selected) state.
  Color? selectedIconColor;

  /// border color of the icons in the normal (unselected) state.
  Color? normalIconBorderColor;

  /// border color of the icons in the highlighted (selected) state.
  Color? selectedIconBorderColor;

  /// text-style of buttons in the highlighted (selected) state.
  TextStyle? selectedTextStyle;

  /// text-style of buttons in the normal (unselected) state.
  TextStyle? normalTextStyle;

  /// the style of the text displayed on the Slider's thumb
  TextStyle? sliderTextStyle;

  /// the background color of the text displayed on the Slider's thumb.
  Color? sliderTextBackgroundColor;

  ///  the color of the track that is active when sliding the Slider.
  Color? sliderActiveTrackColor;

  /// the color of the track that is inactive when sliding the Slider.
  Color? sliderInactiveTrackColor;

  /// the color of the Slider's thumb.
  Color? sliderThumbColor;

  /// the radius of the Slider's thumb.
  double? sliderThumbRadius;

  ZegoCallAudioEffectConfig({
    this.voiceChangeEffect = const [
      VoiceChangerType.littleGirl,
      VoiceChangerType.deep,
      VoiceChangerType.robot,
      VoiceChangerType.ethereal,
      VoiceChangerType.littleBoy,
      VoiceChangerType.female,
      VoiceChangerType.male,
      VoiceChangerType.optimusPrime,
      VoiceChangerType.crystalClear,
      VoiceChangerType.cMajor,
      VoiceChangerType.aMajor,
      VoiceChangerType.harmonicMinor,
    ],
    this.reverbEffect = const [
      ReverbType.ktv,
      ReverbType.hall,
      ReverbType.concert,
      ReverbType.rock,
      ReverbType.smallRoom,
      ReverbType.largeRoom,
      ReverbType.valley,
      ReverbType.recordingStudio,
      ReverbType.basement,
      ReverbType.popular,
      ReverbType.gramophone,
    ],
    this.backgroundColor,
    this.headerTitleTextStyle,
    this.backIcon,
    this.resetIcon,
    this.selectedIconBorderColor,
    this.normalIconBorderColor,
    this.selectedTextStyle,
    this.normalTextStyle,
    this.sliderTextStyle,
    this.sliderTextBackgroundColor,
    this.sliderActiveTrackColor,
    this.sliderInactiveTrackColor,
    this.sliderThumbColor,
    this.sliderThumbRadius,
  });

  ZegoCallAudioEffectConfig.none({
    this.voiceChangeEffect = const [],
    this.reverbEffect = const [],
  });

  bool get isSupportVoiceChange => voiceChangeEffect.isNotEmpty;

  bool get isSupportReverb => reverbEffect.isNotEmpty;
}

class ZegoCallUserConfig {
  ZegoCallUserConfig({
    ZegoCallRequiredUserConfig? requiredUsers,
  }) : requiredUsers = requiredUsers ?? ZegoCallRequiredUserConfig();

  /// necessary user in the call.
  ZegoCallRequiredUserConfig requiredUsers;
}

/// Necessary participants to participate in the call.
///
/// If the participant have not joined after
/// [requiredParticipantCheckTimeoutSeconds] after entering the call,
/// the call will be triggered [ZegoUIKitPrebuiltCallEvents.onCallEnd] with [ZegoCallEndReason.abandoned]
class ZegoCallRequiredUserConfig {
  ZegoCallRequiredUserConfig({
    this.users = const [],
    this.detectSeconds = 5,
    this.detectInDebugMode = false,
    this.enabled = false,
  });

  /// is enable detection or not
  bool enabled;

  /// The time to start the detection, when it arrives, it will start to detect whether all members have entered the call.
  ///
  /// Note that this duration cannot be too short,
  /// otherwise if the remote users enters the call relatively late under poor
  /// network conditions, it will cause current call to be ended.
  int detectSeconds;

  /// Necessary participants to participate in the call.
  ///
  /// If the participant have not joined after [detectSeconds] after entering the call,
  /// the call will be triggered to end by
  /// [ZegoUIKitPrebuiltCallEvents.onCallEnd] with [ZegoCallEndReason.abandoned]
  ///
  /// Usually, you DON'T need to specify.
  /// By default, in the 1v1 call scenario, we will set [users] as the Caller(Inviter) of the cal.
  List<ZegoUIKitUser> users;

  /// Is detection of [participants] enabled in debugging mode?
  ///
  /// Due to hitting breakpoints during debugging, it is easy to cause
  /// timeout issues([checkTimeoutSeconds] is timeout),
  /// which can lead to call exits
  bool detectInDebugMode;

  @override
  String toString() {
    return 'ZegoCallRequiredUserConfig:{'
        'users:$users, '
        'detectSeconds:$detectSeconds, '
        'detectInDebugMode:$detectInDebugMode, '
        '}';
  }
}
