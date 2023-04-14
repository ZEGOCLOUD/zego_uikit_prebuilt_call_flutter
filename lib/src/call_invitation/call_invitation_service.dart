// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/handler.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoUIKitPrebuiltCallInvitationService with ZegoPrebuiltCallKitService {
  void useSystemCallingUI(List<IZegoUIKitPlugin> plugins) {
    ZegoLoggerService.logInfo(
      'using system calling ui, plugins size: ${plugins.length}',
      tag: 'call',
      subTag: 'invitation service',
    );

    ZegoUIKit().installPlugins(plugins);
    if (Platform.isAndroid) {
      ZegoUIKit()
          .getSignalingPlugin()
          .setBackgroundMessageHandler(onBackgroundMessageReceived);
    } else {
      _enableIOSVoIP = true;

      ZegoUIKit()
          .getSignalingPlugin()
          .setIncomingPushReceivedHandler(onIncomingPushReceived);

      initCallkitService();
    }
  }

  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  ZegoCallInvitationInnerText get innerText => _data.innerText;

  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data.events;

  ZegoRingtoneConfig get ringtoneConfig => _data.ringtoneConfig;

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController? get controller => _data.controller;

  CallKitParams? get callKitParams => _callKitParams;

  set callKitParams(value) => _callKitParams = value;

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
    String appName = '',
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallController? controller,
    Size? appDesignSize,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  }) async {
    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:3.2.0; $uikitVersion',
        tag: 'call',
        subTag: 'invitation service',
      );
    });

    if (_isInit) {
      await uninit();
    }

    _callKitParams = await getCurrentCallKitCall();
    ZegoLoggerService.logInfo(
      'callkit param: ${_callKitParams?.toJson()}',
      tag: 'call',
      subTag: 'invitation service',
    );
    await clearAllCallKitCalls();

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
        subTag: 'invitation service',
      );

      if (_data.notifyWhenAppRunningInBackgroundOrQuit) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ZegoLoggerService.logInfo(
            'try enable notification, '
            'isIOSSandboxEnvironment:${_data.isIOSSandboxEnvironment}, '
            'enableIOSVoIP:$_enableIOSVoIP ',
            tag: 'call',
            subTag: 'invitation service',
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .enableNotifyWhenAppRunningInBackgroundOrQuit(
                true,
                isIOSSandboxEnvironment: _data.isIOSSandboxEnvironment,
                enableIOSVoIP: _enableIOSVoIP,
                appName: appName,
              )
              .then((result) {
            ZegoLoggerService.logInfo(
              'enable notification result: $result',
              tag: 'call',
              subTag: 'invitation service',
            );
          });
        });
      }
    });

    FlutterCallkitIncoming.onEvent.listen(_initCallKitIncomingEvent);

    await _initPermissions().then((value) => _initContext());
  }

  Future<void> uninit() async {
    if (!_isInit) {
      return;
    }

    _isInit = false;

    uninitCallkitService();

    await _uninitContext();
  }

  void setCallKitVariables(Map<CallKitInnerVariable, dynamic> variables) {
    SharedPreferences.getInstance().then((prefs) {
      variables.forEach((key, value) {
        switch (key) {
          case CallKitInnerVariable.duration:
            prefs.setDouble(key.cacheKey, value as double? ?? key.defaultValue);
            break;
          case CallKitInnerVariable.textAccept:
          case CallKitInnerVariable.textDecline:
          case CallKitInnerVariable.textMissedCall:
          case CallKitInnerVariable.textCallback:
          case CallKitInnerVariable.backgroundColor:
          case CallKitInnerVariable.backgroundUrl:
          case CallKitInnerVariable.actionColor:
          case CallKitInnerVariable.iconName:
          case CallKitInnerVariable.textAppName:
            prefs.setString(key.cacheKey, value as String? ?? key.defaultValue);
            break;
        }
      });
    });
  }

  void didChangeAppLifecycleState(bool isAppInBackground) {
    if (!_isInit) {
      return;
    }

    _pageManager.didChangeAppLifecycleState(isAppInBackground);
  }

  /// for popup if app in background
  void _initCallKitIncomingEvent(CallEvent? event) {
    ZegoLoggerService.logInfo(
      'callkit incoming event, body:${event?.body}, event:${event?.event}',
      tag: 'call',
      subTag: 'invitation service',
    );

    switch (event!.event) {
      case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
      case Event.ACTION_CALL_INCOMING:
      case Event.ACTION_CALL_START:
        break;
      case Event.ACTION_CALL_ACCEPT:
        _pageManager.hasCallkitIncomingCauseAppInBackground = false;
        final callKitParams =
            convertCallKitCallToParam(event.body as Map<dynamic, dynamic>);
        ZegoLoggerService.logInfo(
          'callkit param: ${callKitParams?.toJson()}',
          tag: 'call',
          subTag: 'invitation service',
        );

        if (callKitParams != null &&
            callKitParams.id == _pageManager.invitationData.callID) {
          ZegoLoggerService.logInfo(
            'auto agree, cause exist callkit params same as current call',
            tag: 'call',
            subTag: 'invitation service',
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .acceptInvitation(
                  inviterID: _pageManager.invitationData.inviter?.id ?? '',
                  data: '')
              .then((result) {
            _pageManager.onLocalAcceptInvitation(
              result.error?.code ?? '',
              result.error?.message ?? '',
            );
          });
        }

        break;
      case Event.ACTION_CALL_DECLINE:
      case Event.ACTION_CALL_TIMEOUT:
        if (_pageManager.hasCallkitIncomingCauseAppInBackground) {
          _pageManager.hasCallkitIncomingCauseAppInBackground = false;
          ZegoUIKit()
              .getSignalingPlugin()
              .refuseInvitation(
                inviterID: _pageManager.invitationData.inviter?.id ?? '',
                data: '{"reason":"decline"}',
              )
              .then((result) {
            _pageManager.onLocalRefuseInvitation(
                result.error?.code ?? '', result.error?.message ?? '');
          });
        }

        break;
      case Event.ACTION_CALL_ENDED:
        _pageManager.hasCallkitIncomingCauseAppInBackground = false;
        break;
      case Event.ACTION_CALL_CALLBACK:
      case Event.ACTION_CALL_TOGGLE_HOLD:
      case Event.ACTION_CALL_TOGGLE_MUTE:
      case Event.ACTION_CALL_TOGGLE_DMTF:
      case Event.ACTION_CALL_TOGGLE_GROUP:
      case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        break;
    }
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

  /// callkit
  bool _enableIOSVoIP = false;
  CallKitParams? _callKitParams;
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
