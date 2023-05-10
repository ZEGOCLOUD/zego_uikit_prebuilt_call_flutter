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
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

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

part 'internal/call_invitation_service_p.dart';

class ZegoUIKitPrebuiltCallInvitationService
    with
        ZegoPrebuiltCallKitService,
        ZegoUIKitPrebuiltCallInvitationServicePrivate {
  factory ZegoUIKitPrebuiltCallInvitationService() => _instance;

  ZegoCallInvitationInnerText get innerText => _data.innerText;

  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data.events;

  ZegoRingtoneConfig get ringtoneConfig => _data.ringtoneConfig;

  ZegoAndroidNotificationConfig? get androidNotificationConfig =>
      _data.androidNotificationConfig;

  ZegoUIKitPrebuiltCallController? get controller => _data.controller;

  String? get callKitCallID => _callKitCallID;

  set callKitCallID(value) => _callKitCallID = value;

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
    ZegoUIKitPrebuiltCallInvitationEvents? events,
    bool notifyWhenAppRunningInBackgroundOrQuit = true,
    bool? isIOSSandboxEnvironment,
    String appName = '',
    // ZegoIOSNotificationConfig? iOSNotificationConfig,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallController? controller,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  }) async {
    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:3.3.11; $uikitVersion',
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
    SystemChannels.lifecycle.setMessageHandler((state) async {
      if (!_isInit) {
        return;
      }

      _pageManager.didChangeAppLifecycleState(
        state != AppLifecycleState.resumed.toString(),
      );
    });

    _callKitCallID = await getCurrentCallKitCallID();
    ZegoLoggerService.logInfo(
      'callkit call id: $_callKitCallID',
      tag: 'call',
      subTag: 'call invitation service',
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
      // iOSNotificationConfig: iOSNotificationConfig,
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
        'plugin init finished, notifyWhenAppRunningInBackgroundOrQuit:'
        '${_data.notifyWhenAppRunningInBackgroundOrQuit}',
        tag: 'call',
        subTag: 'call invitation service',
      );

      if (_data.notifyWhenAppRunningInBackgroundOrQuit) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ZegoLoggerService.logInfo(
            'try enable notification, '
            'isIOSSandboxEnvironment:${_data.isIOSSandboxEnvironment}, '
            // 'iOSNotificationConfig:${_data.iOSNotificationConfig.toString()}, '
            'enableIOSVoIP:$_enableIOSVoIP ',
            tag: 'call',
            subTag: 'call invitation service',
          );
          // if (_data.isIOSSandboxEnvironment != null) {
          //   assert(false);
          //   ZegoLoggerService.logInfo(
          //     'isIOSSandboxEnvironment is deprecated, use iOSNotificationConfig.isIOSSandboxEnvironment instead',
          //     tag: 'call',
          //     subTag: 'call invitation service',
          //   );
          // }

          ZegoUIKit()
              .getSignalingPlugin()
              .enableNotifyWhenAppRunningInBackgroundOrQuit(
                true,
                isIOSSandboxEnvironment: _data.isIOSSandboxEnvironment ?? false,
                enableIOSVoIP: _enableIOSVoIP,
                appName: appName,
              )
              .then((result) {
            if (_enableIOSVoIP) {
              ZegoUIKit().getSignalingPlugin().setInitConfiguration(
                    ZegoSignalingPluginProviderConfiguration(
                      localizedName: appName,
                      iconTemplateImageName:
                          // _data.iOSNotificationConfig?.systemCallingIconName ??
                          'AppIcon',
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

    ZegoLoggerService.logInfo(
      'register callkit incoming event listener',
      tag: 'call',
      subTag: 'call invitation service',
    );
    FlutterCallkitIncoming.onEvent.listen(_initCallKitIncomingEvent);

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

    if (Platform.isIOS) {
      uninitCallkitService();
    }

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

      initCallkitService();
    }
  }

  void setCallKitVariables(Map<CallKitInnerVariable, dynamic> variables) {
    ZegoLoggerService.logInfo(
      'set callkit variables:$variables',
      tag: 'call',
      subTag: 'call invitation service',
    );

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

  @Deprecated('Since 3.3.3')
  void didChangeAppLifecycleState(bool isAppInBackground) {}

  /// for popup top notify window if app in background
  void _initCallKitIncomingEvent(CallEvent? event) {
    ZegoLoggerService.logInfo(
      'callkit incoming event, body:${event?.body}, event:${event?.event}',
      tag: 'call',
      subTag: 'call invitation service',
    );

    switch (event!.event) {
      case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
      case Event.ACTION_CALL_INCOMING:
      case Event.ACTION_CALL_START:
        break;
      case Event.ACTION_CALL_ACCEPT:
        final callKitCallID =
            convertCallKitCallToParam(event.body as Map<dynamic, dynamic>)
                ?.handle;
        acceptCallKitIncomingCauseInBackground(callKitCallID);
        break;
      case Event.ACTION_CALL_DECLINE:
      case Event.ACTION_CALL_TIMEOUT:
        refuseCallKitIncomingCauseInBackground();
        break;
      case Event.ACTION_CALL_ENDED:
        _pageManager.hasCallkitIncomingCauseAppInBackground = false;

        if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
          handUpCurrentCallByCallKit();
        }
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

  void acceptCallKitIncomingCauseInBackground(
    String? callKitCallID,
  ) {
    if (!_pageManager.hasCallkitIncomingCauseAppInBackground) {
      ZegoLoggerService.logInfo(
        'accept invitation, but has not callkit incoming cause by app in background',
        tag: 'call',
        subTag: 'call invitation service',
      );

      _pageManager.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
          true;

      return;
    }

    _pageManager.hasCallkitIncomingCauseAppInBackground = false;
    ZegoLoggerService.logInfo(
      'callkit call id: $callKitCallID',
      tag: 'call',
      subTag: 'call invitation service',
    );

    if (callKitCallID != null &&
        callKitCallID == _pageManager.invitationData.callID) {
      ZegoLoggerService.logInfo(
        'auto agree, cause exist callkit params same as current call',
        tag: 'call',
        subTag: 'call invitation service',
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
  }

  void handUpCurrentCallByCallKit() {
    ZegoLoggerService.logInfo(
      'hang up by call kit',
      tag: 'call',
      subTag: 'call invitation service',
    );

    ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'call invitation service',
      );
    });

    Navigator.of(_contextQuery!.call()).pop();
  }

  void refuseCallKitIncomingCauseInBackground() {
    if (!_pageManager.hasCallkitIncomingCauseAppInBackground) {
      ZegoLoggerService.logInfo(
        'refuse invitation, but has not callkit incoming cause by app in background',
        tag: 'call',
        subTag: 'call invitation service',
      );

      return;
    }

    _pageManager.hasCallkitIncomingCauseAppInBackground = false;

    ZegoLoggerService.logInfo(
      'refuse invitation(${_pageManager.invitationData.toString()}) by callkit',
      tag: 'call',
      subTag: 'call invitation service',
    );

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

  ZegoUIKitPrebuiltCallInvitationService._internal();

  static final ZegoUIKitPrebuiltCallInvitationService _instance =
      ZegoUIKitPrebuiltCallInvitationService._internal();
}
