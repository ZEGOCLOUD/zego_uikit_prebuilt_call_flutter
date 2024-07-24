// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';

class ZegoCallInvitationConfig {
  ZegoCallInvitationConfig({
    this.canInvitingInCalling = false,
    this.endCallWhenInitiatorLeave = false,
    this.onlyInitiatorCanInvite = false,
    this.permissions = const [
      ZegoCallInvitationPermission.camera,
      ZegoCallInvitationPermission.microphone,
    ],
  });

  /// If you want to a pure audio call with invitation without popping up
  /// camera permission requests, you can remove the camera in [permissions]
  /// and set [ZegoUIKitPrebuiltCallConfig turnOnCameraWhenJoining] to false
  ///
  /// ``` dart
  /// ZegoUIKitPrebuiltCallInvitationService().init(
  ///   ...
  ///   config: ZegoCallInvitationConfig(permissions: [
  ///     ZegoCallInvitationPermission.microphone,
  ///   ]),
  ///   requireConfig: (ZegoCallInvitationData data) {
  ///     ...
  ///     config.turnOnCameraWhenJoining = false;
  ///     ...
  ///   },
  /// );
  /// ```
  List<ZegoCallInvitationPermission> permissions;

  /// whether to allow invitations in calling
  /// Default value is false.
  /// Please note that if allowed, it will be incompatible with versions before v4.12.0, which means mutual invitations cannot be made.
  bool canInvitingInCalling;

  /// whether only the call initiator has the permission to invite others to
  /// join the call.
  /// Default value is false.
  ///
  /// If set to false, all participants in the call can invite others.
  bool onlyInitiatorCanInvite;

  /// whether the entire call should end when the initiator leaves the call
  /// (will causing other participants to leave together).
  /// Default value is false.
  ///
  /// If set to false, the call can continue even after the initiator leaves.
  bool endCallWhenInitiatorLeave;

  @override
  String toString() {
    return 'ZegoCallInvitationConfig:{'
        'permissions:$permissions, '
        'canInvitingInCalling:$canInvitingInCalling, '
        'onlyInitiatorCanInvite:$onlyInitiatorCanInvite, '
        'endCallWhenInitiatorLeave:$endCallWhenInitiatorLeave, '
        '}';
  }
}

class ZegoCallInvitationUIConfig {
  ZegoCallInvitationUIConfig({
    this.prebuiltWithSafeArea = true,
    ZegoCallInvitationInviterUIConfig? inviter,
    ZegoCallInvitationInviteeUIConfig? invitee,
  })  : inviter = inviter ?? ZegoCallInvitationInviterUIConfig(),
        invitee = invitee ?? ZegoCallInvitationInviteeUIConfig();

  /// does [ZegoUIKitPrebuiltCall] display with SafeArea or not
  bool prebuiltWithSafeArea;

  ZegoCallInvitationInviterUIConfig inviter;
  ZegoCallInvitationInviteeUIConfig invitee;

  @override
  String toString() {
    return 'ZegoCallInvitationUIConfig:{'
        'prebuiltWithSafeArea:$prebuiltWithSafeArea, '
        'inviter:$inviter, '
        'invitee:$invitee, '
        '}';
  }
}

class ZegoCallInvitationInviterUIConfig {
  ZegoCallInvitationInviterUIConfig({
    this.foregroundBuilder,
    this.pageBuilder,
    this.backgroundBuilder,
    this.showAvatar = true,
    this.showCentralName = true,
    this.showCallingText = true,
    this.spacingBetweenAvatarAndName,
    this.spacingBetweenNameAndCallingText,
    ZegoCallButtonUIConfig? cancelButton,
  }) : cancelButton = cancelButton ?? ZegoCallButtonUIConfig();

  /// The foreground of the calling.
  ZegoCallingForegroundBuilder? foregroundBuilder;

  /// It will replace the (invitee/inviter)'s call view
  ZegoCallingPageBuilder? pageBuilder;

  /// background builder, default is a image
  ZegoCallingBackgroundBuilder? backgroundBuilder;

  /// cancel button
  ZegoCallButtonUIConfig cancelButton;

  bool showAvatar;
  bool showCentralName;
  bool showCallingText;

  /// spacing between avatar and name
  double? spacingBetweenAvatarAndName;

  /// spacing between name and calling text
  double? spacingBetweenNameAndCallingText;

