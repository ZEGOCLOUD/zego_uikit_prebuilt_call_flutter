// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_defines.dart';

class ZegoUIKitPrebuiltCallConfig {
  ZegoUIKitPrebuiltCallConfig({
    this.turnOnCameraWhenJoining = true,
    this.turnOnMicrophoneWhenJoining = true,
    this.useSpeakerWhenJoining = true,
    ZegoAudioVideoViewConfig? audioVideoViewConfig,
    ZegoBottomMenuBarConfig? bottomMenuBarConfig,
    ZegoMemberListConfig? memberListConfig,
    this.layout,
    this.hangUpConfirmDialogInfo,
    this.onHangUpConfirming,
    this.onHangUp,
  })  : audioVideoViewConfig =
            audioVideoViewConfig ?? ZegoAudioVideoViewConfig(),
        bottomMenuBarConfig = bottomMenuBarConfig ?? ZegoBottomMenuBarConfig(),
        memberListConfig = memberListConfig ?? ZegoMemberListConfig() {
    layout ??= ZegoLayout.pictureInPicture(
      showSelfInLargeView: false,
    );
  }

  /// whether to enable the camera by default, the default value is true
  bool turnOnCameraWhenJoining;

  /// whether to enable the microphone by default, the default value is true
  bool turnOnMicrophoneWhenJoining;

  /// whether to use the speaker by default, the default value is true;
  bool useSpeakerWhenJoining;

  /// configs about audio video view
  ZegoAudioVideoViewConfig audioVideoViewConfig;

  Widget? appBar;

  /// configs about bottom menu bar
  ZegoBottomMenuBarConfig bottomMenuBarConfig;

  /// configs about bottom member list
  ZegoMemberListConfig memberListConfig;

  /// layout config
  ZegoLayout? layout;

  /// alert dialog information of quit
  /// if confirm info is not null, APP will pop alert dialog when you hang up
  ZegoHangUpConfirmDialogInfo? hangUpConfirmDialogInfo;

  /// It is often used to customize the process before exiting the call interface.
  /// The callback will triggered when user click hang up button or use system's return,
  /// If you need to handle custom logic, you can set this callback to handle (such as showAlertDialog to let user determine).
  /// if you return true in the callback, prebuilt page will quit and return to your previous page, otherwise will ignore.
  Future<bool?> Function(BuildContext context)? onHangUpConfirming;

  /// customize handling after hang up
  VoidCallback? onHangUp;
}

class ZegoAudioVideoViewConfig {
  /// hide microphone state of audio video view if set false
  bool showMicrophoneStateOnView;

  /// hide camera state of audio video view if set false
  bool showCameraStateOnView;

  /// hide user name of audio video view if set false
  bool showUserNameOnView;

  /// customize your foreground of audio video view, which is the top widget of stack
  /// <br><img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="5%">
  /// you can return any widget, then we will put it on top of audio video view
  AudioVideoViewForegroundBuilder? foregroundBuilder;

  /// customize your background of audio video view, which is the bottom widget of stack
  AudioVideoViewBackgroundBuilder? backgroundBuilder;

  /// video view mode
  /// if set to true, video view will proportional zoom fills the entire View and may be partially cut
  /// if set to false, video view proportional scaling up, there may be black borders
  bool useVideoViewAspectFill;

  /// hide avatar of audio video view if set false
  bool showAvatarInAudioMode;

  /// hide sound level of audio video view if set false
  bool showSoundWavesInAudioMode;

  /// customize your user's avatar, default we use userID's first character as avatar
  /// User avatars are generally stored in your server, ZegoUIkitPrebuiltCall does not know each user's avatar, so by default, ZegoUIkitPrebuiltCall will use the first letter of the user name to draw the default user avatar, as shown in the following figure,
  ///
  /// |When the user is not speaking|When the user is speaking|
  /// |--|--|
  /// |<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar_nowave.jpg" width="10%">|<img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/_default_avatar.jpg" width="10%">|
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
  AudioVideoViewAvatarBuilder? avatarBuilder;

  ZegoAudioVideoViewConfig({
    this.showMicrophoneStateOnView = true,
    this.showCameraStateOnView = true,
    this.showUserNameOnView = true,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.useVideoViewAspectFill = false,
    this.showAvatarInAudioMode = true,
    this.showSoundWavesInAudioMode = true,
    this.avatarBuilder,
  });
}

class ZegoBottomMenuBarConfig {
  /// if true, menu bars will collapse after stand still for 5 seconds
  bool hideMenuBarAutomatically;

  /// if true, menu bars will collapse when clicks on blank spaces
  bool hideMenuBarByClick;

  /// these buttons will displayed on the menu bar, order by the list
  List<ZegoMenuBarButtonName> menuBarButtons;

  /// limited item count display on menu bar,
  /// if this count is exceeded, More button is displayed
  int menuBarButtonsMaxCount;

  /// style
  ZegoMenuBarStyle style;

  /// these buttons will sequentially added to menu bar,
  /// and auto added extra buttons to the pop-up menu
  /// when the limit [menuBarButtonsMaxCount] is exceeded
  List<Widget> menuBarExtendButtons;

  ZegoBottomMenuBarConfig({
    this.hideMenuBarAutomatically = true,
    this.hideMenuBarByClick = true,
    this.menuBarButtons = const [
      ZegoMenuBarButtonName.toggleCameraButton,
      ZegoMenuBarButtonName.toggleMicrophoneButton,
      ZegoMenuBarButtonName.hangUpButton,
      ZegoMenuBarButtonName.switchAudioOutputButton,
      ZegoMenuBarButtonName.switchCameraFacingButton,
    ],
    this.menuBarButtonsMaxCount = 5,
    this.style = ZegoMenuBarStyle.light,
    this.menuBarExtendButtons = const [],
  });
}

enum ZegoMenuBarStyle {
  light, // background is transparent
  dark, // background is black
}

class ZegoMemberListConfig {
  /// show microphone state or not
  bool showMicroPhoneState = true;

  /// show camera state or not
  bool showCameraState = true;

  /// show member list or not
  /// set value to show/hide, and also will be notified when show/hide in prebuilts
  ValueNotifier<bool>? visibilityNotifier;

  /// customize your item view of member list
  MemberListItemBuilder? itemBuilder;

  ZegoMemberListConfig({
    this.visibilityNotifier,
    this.itemBuilder,
  });
}

class ZegoHangUpConfirmDialogInfo {
  String title;
  String message;
  String cancelButtonName;
  String confirmButtonName;

  ZegoHangUpConfirmDialogInfo({
    this.title = "Hangup confirm",
    this.message = "Do you want to hangup?",
    this.cancelButtonName = "Cancel",
    this.confirmButtonName = "Confirm",
  });
}
