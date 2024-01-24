// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

/// @nodoc
typedef PrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
  ZegoCallInvitationData,
);

class ZegoCallingBackgroundBuilderInfo {
  ZegoCallingBackgroundBuilderInfo({
    required this.inviter,
    required this.invitees,
    required this.callType,
  });

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallType callType;
}

typedef ZegoCallingBackgroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBackgroundBuilderInfo info,
);

class ZegoCallInvitationUIConfig {
  ZegoCallInvitationUIConfig({
    this.callingBackgroundBuilder,
    this.prebuiltWithSafeArea = true,
    this.showDeclineButton = true,
    this.showCancelInvitationButton = true,
  });

  /// does [ZegoUIKitPrebuiltCall] display with SafeArea or not
  bool prebuiltWithSafeArea;

  /// whether to display the reject button, default is true
  bool showDeclineButton;

  /// whether to display the invitation cancel button, default is true
  bool showCancelInvitationButton;

  ///
  ZegoCallingBackgroundBuilder? callingBackgroundBuilder;

  @override
  String toString() {
    return 'ZegoCallInvitationUIConfig:{'
        'showDeclineButton:$showDeclineButton, '
        'showCancelInvitationButton:$showCancelInvitationButton, '
        'callingBackgroundBuilder:$callingBackgroundBuilder, '
        '}';
  }
}

class ZegoCallInvitationNotificationConfig {
  ZegoCallInvitationNotificationConfig({
    this.iOSNotificationConfig,
    this.androidNotificationConfig,
  });

  ZegoIOSNotificationConfig? iOSNotificationConfig;
  ZegoAndroidNotificationConfig? androidNotificationConfig;

  @override
  String toString() {
    return 'ZegoCallInvitationNotificationConfig:{'
        'androidNotificationConfig:$androidNotificationConfig, '
        'iOSNotificationConfig:$iOSNotificationConfig, '
        '}';
  }
}

/// ringtone config
class ZegoRingtoneConfig {
  final String? packageName;
  final String? incomingCallPath;
  final String? outgoingCallPath;

  const ZegoRingtoneConfig({
    this.packageName,
    this.incomingCallPath,
    this.outgoingCallPath,
  });

  @override
  String toString() {
    return 'ZegoRingtoneConfig:{'
        'packageName:$packageName, '
        'incomingCallPath:$incomingCallPath, '
        'outgoingCallPath:$outgoingCallPath, '
        '}';
  }
}

/// Call Type
enum ZegoCallType {
  voiceCall,
  videoCall,
}

/// @nodoc
@Deprecated('Use [ZegoCallType]')
typedef ZegoInvitationType = ZegoCallType;

/// @nodoc
extension ZegoCallTypeExtension on ZegoCallType {
  static bool isCallType(int type) {
    return type == ZegoCallType.voiceCall.value ||
        type == ZegoCallType.videoCall.value;
  }

  static const valueMap = {
    ZegoCallType.voiceCall: 0,
    ZegoCallType.videoCall: 1,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoCallType> mapValue = {
    0: ZegoCallType.voiceCall,
    1: ZegoCallType.videoCall,
  };
}

/// @nodoc
class ZegoCallInvitationData {
  String callID = '';
  String invitationID = ''; //zim call id
  ZegoCallType type = ZegoCallType.voiceCall;
  List<ZegoUIKitUser> invitees = [];
  ZegoUIKitUser? inviter;
  String customData = '';

  ZegoCallInvitationData.empty();

  @override
  String toString() {
    return 'callID: $callID, '
        'invitationID: $invitationID, '
        'type: $type, '
        'invitees: ${invitees.map((invitee) => invitee.toString())}, '
        'inviter: $inviter, '
        'customData: $customData.';
  }
}

/// User In Call
class ZegoCallUser {
  String id;
  String name;

  ZegoCallUser(this.id, this.name);

  @override
  String toString() {
    return '{id:$id, name:$name}';
  }
}

/// iOS notification config
class ZegoIOSNotificationConfig {
  String appName;

  /// is iOS sandbox or not
  bool? isSandboxEnvironment;

  ///
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
  ///   iOSNotificationConfig: ZegoIOSNotificationConfig(
  ///     systemCallingIconName: 'CallKitIcon',
  ///   ),
  String systemCallingIconName;

  ZegoIOSNotificationConfig({
    this.appName = '',
    this.certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    this.isSandboxEnvironment,
    this.systemCallingIconName = '',
  });

  @override
  String toString() {
    return 'ZegoIOSNotificationConfig:{'
        'appName:$appName, '
        'certificateIndex:$certificateIndex, '
        'isSandboxEnvironment:$isSandboxEnvironment, '
        'systemCallingIconName:$systemCallingIconName, '
        '}';
  }
}

/// android notification config
class ZegoAndroidNotificationConfig {
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

  ZegoAndroidNotificationConfig({
    this.channelID = 'CallInvitation',
    this.channelName = 'Call Invitation',
    this.icon = '',
    this.sound = '',
    this.vibrate = true,
    this.messageVibrate = false,
    this.callIDVisibility = true,
    this.messageChannelID = 'Message',
    this.messageChannelName = 'Message',
    this.messageIcon = '',
    this.messageSound = '',
  });

  @override
  toString() {
    return 'ZegoAndroidNotificationConfig:{'
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
        '}';
  }
}
