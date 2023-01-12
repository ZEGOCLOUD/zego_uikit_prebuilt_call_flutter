// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_defines.dart';

class ZegoUIKitPrebuiltCallConfig {
  factory ZegoUIKitPrebuiltCallConfig.groupVideoCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
          isGroup: true, isVideo: true);

  factory ZegoUIKitPrebuiltCallConfig.groupVoiceCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
          isGroup: true, isVideo: false);

  factory ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
          isGroup: false, isVideo: true);

  factory ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall() =>
      ZegoUIKitPrebuiltCallConfigExtension.generate(
          isGroup: false, isVideo: false);

  ZegoUIKitPrebuiltCallConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    ZegoPrebuiltAudioVideoViewConfig? audioVideoViewConfig,
    ZegoTopMenuBarConfig? topMenuBarConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoMemberListConfig? memberListConfig,
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
        memberListConfig = memberListConfig ?? ZegoMemberListConfig() {
    layout ??= ZegoLayout.pictureInPicture();
  }

  /// whether to enable the camera by default, the default value is true
  bool turnOnCameraWhenJoining;

  /// whether to enable the microphone by default, the default value is true
  bool turnOnMicrophoneWhenJoining;

  /// whether to use the speaker by default, the default value is true;
  bool useSpeakerWhenJoining;

  /// configs about audio video view
  ZegoPrebuiltAudioVideoViewConfig audioVideoViewConfig;

  /// configs about top bar
  ZegoTopMenuBarConfig topMenuBarConfig;

  /// configs about bottom menu bar
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// configs about bottom member list
  ZegoMemberListConfig memberListConfig;

  /// layout config
  ZegoLayout? layout;

  /// if you don't want to use the default video layout widget, you can customize it entirely
  Widget Function(BuildContext, List<ZegoUIKitUser> allUsers,
      List<ZegoUIKitUser> audioVideoUsers)? audioVideoContainerBuilder;

  /// customize your user's avatar, default we use userID's first character as avatar
  /// User avatars are generally stored in your server, ZegoUIKitPrebuiltCall does not know each user's avatar, so by default, ZegoUIKitPrebuiltCall will use the first letter of the user name to draw the default user avatar, as shown in the following figure,
  ///
  /// |When the user is not speaking|When the user is speaking|
  /// |--|--|
  /// |<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="10%">|<img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/_default_avatar.jpg" width="10%">|
  ///
  /// If you need to display the real avatar of your user, you can use the avatarBuilder to set the user avatar builder method (set user avatar widget builder), the usage is as follows:
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

  /// alert dialog information of quit
  /// if confirm info is not null, APP will pop alert dialog when you hang up
  ZegoHangUpConfirmDialogInfo? hangUpConfirmDialogInfo;

  /// It is often used to customize the process before exiting the call interface.
  /// The callback will triggered when user click hang up button or use system's return,
  /// If you need to handle custom logic, you can set this callback to handle (such as showAlertDialog to let user determine).
  /// if you return true in the callback, prebuilt page will quit and return to your previous page, otherwise will ignore.
  Future<bool?> Function(BuildContext context)? onHangUpConfirmation;

  /// customize handling after hang up
  VoidCallback? onHangUp;

  /// A callback triggered when you're alone in the room.
  /// you can destroy Prebuilt based on this callback and return to the previous page.
  void Function(BuildContext context)? onOnlySelfInRoom;
}

class ZegoPrebuiltAudioVideoViewConfig {
  /// set video is mirror or not
  bool isVideoMirror;

  /// hide microphone state of audio video view if set false
  bool showMicrophoneStateOnView;

  /// hide camera state of audio video view if set false
  bool showCameraStateOnView;

  /// hide user name of audio video view if set false
  bool showUserNameOnView;

  /// customize your foreground of audio video view, which is the top widget of stack
  /// <br><img src="https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="5%">
  /// you can return any widget, then we will put it on top of audio video view
  ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;

