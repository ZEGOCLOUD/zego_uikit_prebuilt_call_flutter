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
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

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

  ZegoCallInvitationInnerText get innerText =>
      _data?.innerText ?? ZegoCallInvitationInnerText();

  /// Invitation-related event notifications and callbacks.
  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data?.events;

  ZegoRingtoneConfig get ringtoneConfig =>
      _data?.ringtoneConfig ?? const ZegoRingtoneConfig();

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data?.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController? get controller => _data?.controller;

  bool get isInCalling => _pageManager?.isInCalling ?? false;

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
      _callInvitationConfig?.contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    } else {
      _contextQuery = () {
        return navigatorKey.currentState!.context;
      };
    }
  }

  bool get isInit => _isInit;

  Future<void> init({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    PrebuiltConfigQuery? requireConfig,
    ZegoUIKitPrebuiltCallInvitationEvents? events,
    ZegoUIKitPrebuiltCallController? controller,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,

    /// todo: move to [ZegoCallInvitationUIConfig]
    bool showDeclineButton = true,
    bool showCancelInvitationButton = true,

    /// todo: move to [ZegoCallInvitationNotificationConfig]
    bool notifyWhenAppRunningInBackgroundOrQuit = true,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoIOSNotificationConfig? iOSNotificationConfig,

    /// todo: move to [ZegoIOSNotificationConfig]
    ZegoSignalingPluginMultiCertificate certificateIndex =
        ZegoSignalingPluginMultiCertificate.firstCertificate,
    String appName = '',
    @Deprecated('use iOSNotificationConfig.isSandboxEnvironment instead')
    bool? isIOSSandboxEnvironment,
  }) async {
    if (_isInit) {
      ZegoLoggerService.logWarn(
        'service had init before',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      return;
    }

    _isInit = true;

    _registerOfflineCallIsolateNameServer();

    await ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:3.18.1; $uikitVersion',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );
    });

    ZegoLoggerService.logInfo(
      'service init',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

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
      uiConfig: uiConfig,
    );

    _callInvitationConfig = ZegoCallInvitationConfig(
      appID: _data!.appID,
      appSign: _data!.appSign,
      userID: _data!.userID,
      userName: _data!.userName,
      prebuiltConfigQuery: _data!.requireConfig ?? _defaultConfig,
      notifyWhenAppRunningInBackgroundOrQuit:
          _data!.notifyWhenAppRunningInBackgroundOrQuit,
      uiConfig: _data!.uiConfig,
      showDeclineButton: _data!.showDeclineButton,
      showCancelInvitationButton: _data!.showCancelInvitationButton,
      androidNotificationConfig: _data!.androidNotificationConfig,
      iOSNotificationConfig: _data!.iOSNotificationConfig,
      invitationEvents: _data!.events,
      innerText: _data!.innerText,
      controller: _data!.controller,
      plugins: plugins,
    );
    if (null != _contextQuery) {
      ZegoLoggerService.logInfo(
        'update contextQuery in call invitation config',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      _callInvitationConfig!.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoNotificationManager(
      showDeclineButton: showDeclineButton,
      callInvitationConfig: _callInvitationConfig!,
    );
    if (_callInvitationConfig!.notifyWhenAppRunningInBackgroundOrQuit) {
      await _notificationManager!.init();
    } else {
      ZegoLoggerService.logInfo(
        'notifyWhenAppRunningInBackgroundOrQuit is false, not need to init',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );
    }

    _pageManager = ZegoInvitationPageManager(
      callInvitationConfig: _callInvitationConfig!,
      notificationManager: _notificationManager!,
    );
    _pageManager?.init(
      ringtoneConfig: _data!.ringtoneConfig,
    );

    ZegoCallInvitationInternalInstance.instance.register(
      pageManager: _pageManager!,
      callInvitationConfig: _callInvitationConfig!,
    );

    _initCallKit(
      pageManager: _pageManager!,
      showDeclineButton: _data!.showDeclineButton,
      callInvitationConfig: _callInvitationConfig!,
      androidNotificationConfig: _data!.androidNotificationConfig,
    );

    _plugins = ZegoPrebuiltPlugins(
      appID: _data!.appID,
      appSign: _data!.appSign,
      userID: _data!.userID,
      userName: _data!.userName,
      plugins: _data!.plugins,
      onError: _data?.events?.onError,
    );
    await _plugins!.init(onPluginInit: () async {
      if (_data!.notifyWhenAppRunningInBackgroundOrQuit) {
        ZegoLoggerService.logInfo(
          'try enable notification, '
          'iOSNotificationConfig:${_data!.iOSNotificationConfig}, '
          'enableIOSVoIP:$_enableIOSVoIP ',
          tag: 'call',
          subTag: 'call invitation service(${identityHashCode(this)})',
        );

        final androidChannelID = _data!.androidNotificationConfig?.channelID ??
            defaultCallChannelKey;
        final androidChannelName =
            _data!.androidNotificationConfig?.channelName ??
                defaultCallChannelName;
        setPreferenceString(
          serializationKeyHandlerInfo,
          HandlerPrivateInfo(
            appID: appID.toString(),
            userID: userID,
            userName: userName,
            isIOSSandboxEnvironment:
                _data!.iOSNotificationConfig?.isSandboxEnvironment,
            enableIOSVoIP: _enableIOSVoIP,
            certificateIndex: certificateIndex.id,
            appName: appName,
            androidCallChannelID: androidChannelID,
            androidCallChannelName: androidChannelName,
            androidCallSound: _data!.androidNotificationConfig?.sound ?? '',
            androidCallVibrate:
                _data!.androidNotificationConfig?.vibrate ?? true,
            androidMessageChannelID:
                _data!.androidNotificationConfig?.messageChannelID ??
                    defaultMessageChannelID,
            androidMessageChannelName:
                _data!.androidNotificationConfig?.messageChannelName ??
                    defaultMessageChannelName,
            androidMessageIcon:
                _data!.androidNotificationConfig?.messageIcon ?? '',
            androidMessageSound:
                _data!.androidNotificationConfig?.messageSound ?? '',
            androidMessageVibrate:
                _data!.androidNotificationConfig?.messageVibrate ?? false,
          ).toJsonString(),
        );

        ZegoUIKit()
            .getSignalingPlugin()
            .enableNotifyWhenAppRunningInBackgroundOrQuit(
              true,
              isIOSSandboxEnvironment:
                  _data!.iOSNotificationConfig?.isSandboxEnvironment,
              enableIOSVoIP: _enableIOSVoIP,
              certificateIndex: certificateIndex.id,
              appName: appName,
              androidChannelID: androidChannelID,
              androidChannelName: androidChannelName,
              androidSound:
                  (_data!.androidNotificationConfig?.sound?.isEmpty ?? true)
                      ? ''
                      : '/raw/${_data!.androidNotificationConfig?.sound}',
            )
            .then((result) {
          if (_enableIOSVoIP) {
            ZegoUIKit().getSignalingPlugin().setInitConfiguration(
                  ZegoSignalingPluginProviderConfiguration(
                    localizedName: appName,
                    iconTemplateImageName:
                        _data!.iOSNotificationConfig?.systemCallingIconName ??
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
            subTag: 'call invitation service(${identityHashCode(this)})',
          );
        });
      }
    }).then((value) {
      ZegoLoggerService.logInfo(
        'plugin init finished, notifyWhenAppRunningInBackgroundOrQuit:'
        '${_data!.notifyWhenAppRunningInBackgroundOrQuit}',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      _pageManager?.listenStream();

      if (Platform.isAndroid) {
        getCurrentCallKitParams().then((paramsJson) {
          ZegoLoggerService.logInfo(
            'offline callkit param: $paramsJson',
            tag: 'call',
            subTag: 'callkit service',
          );

          if (paramsJson?.isEmpty ?? true) {
            return;
          }

          ZegoLoggerService.logInfo(
            'exist offline call accept',
            tag: 'call',
            subTag: 'callkit service',
          );

          /// exist accepted offline call, wait auto enter room
          _pageManager
                  ?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
              true;

          _pageManager?.onInvitationReceived(jsonDecode(paramsJson!));
        });
      }
    });

    await _initPermissions().then((value) => _initContext());
  }

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

    _unregisterOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);

    _notificationManager?.uninit();

    await _uninitCallKit();
    if (Platform.isIOS) {
      _uninitIOSCallkitService();
    }

    ZegoLoggerService.logInfo(
      'logout signaling account',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );
    await ZegoUIKit().getSignalingPlugin().logout();

    await _uninitContext();
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

  void _registerOfflineCallIsolateNameServer() {
    _backgroundPort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _backgroundPort!.sendPort,
      backgroundMessageIsolatePortName,
    );
    _backgroundPort!.listen((dynamic message) async {
      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, message:$message',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      final messageMap = jsonDecode(message) as Map<String, dynamic>;
      final messageTitle = messageMap['title'] as String? ?? '';
      final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, '
        'title:$messageTitle, '
        'extra:$messageExtras',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
      await ZegoCallPluginPlatform.instance.activeAppToForeground();
      await ZegoCallPluginPlatform.instance.requestDismissKeyguard();

      /// There is no need for additional processing.
      /// When the app is suspended after being screen-locked for more than 10
      /// minutes, it will receives offline calls from ZPNS.
      ///
      /// At this time, the offline handler wakes up the app through isolate
      /// and then ZIM been reconnected and receive online call.
      /// After receiving an online call, because the app is in the background,
      /// it will run the logic code of background online calls and then pops
      /// up the CallKit UI.
    });

    ZegoLoggerService.logInfo(
      'isolate: register offline call isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );
  }

  void _unregisterOfflineCallIsolateNameServer() {
    ZegoLoggerService.logInfo(
      'isolate: unregister offline call  isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    _backgroundPort?.close();
    IsolateNameServer.removePortNameMapping(backgroundMessageIsolatePortName);
  }

  @Deprecated('Since 3.3.3')
  void didChangeAppLifecycleState(bool isAppInBackground) {}

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    if (!_isInit) {
      return;
    }

    final isScreenLockEnabled = await isLockScreen() ?? false;
    var isAppInBackground = appLifecycleState != AppLifecycleState.resumed;
    if (isScreenLockEnabled) {
      isAppInBackground = true;
    }
    ZegoLoggerService.logInfo(
      'AppLifecycleStateChanged, state:$appLifecycleState, '
      'isAppInBackground:$isAppInBackground, '
      'isScreenLockEnabled:$isScreenLockEnabled',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    _pageManager?.didChangeAppLifecycleState(isAppInBackground);
    _plugins?.didChangeAppLifecycleState(isAppInBackground);
  }

  ZegoUIKitPrebuiltCallInvitationService._internal() {
    ZegoLoggerService.logInfo(
      'ZegoUIKitPrebuiltCallInvitationService create',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );
  }

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();

  bool _isInit = false;

  /// callkit
  bool _enableIOSVoIP = false;

  ReceivePort? _backgroundPort;
}
