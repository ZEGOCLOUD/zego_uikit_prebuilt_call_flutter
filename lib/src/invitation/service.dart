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
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/handler.android.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/handler.ios.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/isolate_name_server_guard.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/notification.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/plugins.dart';

part 'mixins/private/callkit.dart';

part 'mixins/private/ios.callkit.dart';

part 'mixins/private/private.dart';

part 'mixins/invitation.dart';

part 'mixins/private/invitation.dart';

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
    with ZegoCallInvitationServicePrivate, ZegoCallInvitationServiceAPI {
  bool get isInit => private._isInit;

  bool get isInCalling => private._pageManager?.isInCalling ?? false;

  ZegoUIKitPrebuiltCallController get controller =>
      ZegoUIKitPrebuiltCallController.instance;

  /// we need a context object, to push/pop page when receive invitation request
  /// so we need navigatorKey to get context
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    ZegoLoggerService.logInfo(
      'isInit:${private._isInit},'
      'navigatorKey:$navigatorKey',
      tag: 'call-invitation',
      subTag: 'service(${identityHashCode(this)}), setNavigatorKey',
    );

    if (private._isInit) {
      private._data?.contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    } else {
      private._contextQuery = () {
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
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    String appSign = '',
    String token = '',

    /// call abouts.
    ZegoCallPrebuiltConfigQuery? requireConfig,
    ZegoUIKitPrebuiltCallEvents? events,

    /// invitation abouts.
    ZegoCallInvitationConfig? config,
    ZegoCallRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationNotificationConfig? notificationConfig,
    ZegoCallInvitationInnerText? innerText,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
  }) async {
    if (private._isInit) {
      ZegoLoggerService.logWarn(
        'service had init before',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)}), init',
      );

      return;
    }

    await ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:4.14.3; $uikitVersion',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)}), init',
      );
    });

    private._isInit = true;

    ZegoLoggerService.logInfo(
      'service init, '
      'appID:$appID, '
      'userID:$userID, '
      'userName:$userName, '
      'plugins:$plugins, '
      'ringtoneConfig:$ringtoneConfig, '
      'config:$config, '
      'uiConfig:$uiConfig, '
      'notificationConfig:$notificationConfig, ',
      tag: 'call-invitation',
      subTag: 'service(${identityHashCode(this)}), init',
    );

    await private._initPrivate(
      appID: appID,
      appSign: appSign,
      token: token,
      userID: userID,
      userName: userName,
      plugins: plugins,
      requireConfig: requireConfig,
      ringtoneConfig: ringtoneConfig,
      config: config,
      uiConfig: uiConfig,
      notificationConfig: notificationConfig,
      innerText: innerText,
      events: events,
      invitationEvents: invitationEvents,
    );
    _invitation._private.init(
      innerText: innerText,
      events: events,
    );

    await private.callkit._initCallKit(
      pageManager: private._pageManager!,
      androidNotificationConfig:
          private._data!.notificationConfig.androidNotificationConfig,
    );

    await private._initPlugins(
      appID: appID,
      appSign: appSign,
      token: token,
      userID: userID,
      userName: userName,
    );

    await private._initPermissions().then((value) => private._initContext());
  }

  ///   you must call this method as soon as the user logout from your app
  Future<void> uninit() async {
    if (!private._isInit) {
      ZegoLoggerService.logInfo(
        'service had not init, not need to un-init',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)}), uninit',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'service un-init',
      tag: 'call-invitation',
      subTag: 'service(${identityHashCode(this)}), uninit',
    );

    private._isInit = false;

    await private._uninitPrivate();

    _invitation._private.uninit();

    await private.callkit._uninitCallKit();
    if (Platform.isIOS) {
      private.iOSCallkit._uninitIOSCallkitService();
    }

    await private._uninitPlugins();
  }

  void useSystemCallingUI(List<IZegoUIKitPlugin> plugins) {
    ZegoLoggerService.logInfo(
      'plugins size: ${plugins.length}',
      tag: 'call-invitation',
      subTag: 'service(${identityHashCode(this)}), useSystemCallingUI',
    );

    ZegoUIKit().installPlugins(plugins);
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'register background message handler',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)}), useSystemCallingUI',
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .setBackgroundMessageHandler(onBackgroundMessageReceived);
    } else if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'register incoming push receive handler',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)}), useSystemCallingUI',
      );

      private._enableIOSVoIP = true;

      ZegoUIKit()
          .getSignalingPlugin()
          .setIncomingPushReceivedHandler(onIncomingPushReceived);

      private.iOSCallkit._initIOSCallkitService();
    }
  }

  /// This function is used to send call invitations to one or more specified users.
  ///
  /// You can provide a list of target users [invitees] and specify whether it is a video call [isVideoCall]. If it is not a video call, it defaults to an audio call.
  /// You can also pass additional custom data [customData] to the invitees.
  /// Additionally, you can specify the call ID [callID]. If not provided, the system will generate one automatically based on certain rules.
  /// If you want to set a ringtone for offline call invitations, set [resourceID] to a value that matches the push resource ID in the ZEGOCLOUD management console.
  /// You can also set the notification title [notificationTitle] and message [notificationMessage].
  /// If the call times out, the call will automatically hang up after the specified timeout duration [timeoutSeconds] (in seconds).
  ///
  /// Note that this function behaves the same as [ZegoSendCallInvitationButton].
  Future<bool> send({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) async {
    return _invitation.send(
      invitees: invitees,
      isVideoCall: isVideoCall,
      customData: customData,
      callID: callID,
      resourceID: resourceID,
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
      timeoutSeconds: timeoutSeconds,
    );
  }

  ///  To cancel the invitation for [callees] in a call, you can include your
  ///  cancellation reason using the [customData].
  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    return _invitation.cancel(
      callees: callees,
      customData: customData,
    );
  }

  /// To reject the current call invitation, you can use the [customData]
  /// parameter if you need to provide a reason for the rejection to the other party.
  ///
  /// Additionally, the inviting party can receive notifications of the
  /// rejection by listening to [onOutgoingCallRejectedCauseBusy] or
  /// [onOutgoingCallDeclined] when the other party declines the call invitation.
  Future<bool> reject({
    String customData = '',
  }) async {
    return _invitation.reject(customData: customData);
  }

  /// To accept the current call invitation, you can use the [customData]
  /// parameter if you need to provide a reason for the acceptance to the other party.
  ///
  /// Additionally, the inviting party can receive notifications by listening
  /// to [onOutgoingCallAccepted] when the other party accepts the call invitation.
  Future<bool> accept({
    String customData = '',
  }) async {
    return _invitation.accept(customData: customData);
  }

  ZegoUIKitPrebuiltCallInvitationService._internal() {
    ZegoLoggerService.logInfo(
      'create',
      tag: 'call-invitation',
      subTag: 'service(${identityHashCode(this)})',
    );
  }

  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();
}
