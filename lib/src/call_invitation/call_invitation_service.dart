// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_controller.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/handler.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/app_state.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';

import 'internal/shared_pref_defines.dart';

part 'callkit/call_invitation_service.callkit.dart';

part 'callkit/call_invitation_service.ios.callkit.dart';

part 'internal/call_invitation_service.p.dart';

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
        ZegoUIKitPrebuiltCallInvitationServicePrivate,
        iOSCallKitService,
        ZegoUIKitPrebuiltCallInvitationServiceCallKit {
  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  ZegoCallInvitationInnerText get innerText => _data.innerText;

  /// Invitation-related event notifications and callbacks.
  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data.events;

  ZegoRingtoneConfig get ringtoneConfig => _data.ringtoneConfig;

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController? get controller => _data.controller;

  bool get isInCalling => _pageManager.isInCalling;

  /// we need a context object, to push/pop page when receive invitation request
  /// so we need navigatorKey to get context
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    if (_isInit) {
      _callInvitationConfig.contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    } else {
      _contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    }
  }

  Future<void> init({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    PrebuiltConfigQuery? requireConfig,
    bool showDeclineButton = true,
    bool showCancelInvitationButton = true,
    ZegoUIKitPrebuiltCallInvitationEvents? events,
    bool notifyWhenAppRunningInBackgroundOrQuit = true,
    ZegoSignalingPluginMultiCertificate certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    String appName = '',
    @Deprecated('use iOSNotificationConfig.isSandboxEnvironment instead')
        bool? isIOSSandboxEnvironment,
    ZegoIOSNotificationConfig? iOSNotificationConfig,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallController? controller,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  }) async {
    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:3.11.0; $uikitVersion',
        tag: 'call',
        subTag: 'call invitation service',
      );
    });

    if (_isInit) {
      await uninit();
    }

    ZegoLoggerService.logInfo(
      'service init',
      tag: 'call',
      subTag: 'call invitation service',
    );

    /// sync app background state
    SystemChannels.lifecycle.setMessageHandler((stateString) async {
      final state = parseStateFromString(stateString!);
      WidgetsBinding.instance?.handleAppLifecycleStateChanged(state);

      if (!_isInit) {
        return;
      }

      /// todo 'locked awake' is also resumed in android
      final isAppInBackground = state != AppLifecycleState.resumed;

      _pageManager.didChangeAppLifecycleState(isAppInBackground);
      _plugins.didChangeAppLifecycleState(isAppInBackground);
      return null;
    });

    _isInit = true;

    _correctIOSNotificationConfig(
      isIOSSandboxEnvironment: isIOSSandboxEnvironment,
      iOSNotificationConfig: iOSNotificationConfig,
    );
    _data = ZegoUIKitPrebuiltCallInvitationServiceData(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: plugins,
      requireConfig: requireConfig,
      showDeclineButton: showDeclineButton,
      showCancelInvitationButton: showCancelInvitationButton,
      events: events,
      notifyWhenAppRunningInBackgroundOrQuit:
          notifyWhenAppRunningInBackgroundOrQuit,
      iOSNotificationConfig: iOSNotificationConfig,
      androidNotificationConfig: androidNotificationConfig,
      controller: controller,
      innerText: innerText,
      ringtoneConfig: ringtoneConfig,
    );

    _callInvitationConfig = ZegoCallInvitationConfig(
      appID: _data.appID,
      appSign: _data.appSign,
      userID: _data.userID,
      userName: _data.userName,
      prebuiltConfigQuery: _data.requireConfig ?? _defaultConfig,
      notifyWhenAppRunningInBackgroundOrQuit:
          _data.notifyWhenAppRunningInBackgroundOrQuit,
      showDeclineButton: _data.showDeclineButton,
      showCancelInvitationButton: _data.showCancelInvitationButton,
      androidNotificationConfig: _data.androidNotificationConfig,
      iOSNotificationConfig: _data.iOSNotificationConfig,
      invitationEvents: _data.events,
      innerText: _data.innerText,
      controller: _data.controller,
      plugins: plugins,
    );
    if (null != _contextQuery) {
      _callInvitationConfig.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoNotificationManager(
      showDeclineButton: showDeclineButton,
      callInvitationConfig: _callInvitationConfig,
    );
    _notificationManager.init();

    _pageManager = ZegoInvitationPageManager(
      callInvitationConfig: _callInvitationConfig,
      notificationManager: _notificationManager,
    );

    ZegoCallInvitationInternalInstance.instance.register(
      pageManager: _pageManager,
      callInvitationConfig: _callInvitationConfig,
    );

    _initCallKit(
      pageManager: _pageManager,
      showDeclineButton: _data.showDeclineButton,
      callInvitationConfig: _callInvitationConfig,
      androidNotificationConfig: _data.androidNotificationConfig,
    );

    _plugins = ZegoPrebuiltPlugins(
      appID: _data.appID,
      appSign: _data.appSign,
      userID: _data.userID,
      userName: _data.userName,
      plugins: _data.plugins,
    );
    await _plugins.init().then((value) {
      ZegoLoggerService.logInfo(
        'plugin init finished, notifyWhenAppRunningInBackgroundOrQuit:'
        '${_data.notifyWhenAppRunningInBackgroundOrQuit}',
        tag: 'call',
        subTag: 'call invitation service',
      );

      if (_data.notifyWhenAppRunningInBackgroundOrQuit) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ZegoLoggerService.logInfo(
            'try enable notification, '
            'iOSNotificationConfig:${_data.iOSNotificationConfig}, '
            'enableIOSVoIP:$_enableIOSVoIP ',
            tag: 'call',
            subTag: 'call invitation service',
          );

          final androidChannelID =
              _data.androidNotificationConfig?.channelID ?? 'CallInvitation';
          final androidChannelName =
              _data.androidNotificationConfig?.channelName ?? 'Call Invitation';
          final androidSound =
              '/raw/${_data.androidNotificationConfig?.sound ?? '/raw/zego_incoming'}';
          setPreferenceString(
            serializationKeyHandlerInfo,
            HandlerPrivateInfo(
              appID: appID.toString(),
              userID: userID,
              userName: userName,
              isIOSSandboxEnvironment:
                  _data.iOSNotificationConfig?.isSandboxEnvironment ?? false,
              enableIOSVoIP: _enableIOSVoIP,
              certificateIndex: certificateIndex.id,
              appName: appName,
              androidChannelID: androidChannelID,
              androidChannelName: androidChannelName,
              androidSound: androidSound,
            ).toJsonString(),
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .enableNotifyWhenAppRunningInBackgroundOrQuit(
                true,
                isIOSSandboxEnvironment:
                    _data.iOSNotificationConfig?.isSandboxEnvironment ?? false,
                enableIOSVoIP: _enableIOSVoIP,
                certificateIndex: certificateIndex.id,
                appName: appName,
                androidChannelID: androidChannelID,
                androidChannelName: androidChannelName,
                androidSound: androidSound,
              )
              .then((result) {
            if (_enableIOSVoIP) {
              ZegoUIKit().getSignalingPlugin().setInitConfiguration(
                    ZegoSignalingPluginProviderConfiguration(
                      localizedName: appName,
                      iconTemplateImageName:
                          _data.iOSNotificationConfig?.systemCallingIconName ??
                              '',
                      supportsVideo: false,
                      maximumCallsPerCallGroup: 1,
                      maximumCallGroups: 1,
                    ),
                  );
            }

            ZegoLoggerService.logInfo(
              'enable notification result: $result',
              tag: 'call',
              subTag: 'call invitation service',
            );
          });
        });
      }
    });

    await _initPermissions().then((value) => _initContext());
  }

  Future<void> uninit() async {
    if (!_isInit) {
      return;
    }

    ZegoLoggerService.logInfo(
      'un-init',
      tag: 'call',
      subTag: 'call invitation service',
    );

    _isInit = false;

    _notificationManager.uninit();

    await _uninitCallKit();
    if (Platform.isIOS) {
      _uninitIOSCallkitService();
    }

    ZegoLoggerService.logInfo(
      'logout signaling account',
      tag: 'call',
      subTag: 'call invitation service',
    );
    await ZegoUIKit().getSignalingPlugin().logout();

    await _uninitContext();
  }

  void useSystemCallingUI(List<IZegoUIKitPlugin> plugins) {
    ZegoLoggerService.logInfo(
      'using system calling ui, plugins size: ${plugins.length}',
      tag: 'call',
      subTag: 'call invitation service',
    );

    ZegoUIKit().installPlugins(plugins);
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'register background message handler',
        tag: 'call',
        subTag: 'call invitation service',
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .setBackgroundMessageHandler(onBackgroundMessageReceived);
    } else if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'register incoming push receive handler',
        tag: 'call',
        subTag: 'call invitation service',
      );

      _enableIOSVoIP = true;

      ZegoUIKit()
          .getSignalingPlugin()
          .setIncomingPushReceivedHandler(onIncomingPushReceived);

      _initIOSCallkitService();
    }
  }

  @Deprecated('Since 3.3.3')
  void didChangeAppLifecycleState(bool isAppInBackground) {}

  ZegoUIKitPrebuiltCallInvitationService._internal();

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();
}
