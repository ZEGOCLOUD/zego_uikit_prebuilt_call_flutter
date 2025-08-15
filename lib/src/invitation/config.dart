// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/deprecated/deprecated.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';

class ZegoCallInvitationConfig {
  ZegoCallInvitationConfig({
    this.endCallWhenInitiatorLeave = false,
    this.permissions = const [
      ZegoCallInvitationPermission.camera,
      ZegoCallInvitationPermission.microphone,
    ],
    ZegoCallInvitationInCallingConfig? inCalling,
    ZegoCallInvitationOfflineConfig? offline,
    ZegoCallSystemConfirmDialogConfig? systemWindowConfirmDialog,
    ZegoCallInvitationMissedCallConfig? missedCall,
    ZegoCallInvitationPIPConfig? pip,
    @Deprecated(
        'use inCalling.canInvitingInCalling instead$deprecatedTipsV4150')
    bool canInvitingInCalling = false,
    @Deprecated(
        'use inCalling.onlyInitiatorCanInvite instead$deprecatedTipsV4150')
    bool onlyInitiatorCanInvite = false,
    @Deprecated('use systemWindowConfirmDialog instead$deprecatedTipsV4172')
    ZegoCallSystemConfirmDialogConfig? systemAlertWindowConfirmDialog,
  })  : systemWindowConfirmDialog =
            systemWindowConfirmDialog ?? ZegoCallSystemConfirmDialogConfig(),
        offline = offline ?? ZegoCallInvitationOfflineConfig(),
        inCalling = inCalling ??
            ZegoCallInvitationInCallingConfig(
              canInvitingInCalling: canInvitingInCalling,
              onlyInitiatorCanInvite: onlyInitiatorCanInvite,
            ),
        missedCall = missedCall ?? ZegoCallInvitationMissedCallConfig(),
        pip = pip ?? ZegoCallInvitationPIPConfig();

  /// If you want to a pure audio call with invitation without popping up
  /// camera permission requests, you can remove the camera in [permissions]
  /// and set [ZegoUIKitPrebuiltCallConfig turnOnCameraWhenJoining] to false
  ///
  /// ``` dart
  /// ZegoUIKitPrebuiltCallInvitationService().init(
  ///   ...
  ///   config: ZegoCallInvitationConfig(permissions: ZegoCallInvitationPermissions.audio),
  /// );
  /// ```
  ///
  /// If you want to remove systemAlertWindow request, you can remove it in [permissions]
  ///
  /// ``` dart
  /// ZegoUIKitPrebuiltCallInvitationService().init(
  ///   ...
  ///   config: ZegoCallInvitationConfig(permissions: ZegoCallInvitationPermissions.withoutSystemAlertWindow),
  /// );
  /// ```
  ///
  List<ZegoCallInvitationPermission> permissions;

  /// whether the entire call should end when the initiator leaves the call
  /// 1. will causing other participants to leave together.
  /// 2. other participants can't enter the call anymore
  ///
  /// Default value is false.
  ///
  /// If set to false
  /// 1. the call can continue even after the initiator leaves.
  /// 2. other participants can enter the call after the initiator leaves.
  bool endCallWhenInitiatorLeave;

  /// offline config
  ZegoCallInvitationOfflineConfig offline;

  ///  calling config
  ZegoCallInvitationInCallingConfig inCalling;

  ///  missed call config
  ZegoCallInvitationMissedCallConfig missedCall;

  /// When requests systemAlertWindows in Android, should the confirmation box pop up first?
  /// Default will pop-up a confirmation box. If not, please set it to null.
  ZegoCallSystemConfirmDialogConfig? systemWindowConfirmDialog;

  /// pip
  ZegoCallInvitationPIPConfig pip;

  /// network config
  ZegoNetworkLoadingConfig? networkLoading;

  @override
  String toString() {
    return 'ZegoCallInvitationConfig:{'
        'permissions:$permissions, '
        'calling:$inCalling, '
        'offline:$offline, '
        'missedCall:$missedCall, '
        'systemWindowConfirmDialog:$systemWindowConfirmDialog, '
        'pip:$pip, '
        'endCallWhenInitiatorLeave:$endCallWhenInitiatorLeave, '
        'networkLoading:$networkLoading, '
        '}';
  }
}

