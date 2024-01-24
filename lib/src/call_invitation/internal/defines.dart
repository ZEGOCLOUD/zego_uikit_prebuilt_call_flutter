// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';

/// @nodoc
typedef ContextQuery = BuildContext Function();

/// @nodoc
class ZegoUIKitPrebuiltCallInvitationData {
  ZegoUIKitPrebuiltCallInvitationData({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.plugins,
    required this.requireConfig,
    this.events,
    this.invitationEvents,
    this.contextQuery,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationNotificationConfig? notificationConfig,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
        uiConfig = uiConfig ?? ZegoCallInvitationUIConfig(),
        innerText = innerText ?? ZegoCallInvitationInnerText(),
        notificationConfig =
            notificationConfig ?? ZegoCallInvitationNotificationConfig();

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// local user info
  final String userID;
  final String userName;

  /// we need the [ZegoUIKitPrebuiltCallConfig] to show [ZegoUIKitPrebuiltCall]
  final PrebuiltConfigQuery requireConfig;

  ZegoUIKitPrebuiltCallEvents? events;

  final ZegoCallInvitationInnerText innerText;

  ///
  final List<IZegoUIKitPlugin> plugins;

  final ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents;

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  /// ui config
  final ZegoCallInvitationUIConfig uiConfig;

  final ZegoCallInvitationNotificationConfig notificationConfig;

  /// we need a context object, to push/pop page when receive invitation request
  ContextQuery? contextQuery;
}
