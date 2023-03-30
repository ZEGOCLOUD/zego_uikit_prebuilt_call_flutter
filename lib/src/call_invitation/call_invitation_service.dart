// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_inviataion_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoUIKitPrebuiltCallInvitationService {
  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  ZegoCallInvitationInnerText get innerText => _data.innerText;

  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data.events;

  ZegoRingtoneConfig get ringtoneConfig => _data.ringtoneConfig;

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController? get controller => _data.controller;

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
    ZegoUIKitPrebuiltCallInvitationEvents? events,
    bool notifyWhenAppRunningInBackgroundOrQuit = true,
    bool isIOSSandboxEnvironment = false,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallController? controller,
    Size? appDesignSize,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  }) async {
    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:3.1.0; $uikitVersion',
        tag: 'call',
        subTag: 'prebuilt invitation',
      );
    });

    if (_isInit) {
      await uninit();
    }

    _isInit = true;
    _data = ZegoUIKitPrebuiltCallInvitationServiceData(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: plugins,
      requireConfig: requireConfig,
      showDeclineButton: showDeclineButton,
      events: events,
      notifyWhenAppRunningInBackgroundOrQuit:
          notifyWhenAppRunningInBackgroundOrQuit,
      isIOSSandboxEnvironment: isIOSSandboxEnvironment,
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
      androidNotificationConfig: _data.androidNotificationConfig,
      invitationEvents: _data.events,
      innerText: _data.innerText,
      controller: _data.controller,
      appDesignSize: appDesignSize,
    );
    if (null != _contextQuery) {
      _callInvitationConfig.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoNotificationManager(
      callInvitationConfig: _callInvitationConfig,
      events: _data.events,
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

    _plugins = ZegoPrebuiltPlugins(
      appID: _data.appID,
      appSign: _data.appSign,
      userID: _data.userID,
      userName: _data.userName,
      plugins: _data.plugins,
    );
    await _plugins.init().then((value) {
      ZegoLoggerService.logInfo(
        '[call ] plugin init finished, notifyWhenAppRunningInBackgroundOrQuit:'
        '${_data.notifyWhenAppRunningInBackgroundOrQuit}',
        tag: 'call',
        subTag: 'prebuilt invitation',
      );
      if (_data.notifyWhenAppRunningInBackgroundOrQuit) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ZegoLoggerService.logInfo(
            'try enable notification, '
            'isIOSSandboxEnvironment:${_data.isIOSSandboxEnvironment}',
            tag: 'call',
            subTag: 'prebuilt invitation',
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .enableNotifyWhenAppRunningInBackgroundOrQuit(
                true,
                isIOSSandboxEnvironment: _data.isIOSSandboxEnvironment,
              )
              .then((result) {
            ZegoLoggerService.logInfo(
              'enable notification result: $result',
              tag: 'call',
              subTag: 'prebuilt invitation',
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

    _isInit = false;

    await _uninitContext();
  }

  Future<void> _initPermissions() async {
    await requestPermission(Permission.camera);
    await requestPermission(Permission.microphone);
  }

  Future<void> _initContext() async {
    ZegoUIKit().login(_data.userID, _data.userName);
    await ZegoUIKit().init(appID: _data.appID, appSign: _data.appSign);

    ZegoUIKit.instance.turnCameraOn(false);

    _pageManager.init(
      ringtoneConfig: _data.ringtoneConfig,
    );
  }

  Future<void> _uninitContext() async {
    _notificationManager.uninit();
    _pageManager.uninit();
    await _plugins.uninit();
  }

  ZegoUIKitPrebuiltCallConfig _defaultConfig(ZegoCallInvitationData data) {
    final config = (data.invitees.length > 1)
        ? ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        : ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return config;
  }

  /// private variables

  ZegoUIKitPrebuiltCallInvitationService._internal();

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();

  bool _isInit = false;
  ContextQuery? _contextQuery;
  late ZegoUIKitPrebuiltCallInvitationServiceData _data;
  late ZegoInvitationPageManager _pageManager;
  late ZegoNotificationManager _notificationManager;
  late ZegoCallInvitationConfig _callInvitationConfig;
  late ZegoPrebuiltPlugins _plugins;
}

class ZegoUIKitPrebuiltCallInvitationServiceData {
  ZegoUIKitPrebuiltCallInvitationServiceData({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.plugins,
    this.requireConfig,
    this.showDeclineButton = true,
    this.events,
    this.notifyWhenAppRunningInBackgroundOrQuit = true,
    this.isIOSSandboxEnvironment = false,
    this.androidNotificationConfig,
    this.controller,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
        innerText = innerText ?? ZegoCallInvitationInnerText();

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// local user info
  final String userID;
  final String userName;

  final ZegoUIKitPrebuiltCallInvitationEvents? events;

  /// we need the [ZegoUIKitPrebuiltCallConfig] to show [ZegoUIKitPrebuiltCall]
  final PrebuiltConfigQuery? requireConfig;

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  ///
  final List<IZegoUIKitPlugin> plugins;

  /// whether to display the reject button, default is true
  final bool showDeclineButton;

  /// whether to enable offline notification, default is true
  final bool notifyWhenAppRunningInBackgroundOrQuit;

  /// iOS only
  final bool isIOSSandboxEnvironment;

  /// only for Android
  final ZegoAndroidNotificationConfig? androidNotificationConfig;

  final ZegoCallInvitationInnerText innerText;

  final ZegoUIKitPrebuiltCallController? controller;
}