class ZegoCallInvitationOfflineConfig {
  ZegoCallInvitationOfflineConfig({
    this.autoEnterAcceptedOfflineCall = true,
  });

  /// Due to some time-consuming and waiting operations, such as data loading
  /// or user login in the App.
  /// so in certain situations, it may not be appropriate to navigate to
  /// [ZegoUIKitPrebuiltCall] directly when [ZegoUIKitPrebuiltCallInvitationService.init].
  ///
  /// This is because the behavior of jumping to ZegoUIKitPrebuiltCall
  /// may be **overwritten by some subsequent jump behaviors of the App**.
  /// Therefore, manually navigate to [ZegoUIKitPrebuiltCall] using the API
  /// in App will be a better choice.
  ///
  /// When you want to do this, set it to **false** (default is true) and then
  /// call [ZegoUIKitPrebuiltCallInvitationService.enterAcceptedOfflineCall]
  bool autoEnterAcceptedOfflineCall;

  @override
  String toString() {
    return 'ZegoCallInvitationOfflineConfig:{'
        'autoEnterAcceptedOfflineCall:$autoEnterAcceptedOfflineCall, '
        '}';
  }
}

class ZegoCallInvitationInCallingConfig {
  ZegoCallInvitationInCallingConfig({
    this.canInvitingInCalling = false,
    this.onlyInitiatorCanInvite = false,
  });

  /// whether to allow invitations in calling
  /// Default value is false.
  /// Please note that if allowed, it will be incompatible with versions before v4.12.0,
  /// which means mutual invitations cannot be made between the old and new versions of zego_uikit_prebuilt_call.
  bool canInvitingInCalling;

  /// whether only the call initiator has the permission to invite others to
  /// join the call.
  /// Default value is false.
  ///
  /// If set to false, all participants in the call can invite others.
  bool onlyInitiatorCanInvite;

  @override
  String toString() {
    return 'ZegoCallInvitationInCallingConfig:{'
        'canInvitingInCalling:$canInvitingInCalling, '
        'onlyInitiatorCanInvite:$onlyInitiatorCanInvite, '
        '}';
  }
}

class ZegoCallInvitationMissedCallConfig {
  ZegoCallInvitationMissedCallConfig({
    this.enabled = false,
    @Deprecated('use enableDialBack instead$deprecatedTipsV4152')
    bool? enableReCall,
    bool? enableDialBack,
    this.resourceID,
    this.notificationTitle,
    this.notificationMessage,
    this.timeoutSeconds = 30,
  }) : enableDialBack = enableDialBack ?? (enableReCall ?? false);

  /// whether to allow popup the missed notification
  /// Default value is true.
  bool enabled;

  /// whether to allow redial the missed when click notification
  /// Default value is false.
  /// Please note that if allowed, it will be incompatible with versions before v4.12.0,
  /// which means mutual invitations cannot be made between the old and new versions of zego_uikit_prebuilt_call.
  bool enableDialBack;

  /// The [resource id] for notification which same as [Zego Console](https://console.zegocloud.com/)
  String? resourceID;

  /// The title for the notification.
  String? Function()? notificationTitle;

  /// The message for the notification.
  String? Function()? notificationMessage;

  /// The timeout duration in seconds for the redial invitation.
  int timeoutSeconds;

  @override
  String toString() {
    return 'ZegoCallInvitationMissedCallConfig:{'
        'enableDialBack:$enableDialBack, '
        'timeoutSeconds:$timeoutSeconds, '
        'resourceID:$resourceID, '
        '}';
  }
}

/// pip config
class ZegoCallInvitationPIPConfig {
  /// ios config
  ZegoCallInvitationPIPIOSConfig iOS;

  ZegoCallInvitationPIPConfig({
    ZegoCallInvitationPIPIOSConfig? iOS,
  }) : iOS = iOS ?? ZegoCallInvitationPIPIOSConfig();
}

/// iOS pip
/// only available on 15.0
class ZegoCallInvitationPIPIOSConfig {
  ZegoCallInvitationPIPIOSConfig({
    this.support = false,
  });

