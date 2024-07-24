// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';

/// @nodoc
typedef ContextQuery = BuildContext Function();

/// @nodoc
class ZegoUIKitPrebuiltCallInvitationData {
  ZegoUIKitPrebuiltCallInvitationData({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.plugins,
    required this.requireConfig,
    this.events,
    this.invitationEvents,
    this.contextQuery,
    ZegoCallInvitationInnerText? innerText,
    ZegoCallRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationConfig? config,
    ZegoCallInvitationNotificationConfig? notificationConfig,
  })  : ringtoneConfig = ringtoneConfig ?? ZegoCallRingtoneConfig(),
        config = config ?? ZegoCallInvitationConfig(),
        uiConfig = uiConfig ?? ZegoCallInvitationUIConfig(),
        innerText = innerText ?? ZegoCallInvitationInnerText(),
        notificationConfig =
            notificationConfig ?? ZegoCallInvitationNotificationConfig();

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  final String token;

  /// local user info
  final String userID;
  final String userName;

  /// we need the [ZegoUIKitPrebuiltCallConfig] to show [ZegoUIKitPrebuiltCall]
  final ZegoCallPrebuiltConfigQuery requireConfig;

  ZegoUIKitPrebuiltCallEvents? events;

  final ZegoCallInvitationInnerText innerText;

  ///
  final List<IZegoUIKitPlugin> plugins;

  final ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents;

  /// you can customize your ringing bell
  final ZegoCallRingtoneConfig ringtoneConfig;

  /// ui config
  final ZegoCallInvitationUIConfig uiConfig;

  /// config
  final ZegoCallInvitationConfig config;

  final ZegoCallInvitationNotificationConfig notificationConfig;

  /// we need a context object, to push/pop page when receive invitation request
  ContextQuery? contextQuery;
}

class ZegoCallInvitationLocalParameter {
  ZegoCallInvitationLocalParameter({
    this.resourceID,
    this.notificationMessage,
    this.notificationTitle,
    this.timeoutSeconds = 60,
  });

  final String? resourceID;
  final String? notificationTitle;
  final String? notificationMessage;
  final int timeoutSeconds;

  ZegoCallInvitationLocalParameter.empty({
    this.resourceID = '',
    this.notificationTitle = '',
    this.notificationMessage = '',
    this.timeoutSeconds = 60,
  });

  @override
  String toString() {
    return 'ZegoCallInvitationLocalParameter:{'
        'resourceID:$resourceID, '
        'notificationTitle:$notificationTitle, '
        'notificationMessage:$notificationMessage, '
        'timeoutSeconds:$timeoutSeconds, '
        '}';
  }
}
