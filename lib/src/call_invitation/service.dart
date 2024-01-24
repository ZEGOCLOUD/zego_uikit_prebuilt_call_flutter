// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_callkit_incoming_yoer/entities/call_event.dart';
import 'package:flutter_callkit_incoming_yoer/flutter_callkit_incoming.dart';
import 'package:is_lock_screen2/is_lock_screen2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/handler.android.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/handler.ios.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';

part 'mixins/callkit.dart';

part 'mixins/ios.callkit.dart';

part 'mixins/private.dart';

/// To receive the call invites from others and let the calling notification show on the top bar when receiving it, you will need to initialize the call invitation service (ZegoUIKitPrebuiltCallInvitationService) first.
///
/// 1.1 Set up the context.
///   To make the UI show when receiving a call invite, you will need to get the Context. To do so, do the following 3 steps:
///   1.1.1 Define a navigator key.
///   1.1.2 Set the navigatorKey to ZegoUIKitPrebuiltCallInvitationService.
///   1.1.3 Register the navigatorKey to MaterialApp.
///
/// 1.2 Initialize/Deinitialize the call invitation service.
///   1.2.1 Initialize the service when your app users logged in successfully or re-logged in after an exit.
///   1.2.2 Deinitialize the service after your app users logged out.
///
/// Example:
/// ``` dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   /// 1.1.1 define a navigator key
///   final navigatorKey = GlobalKey<NavigatorState>();
///
///   /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
///   ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
///
///   runApp(MyApp(navigatorKey: navigatorKey));
/// }
///
/// class MyApp extends StatefulWidget {
///   final GlobalKey<NavigatorState> navigatorKey;
///
///   const MyApp({
///     required this.navigatorKey,
///     Key? key,
///   }) : super(key: key);
///
///   @override
///   State<StatefulWidget> createState() => MyAppState();
/// }
///
/// class MyAppState extends State<MyApp> {
///   @override
///   void initState() {
///     super.initState();
///
///     if (/*the user of the app is logged in*/) {
///       onUserLogin();
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       /// 1.1.3: register the navigator key to MaterialApp
///       navigatorKey: widget.navigatorKey,
///       ...
///     );
///   }
/// }
///
/// /// on App's user login
/// void onUserLogin() {
///   /// 1.2.1. initialized ZegoUIKitPrebuiltCallInvitationService
///   /// when app's user is logged in or re-logged in
///   /// We recommend calling this method as soon as the user logs in to your app.
///   ZegoUIKitPrebuiltCallInvitationService().init(
///     appID: yourAppID /*input your AppID*/,
///     appSign: yourAppSign /*input your AppSign*/,
///     userID: currentUser.id,
///     userName: currentUser.name,
///     plugins: [ZegoUIKitSignalingPlugin()],
///   );
/// }
///
/// /// on App's user logout
/// void onUserLogout() {
///   /// 1.2.2. de-initialization ZegoUIKitPrebuiltCallInvitationService
///   /// when app's user is logged out
///   ZegoUIKitPrebuiltCallInvitationService().uninit();
/// }
/// ```
class ZegoUIKitPrebuiltCallInvitationService
    with
        CallInvitationServicePrivate,
        CallInvitationServiceCallKit,
        CallInvitationServiceIOSCallKit {
  bool get isInit => _isInit;

  bool get isInCalling => _pageManager?.isInCalling ?? false;

  ZegoCallInvitationInnerText get innerText =>
      _data?.innerText ?? ZegoCallInvitationInnerText();

  /// Invitation-related event notifications and callbacks.
  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data?.invitationEvents;

  ZegoRingtoneConfig get ringtoneConfig =>
      _data?.ringtoneConfig ?? const ZegoRingtoneConfig();

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data?.notificationConfig.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController get controller =>
      ZegoUIKitPrebuiltCallController.instance;

  /// we need a context object, to push/pop page when receive invitation request
  /// so we need navigatorKey to get context
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    ZegoLoggerService.logInfo(
      'setNavigatorKey, '
      'isInit:$_isInit,'
      'navigatorKey:$navigatorKey',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    if (_isInit) {
      _data?.contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    } else {
      _contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    }
  }

  /// you must call this method as soon as the user login(or re-login, auto-login) to your app.
  ///
  /// You must include [ZegoUIKitSignalingPlugin] in [plugins] to support the invitation feature.
  ///
  /// If you need to set [ZegoUIKitPrebuiltCallConfig], you can do so through [requireConfig].
  /// Each time the [ZegoUIKitPrebuiltCall] starts, it will request this callback to obtain the current call's config.
  ///
  /// Additionally, you can customize the call ringtone through [ringtoneConfig], and configure notifications through [notificationConfig].
  /// You can also customize the invitation interface with [uiConfig]. If you want to modify the related text on the interface, you can set [innerText].
  /// If you want to listen for events and perform custom logics, you can use [invitationEvents] to obtain related invitation events, and for call-related events, you need to use [events].
  Future<void> init({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    PrebuiltConfigQuery? requireConfig,
    ZegoRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationNotificationConfig? notificationConfig,
    ZegoCallInvitationInnerText? innerText,
    ZegoUIKitPrebuiltCallEvents? events,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
  }) async {
    if (_isInit) {
      ZegoLoggerService.logWarn(
        'service had init before',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      return;
    }

    await ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:4.1.6; $uikitVersion',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );
    });

    _isInit = true;

    ZegoLoggerService.logInfo(
      'service init',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    await _initPrivate(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: plugins,
      requireConfig: requireConfig,
      ringtoneConfig: ringtoneConfig,
      uiConfig: uiConfig,
      notificationConfig: notificationConfig,
      innerText: innerText,
      events: events,
      invitationEvents: invitationEvents,
    );

    await _initCallKit(
      pageManager: _pageManager!,
      androidNotificationConfig:
          _data!.notificationConfig.androidNotificationConfig,
    );

    await _initPlugins(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
    );

    await _initPermissions().then((value) => _initContext());
  }

  ///   you must call this method as soon as the user logout from your app
  Future<void> uninit() async {
    if (!_isInit) {
      ZegoLoggerService.logInfo(
        'service had not init, not need to un-init',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'service un-init',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    _isInit = false;

    await _uninitPrivate();

    await _uninitCallKit();
    if (Platform.isIOS) {
      _uninitIOSCallkitService();
    }

    await _uninitPlugins();
  }

  void useSystemCallingUI(List<IZegoUIKitPlugin> plugins) {
    ZegoLoggerService.logInfo(
      'using system calling ui, plugins size: ${plugins.length}',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    ZegoUIKit().installPlugins(plugins);
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'register background message handler',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .setBackgroundMessageHandler(onBackgroundMessageReceived);
    } else if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'register incoming push receive handler',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      _enableIOSVoIP = true;

      ZegoUIKit()
          .getSignalingPlugin()
          .setIncomingPushReceivedHandler(onIncomingPushReceived);

      _initIOSCallkitService();
    }
  }

  ZegoUIKitPrebuiltCallInvitationService._internal() {
    ZegoLoggerService.logInfo(
      'ZegoUIKitPrebuiltCallInvitationService create',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );
  }

  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();
}