  /// Whether to enable PIP under iOS
  /// After setting, it cannot be modified again within one lifetime of prebuilt
  ///
  /// the value of [support] and [ZegoUIKitPrebuiltCallConfig.pip.iOS.support] must be consistent,
  /// otherwise, the video frame will not be rendered.
  /// ```dart
  /// ZegoUIKitPrebuiltCallConfig.pip.iOS.support = true;
  ///
  /// ZegoUIKitPrebuiltCallInvitationService().init(
  ///    config: ZegoCallInvitationConfig(
  ///      pip: ZegoCallInvitationPIPConfig(
  ///        iOS: ZegoCallInvitationPIPIOSConfig(
  ///          support: true,
  ///        ),
  ///      ),
  ///    ),
  ///  );
  /// ```
  bool support;

  @override
  String toString() {
    return 'ZegoCallInvitationPIPIOSConfig:{'
        'support:$support, '
        '}';
  }
}

class ZegoCallInvitationUIConfig {
  ZegoCallInvitationUIConfig({
    this.withSafeArea = true,
    ZegoCallInvitationInviterUIConfig? inviter,
    ZegoCallInvitationInviteeUIConfig? invitee,
  })  : inviter = inviter ?? ZegoCallInvitationInviterUIConfig(),
        invitee = invitee ?? ZegoCallInvitationInviteeUIConfig();

  /// does invitation widget display with SafeArea or not
  bool withSafeArea;

  ZegoCallInvitationInviterUIConfig inviter;
  ZegoCallInvitationInviteeUIConfig invitee;