  @override
  String toString() {
    return 'ZegoCallInvitationInviterUIConfig:{'
        'showAvatar:$showAvatar, '
        'showCentralName:$showCentralName, '
        'showCallingText:$showCallingText, '
        'foregroundBuilder:$foregroundBuilder, '
        'pageBuilder:$pageBuilder, '
        'backgroundBuilder:$backgroundBuilder, '
        'cancelButton:$cancelButton, '
        'spacingBetweenAvatarAndName:$spacingBetweenAvatarAndName, '
        'spacingBetweenNameAndCallingText:$spacingBetweenNameAndCallingText, '
        '}';
  }
}

class ZegoCallInvitationInviteeUIConfig {
  ZegoCallInvitationInviteeUIConfig({
    this.foregroundBuilder,
    this.pageBuilder,
    this.backgroundBuilder,
    this.showAvatar = true,
    this.showCentralName = true,
    this.showCallingText = true,
    this.spacingBetweenAvatarAndName,
    this.spacingBetweenNameAndCallingText,
    ZegoCallButtonUIConfig? declineButton,
    ZegoCallButtonUIConfig? acceptButton,
    ZegoCallInvitationNotifyPopUpUIConfig? popUp,
  })  : declineButton = declineButton ?? ZegoCallButtonUIConfig(),
        acceptButton = acceptButton ?? ZegoCallButtonUIConfig(),
        popUp = popUp ?? ZegoCallInvitationNotifyPopUpUIConfig();

  /// config of call invitation pop-up dialog
  ZegoCallInvitationNotifyPopUpUIConfig popUp;

  /// The foreground of the calling.
  ZegoCallingForegroundBuilder? foregroundBuilder;

  /// It will replace the (invitee/inviter)'s call view
  ZegoCallingPageBuilder? pageBuilder;

  /// background builder, default is a image
  ZegoCallingBackgroundBuilder? backgroundBuilder;

  /// decline button
  ZegoCallButtonUIConfig declineButton;

  /// accept button
  ZegoCallButtonUIConfig acceptButton;

  bool showAvatar;
  bool showCentralName;
  bool showCallingText;

  /// spacing between avatar and name
  double? spacingBetweenAvatarAndName;

  /// spacing between name and calling text
  double? spacingBetweenNameAndCallingText;

  @override
  String toString() {
    return 'ZegoCallInvitationInviteeUIConfig:{'
        'showAvatar:$showAvatar, '
        'showCentralName:$showCentralName, '
        'showCallingText:$showCallingText, '
        'foregroundBuilder:$foregroundBuilder, '
        'pageBuilder:$pageBuilder, '
        'backgroundBuilder:$backgroundBuilder, '
        'popUp:$popUp, '
        'acceptButton:$acceptButton, '
        'declineButton:$declineButton, '
        'spacingBetweenAvatarAndName:$spacingBetweenAvatarAndName, '
        'spacingBetweenNameAndCallingText:$spacingBetweenNameAndCallingText, '
        '}';
  }
}

class ZegoCallInvitationNotificationConfig {
  ZegoCallInvitationNotificationConfig({
    this.iOSNotificationConfig,
    this.androidNotificationConfig,
  });

  ZegoCallIOSNotificationConfig? iOSNotificationConfig;
  ZegoCallAndroidNotificationConfig? androidNotificationConfig;

  @override
  String toString() {
    return 'ZegoCallInvitationNotificationConfig:{'
        'androidNotificationConfig:$androidNotificationConfig, '
        'iOSNotificationConfig:$iOSNotificationConfig, '
        '}';
  }
}

/// online call ringtone config
/// Note that it only works for online calls. If it is offline, please configure it in the zego console
class ZegoCallRingtoneConfig {
  /// callee ringtone on local side, please note that the resource needs to be configured in your flutter project
  /// example: "assets/ringtone/incomingCallRingtone.mp3"
  String? incomingCallPath;

  /// caller ringtone on local side, please note that the resource needs to be configured in your flutter project
  /// example: "assets/ringtone/outgoingCallRingtone.mp3"
  String? outgoingCallPath;

  ZegoCallRingtoneConfig({
    this.incomingCallPath,
    this.outgoingCallPath,
  });

  @override
  String toString() {
    return 'ZegoCallRingtoneConfig:{'
        'incomingCallPath:$incomingCallPath, '
        'outgoingCallPath:$outgoingCallPath, '
        '}';
  }
}

/// iOS notification config
class ZegoCallIOSNotificationConfig {
  String appName;

  /// is iOS sandbox or not. default is null which is auto mode.
  bool? isSandboxEnvironment;

