// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
typedef ContextQuery = BuildContext Function();

/// @nodoc
class ZegoCallInvitationConfig {
  int appID;
  String appSign;
  String userID;
  String userName;
  PrebuiltConfigQuery prebuiltConfigQuery;

  /// we need a context object, to push/pop page when receive invitation request
  ContextQuery? contextQuery;

  bool notifyWhenAppRunningInBackgroundOrQuit = true;
  bool showDeclineButton = true;
  bool showCancelInvitationButton = true;
  ZegoCallInvitationUIConfig? uiConfig;
  ZegoIOSNotificationConfig? iOSNotificationConfig;
  ZegoAndroidNotificationConfig? androidNotificationConfig;
  ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents;
  ZegoCallInvitationInnerText? innerText;

  ZegoUIKitPrebuiltCallController? controller;

  final List<IZegoUIKitPlugin>? plugins;

  ZegoCallInvitationConfig({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.prebuiltConfigQuery,
    this.contextQuery,
    this.showDeclineButton = true,
    this.showCancelInvitationButton = true,
    this.notifyWhenAppRunningInBackgroundOrQuit = true,
    this.androidNotificationConfig,
    this.iOSNotificationConfig,
    this.uiConfig,
    this.invitationEvents,
    this.innerText,
    this.controller,
    this.plugins,
  });
}