  @override
  String toString() {
    return 'ZegoCallInvitationUIConfig:{'
        'withSafeArea:$withSafeArea, '
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
    this.useVideoViewAspectFill = false,
    this.defaultCameraOn = true,
    this.defaultMicrophoneOn = true,
    this.defaultSpeakerOn = false,
    this.showMainButtonsText = false,
    this.showSubButtonsText = true,
    this.spacingBetweenAvatarAndName,
    this.spacingBetweenNameAndCallingText,
    ZegoCallButtonUIConfig? cancelButton,
    ZegoCallButtonUIConfig? cameraButton,
    ZegoCallButtonUIConfig? cameraSwitchButton,
    ZegoCallButtonUIConfig? microphoneButton,
    ZegoCallButtonUIConfig? speakerButton,
  })  : cancelButton = cancelButton ?? ZegoCallButtonUIConfig(),
        cameraButton = cancelButton ?? ZegoCallButtonUIConfig(),
        cameraSwitchButton = cancelButton ?? ZegoCallButtonUIConfig(),
        microphoneButton = cancelButton ?? ZegoCallButtonUIConfig(),
        speakerButton = cancelButton ?? ZegoCallButtonUIConfig();

  /// The foreground of the calling.
  ZegoCallingForegroundBuilder? foregroundBuilder;

  /// It will replace the (invitee/inviter)'s call view
  ZegoCallingPageBuilder? pageBuilder;

  /// background builder, default is a image
  ZegoCallingBackgroundBuilder? backgroundBuilder;

  /// cancel button
  ZegoCallButtonUIConfig cancelButton;

  /// microphone button
  ZegoCallButtonUIConfig? microphoneButton;

  /// Whether to open the microphone when on calling
  /// default value is true
  bool defaultMicrophoneOn;

  /// camera button
  ZegoCallButtonUIConfig? cameraButton;

  /// Whether to open the camera when on calling
  /// default value is true
  bool defaultCameraOn;

  /// camera switch button
  ZegoCallButtonUIConfig? cameraSwitchButton;

  /// speaker button
  ZegoCallButtonUIConfig? speakerButton;

  /// Whether to open the speaker when on calling
  /// default value is false
  bool defaultSpeakerOn;

  /// show avatar or not
  /// default value is true
  bool showAvatar;

  /// show central name or not
  /// default value is true
  bool showCentralName;

  /// show calling text or not
  /// default value is true
  bool showCallingText;

  /// spacing between avatar and name
  double? spacingBetweenAvatarAndName;

  /// spacing between name and calling text
  double? spacingBetweenNameAndCallingText;

  /// Video view mode.
  /// default value is false
  ///
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  bool useVideoViewAspectFill;

  /// show main buttons text or not
  /// default value is false
  ///
  /// main buttons: cancel
  bool showMainButtonsText;

  /// show sub buttons text or not
  /// default value is true
  ///
  /// sub buttons: camera/microphone/camera switch/speaker
  bool showSubButtonsText;

  @override
  String toString() {
    return 'ZegoCallInvitationInviterUIConfig:{'
        'showAvatar:$showAvatar, '
        'showCentralName:$showCentralName, '
        'showCallingText:$showCallingText, '
        'useVideoViewAspectFill:$useVideoViewAspectFill, '
        'foregroundBuilder:$foregroundBuilder, '
        'pageBuilder:$pageBuilder, '
        'backgroundBuilder:$backgroundBuilder, '
        'cancelButton:$cancelButton, '
        'cameraButton:$cameraButton, '
        'cameraSwitchButton:$cameraSwitchButton, '
        'microphoneButton:$microphoneButton, '
        'speakerButton:$speakerButton, '
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
    this.useVideoViewAspectFill = false,
    this.showVideoOnCalling = true,
    this.defaultMicrophoneOn = true,
    this.defaultCameraOn = true,
    this.showMainButtonsText = false,
    this.showSubButtonsText = true,
    this.spacingBetweenAvatarAndName,
    this.spacingBetweenNameAndCallingText,
    ZegoCallButtonUIConfig? declineButton,
    ZegoCallButtonUIConfig? acceptButton,
    ZegoCallButtonUIConfig? cameraButton,
    ZegoCallButtonUIConfig? cameraSwitchButton,
    ZegoCallButtonUIConfig? microphoneButton,
    ZegoCallInvitationNotifyPopUpUIConfig? popUp,
  })  : declineButton = declineButton ?? ZegoCallButtonUIConfig(),
        acceptButton = acceptButton ?? ZegoCallButtonUIConfig(),
        cameraButton = acceptButton ?? ZegoCallButtonUIConfig(),
        cameraSwitchButton = acceptButton ?? ZegoCallButtonUIConfig(),
        microphoneButton = acceptButton ?? ZegoCallButtonUIConfig(),
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

  /// microphone button
  ZegoCallButtonUIConfig? microphoneButton;

  /// Whether to open the microphone when on be called
  /// default value is true
  bool defaultMicrophoneOn;

  /// camera button
  ZegoCallButtonUIConfig? cameraButton;

  /// Whether to open the camera when on be called
  /// default value is true
  bool defaultCameraOn;

  /// camera switch button
  ZegoCallButtonUIConfig? cameraSwitchButton;

  /// show avatar or not
  /// default value is true
  bool showAvatar;

  /// show central name or not
  /// default value is true
  bool showCentralName;

  /// show calling text or not
  /// default value is true
  bool showCallingText;

  /// spacing between avatar and name
  double? spacingBetweenAvatarAndName;

  /// spacing between name and calling text
  double? spacingBetweenNameAndCallingText;

  /// Video view mode.
  /// default value is false
  ///
  /// Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
  /// Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.
  bool useVideoViewAspectFill;

  /// show video or not on a video calling;
  /// default value is true
  bool showVideoOnCalling;

  /// show main buttons text or not
  /// default value is false
  ///
  /// main buttons: accept/decline
  bool showMainButtonsText;

  /// show sub buttons text or not
  /// default value is true
  ///
  /// sub buttons: camera/microphone/camera switch
  bool showSubButtonsText;

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
        'cameraButton:$cameraButton, '
        'cameraSwitchButton:$cameraSwitchButton, '
        'microphoneButton:$microphoneButton, '
        'showVideoOnCalling:$showVideoOnCalling, '
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
  String? fullScreenBackgroundAssetURL;

  /// specify the channel config of call notification
  /// channelID, channelName and sound need be same in 'Zego Console'
  ZegoCallAndroidNotificationChannelConfig callChannel;

  /// specify the channel config of message notification
  /// channelID, channelName and sound need be same in 'Zego Console'
  ZegoCallAndroidNotificationChannelConfig messageChannel;

  /// specify the channel config of missed call notification
  ZegoCallAndroidNotificationChannelConfig missedCallChannel;

  ZegoCallAndroidNotificationConfig({
    this.callIDVisibility = true,
    this.showFullScreen = false,
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    ZegoCallAndroidNotificationChannelConfig? missedCallChannel,

    /// Deprecated
    @Deprecated('use fullScreenBackgroundAssetURL instead$deprecatedTipsV4150')
    String? fullScreenBackground,
    String? fullScreenBackgroundAssetURL,

    /// Deprecated call channel config, please use callChannel
    @Deprecated('use callChannel.channelID instead$deprecatedTipsV4150')
    String channelID = 'call_invitation',
    @Deprecated('use callChannel.channelName instead$deprecatedTipsV4150')
    String channelName = 'Call Invitation',
    @Deprecated('use callChannel.icon instead$deprecatedTipsV4150')
    String? icon = '',
    @Deprecated('use callChannel.sound instead$deprecatedTipsV4150')
    String? sound = '',
    @Deprecated('use callChannel.vibrate instead$deprecatedTipsV4150')
    bool vibrate = true,
    ZegoCallAndroidNotificationChannelConfig? callChannel,

    /// Deprecated message channel config, please use messageChannel
    @Deprecated('use messageChannel.channelID instead$deprecatedTipsV4150')
    String messageChannelID = 'zimkit_message',
    @Deprecated('use messageChannel.channelName instead$deprecatedTipsV4150')
    String messageChannelName = 'Chat Message',
    @Deprecated('use messageChannel.icon instead$deprecatedTipsV4150')
    String? messageIcon = '',
    @Deprecated('use messageChannel.sound instead$deprecatedTipsV4150')
    String? messageSound = '',
    @Deprecated('use messageChannel.vibrate instead$deprecatedTipsV4150')
    bool messageVibrate = false,
    ZegoCallAndroidNotificationChannelConfig? messageChannel,
  })  : fullScreenBackgroundAssetURL =
            fullScreenBackgroundAssetURL ?? fullScreenBackground ?? '',
        callChannel = callChannel ??
            ZegoCallAndroidNotificationChannelConfig(
              channelID: channelID,
              channelName: channelName,
              icon: icon,
              sound: sound,
              vibrate: vibrate,
            ),
        missedCallChannel = missedCallChannel ??
            ZegoCallAndroidNotificationChannelConfig(
              channelID: 'missed_call',
              channelName: 'Missed Call',
              icon: '',
              sound: '',
              vibrate: false,
            ),
        messageChannel = messageChannel ??
            ZegoCallAndroidNotificationChannelConfig(
              channelID: messageChannelID,
              channelName: messageChannelName,
              icon: messageIcon,
              sound: messageSound,
              vibrate: messageVibrate,
            );

  @override
  toString() {
    return 'ZegoCallAndroidNotificationConfig:{'
        'callIDVisibility:$callIDVisibility, '
        'certificateIndex:$certificateIndex, '
        'showFullScreen:$showFullScreen, '
        'call channel config:$callChannel, '
        'missed call channel config:$missedCallChannel, '
        'message channel config:$messageChannel, '
        '}';
  }
}