  /// Corresponding certificate index configured by zego console
  ZegoSignalingPluginMultiCertificate certificateIndex;

  /// Customizing the icon for the iOS CallKit lock screen interface
  ///
  /// Below, we will using the example of setting a CallKitIcon icon, to
  /// explain how to set the icon for the CallKit lock screen interface on iOS system .
  ///
  /// Place your icon file in the ios/Runner/Assets.xcassets/ folder, with the file name CallKitIcon.imageset.
  /// When calling ZegoUIKitPrebuiltCallInvitationService.init,
  /// configure the [iOSNotificationConfig.systemCallingIconName] parameter with the file name (without the file extension).
  ///
  /// such as :
  ///   iOSNotificationConfig: ZegoCallIOSNotificationConfig(
  ///     systemCallingIconName: 'CallKitIcon',
  ///   ),
  String systemCallingIconName;

  ZegoCallIOSNotificationConfig({
    this.appName = '',
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    this.isSandboxEnvironment,
    this.systemCallingIconName = '',
  });

  @override
  String toString() {
    return 'ZegoCallIOSNotificationConfig:{'
        'appName:$appName, '
        'certificateIndex:$certificateIndex, '
        'isSandboxEnvironment:$isSandboxEnvironment, '
        'systemCallingIconName:$systemCallingIconName, '
        '}';
  }
}

/// android notification config
class ZegoCallAndroidNotificationConfig {
  /// specify the channel id of notification, which is same in 'Zego Console'
  String channelID;

  /// specify the channel name of notification, which is same in 'Zego Console'
  String channelName;

  /// specify the icon file name id of notification,
  /// Additionally, you must place your icon file in the following path:
  /// ${project_root}/android/app/src/main/res/drawable/${icon}.png
  String? icon;

  /// specify the sound file name id of notification, which is same in 'Zego Console'.
  /// Additionally, you must place your audio file in the following path:
  /// ${project_root}/android/app/src/main/res/raw/${sound}.mp3
  String? sound;

  bool vibrate;

  /// specify the call id show or hide,
  bool callIDVisibility;

  /// only for offline call, displayed in full screen or not when the screen is locked, default value is false.
  ///
  ///  and THE IMPORTANT IS, if set [showFullScreen] on true,
  ///  you need set **android:launchMode="singleInstance"**
  ///  in `manifest/application/activity` node
  ///  of ${project_root}/android/app/src/main/AndroidManifest.xml
  bool showFullScreen;

  /// Corresponding certificate index configured by zego console
  ZegoSignalingPluginMultiCertificate certificateIndex;

  /// If fullScreen is enabled, you can use this parameter to configure the
  /// background image
  /// such as fullScreenBackground: 'assets/image/call.png'
  String? fullScreenBackground;

  /// specify the channel id of message notification, which is same in 'Zego Console'
  String messageChannelID;

  /// specify the channel name of message notification, which is same in 'Zego Console'
  String messageChannelName;

  /// specify the icon file name id of message notification,
  /// Additionally, you must place your icon file in the following path:
  /// ${project_root}/android/app/src/main/res/drawable/${icon}.png
  String? messageIcon;

  /// specify the sound file name id of message notification, which is same in 'Zego Console'.
  /// Additionally, you must place your audio file in the following path:
  /// ${project_root}/android/app/src/main/res/raw/${sound}.mp3
  String? messageSound;

  bool messageVibrate;

  ZegoCallAndroidNotificationConfig({
    this.channelID = 'CallInvitation',
    this.channelName = 'Call Invitation',
    this.icon = '',
    this.sound = '',
    this.vibrate = true,
    this.messageVibrate = false,
    this.callIDVisibility = true,
    this.showFullScreen = false,
    this.messageChannelID = 'Message',
    this.messageChannelName = 'Message',
    this.messageIcon = '',
    this.messageSound = '',
    this.fullScreenBackground = '',
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
  });

  @override
  toString() {
    return 'ZegoCallAndroidNotificationConfig:{'
        'channelID:$channelID, '
        'channelName:$channelName, '
        'icon:$icon, '
        'sound:$sound, '
        'vibrate:$vibrate, '
        'messageVibrate:$messageVibrate, '
        'callIDVisibility:$callIDVisibility, '
        'messageChannelID:$messageChannelID, '
        'messageChannelName:$messageChannelName, '
        'messageIcon:$messageIcon, '
        'messageSound:$messageSound, '
        'certificateIndex:$certificateIndex, '
        'showFullScreen:$showFullScreen, '
        '}';
  }
}