  /// customize your background of audio video view, which is the bottom widget of stack
  ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// video view mode
  /// if set to true, video view will proportional zoom fills the entire View and may be partially cut
  /// if set to false, video view proportional scaling up, there may be black borders
  bool useVideoViewAspectFill;

  /// hide avatar of audio video view if set false
  bool showAvatarInAudioMode;

  /// hide sound level of audio video view if set false
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

class ZegoTopMenuBarConfig {
  ///
  bool isVisible;

  ///
  String title;

  /// if true, top bars will collapse after stand still for 5 seconds
  bool hideAutomatically;

  /// if true, top bars will collapse when clicks on blank spaces
  bool hideByClick;

  /// these buttons will displayed on the menu bar, order by the list
  List<ZegoMenuBarButtonName> buttons;

  /// style
  ZegoMenuBarStyle style;

  /// these buttons will sequentially added to menu bar,
  /// and auto added extra buttons to the pop-up menu
  /// when the limit [maxCount] is exceeded
  List<Widget> extendButtons;

  ZegoTopMenuBarConfig({
    this.isVisible = false,
    this.hideAutomatically = true,
    this.hideByClick = true,
    this.buttons = const [],
    this.style = ZegoMenuBarStyle.light,
    this.extendButtons = const [],
    this.title = "",
  });
}

class ZegoBottomMenuBarConfig {
  /// if true, menu bars will collapse after stand still for 5 seconds
  bool hideAutomatically;

  /// if true, menu bars will collapse when clicks on blank spaces
  bool hideByClick;

  /// these buttons will displayed on the menu bar, order by the list
  List<ZegoMenuBarButtonName> buttons;

  /// limited item count display on menu bar,
  /// if this count is exceeded, More button is displayed
  int maxCount;

  /// style
  ZegoMenuBarStyle style;

  /// these buttons will sequentially added to menu bar,
  /// and auto added extra buttons to the pop-up menu
  /// when the limit [maxCount] is exceeded
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

enum ZegoMenuBarStyle {
  light, // background is transparent
  dark, // background is black
}

class ZegoMemberListConfig {
  /// show microphone state or not
  bool showMicrophoneState;

  /// show camera state or not
  bool showCameraState;

  /// customize your item view of member list
  ZegoMemberListItemBuilder? itemBuilder;

  ZegoMemberListConfig({
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
  });
}

class ZegoHangUpConfirmDialogInfo {
  String title;
  String message;
  String cancelButtonName;
  String confirmButtonName;

  ZegoHangUpConfirmDialogInfo({
    this.title = "Hangup Confirmation",
    this.message = "Do you want to hangup?",
    this.cancelButtonName = "Cancel",
    this.confirmButtonName = "OK",
  });
}

extension ZegoUIKitPrebuiltCallConfigExtension on ZegoUIKitPrebuiltCallConfig {
  static ZegoUIKitPrebuiltCallConfig generate({
    required bool isGroup,
    required bool isVideo,
  }) {
    return ZegoUIKitPrebuiltCallConfig(
        turnOnCameraWhenJoining: isVideo,
        turnOnMicrophoneWhenJoining: true,
        useSpeakerWhenJoining: (!isGroup && !isVideo) ? false : true,
        layout: isGroup ? ZegoLayout.gallery() : ZegoLayout.pictureInPicture(),
        topMenuBarConfig: isGroup
            ? ZegoTopMenuBarConfig(
                isVisible: true,
                style: ZegoMenuBarStyle.dark,
                buttons: [
                  ZegoMenuBarButtonName.showMemberListButton,
                ],
              )
            : ZegoTopMenuBarConfig(isVisible: false, buttons: []),
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
          useVideoViewAspectFill: isGroup ? false : true,
        ),
        memberListConfig: ZegoMemberListConfig(),
        onOnlySelfInRoom:
            isGroup ? null : (context) => Navigator.of(context).pop());
  }
}