class ZegoCallAndroidNotificationChannelConfig {
  /// specify the channel id of notification
  String channelID;

  /// specify the channel name of notification
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

  ZegoCallAndroidNotificationChannelConfig({
    this.channelID = 'unknown_channel',
    this.channelName = 'Unknown Channel',
    this.icon = '',
    this.sound = '',
    this.vibrate = true,
  });
  @override
  toString() {
    return 'ZegoCallAndroidNotificationChannelConfig:{'
        'channelID:$channelID, '
        'channelName:$channelName, '
        'icon:$icon, '
        'sound:$sound, '
        'vibrate:$vibrate, '
        '}';
  }
}

/// Confirmation dialog like system.
class ZegoCallSystemConfirmDialogConfig {
  String? title;
  TextStyle? titleStyle;
  TextStyle? contentStyle;
  TextStyle? actionTextStyle;
  Brightness? backgroundBrightness;

  ZegoCallSystemConfirmDialogConfig({
    this.title,
    this.titleStyle,
    this.contentStyle,
    this.actionTextStyle,
    this.backgroundBrightness,
  });

  @override
  String toString() {
    return 'ZegoCallSystemConfirmDialogConfig:{'
        'title:$title, '
        'titleStyle:$titleStyle, '
        'contentStyle:$contentStyle, '
        'actionTextStyle:$actionTextStyle, '
        'backgroundBrightness:$backgroundBrightness, '
        '}';
  }
}
