// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/notification_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/plugins.dart';

class ZegoUIKitPrebuiltCallWithInvitation extends StatefulWidget {
  ZegoUIKitPrebuiltCallWithInvitation({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.child,
    required this.plugins,
    this.tokenServerUrl = '',
    this.requireConfig,
    this.showDeclineButton = true,
    this.events,
    this.notifyWhenAppRunningInBackgroundOrQuit = true,
    this.isIOSSandboxEnvironment = false,
    this.androidNotificationConfig,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
        innerText = innerText ?? ZegoCallInvitationInnerText(),
        super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltInvitationCall(
  ///     appID: appID,
  ///     userID: userID,
  ///     userName: userName,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  final ZegoUIKitPrebuiltCallInvitationEvents? events;

  /// we need the [ZegoUIKitPrebuiltCallConfig] to show [ZegoUIKitPrebuiltCall]
  final PrebuiltConfigQuery? requireConfig;

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  /// your Widget that receive
  final Widget child;

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

  @override
  State<ZegoUIKitPrebuiltCallWithInvitation> createState() =>
      _ZegoUIKitPrebuiltCallWithInvitationState();
}

class _ZegoUIKitPrebuiltCallWithInvitationState
    extends State<ZegoUIKitPrebuiltCallWithInvitation>
    with WidgetsBindingObserver {
  ZegoPrebuiltPlugins? plugins;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ZegoNotificationManager.instance.init(events: widget.events);

    plugins = ZegoPrebuiltPlugins(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      plugins: widget.plugins,
    );
    plugins?.init().then((value) {
      ZegoLoggerService.logInfo(
        '[call ] plugin init finished, notifyWhenAppRunningInBackgroundOrQuit:'
        '${widget.notifyWhenAppRunningInBackgroundOrQuit}',
        tag: 'call',
        subTag: 'prebuilt invitation',
      );
      if (widget.notifyWhenAppRunningInBackgroundOrQuit) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ZegoLoggerService.logInfo(
            'try enable notification, '
            'isIOSSandboxEnvironment:${widget.isIOSSandboxEnvironment}',
            tag: 'call',
            subTag: 'prebuilt invitation',
          );

          ZegoUIKit()
              .getSignalingPlugin()
              .enableNotifyWhenAppRunningInBackgroundOrQuit(
                true,
                isIOSSandboxEnvironment: widget.isIOSSandboxEnvironment,
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

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      ZegoLoggerService.logInfo(
        'versions: zego_uikit_prebuilt_call:1.4.2; $uikitVersion',
        tag: 'call',
        subTag: 'prebuilt invitation',
      );
    });

    initPermissions().then((value) => initContext());
  }

  @override
  void dispose() async {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);

    plugins?.uninit();

    uninitContext();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallWithInvitation oldWidget) {
    super.didUpdateWidget(oldWidget);

    ZegoInvitationPageManager.instance.updateInvitationConfig(
      widget.showDeclineButton,
      widget.androidNotificationConfig,
      widget.events,
      widget.innerText,
    );
    plugins?.onUserInfoUpdate(widget.userID, widget.userName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState $state',
      tag: 'call',
      subTag: 'prebuilt invitation',
    );

    ZegoInvitationPageManager.instance
        .didChangeAppLifecycleState(state != AppLifecycleState.resumed);

    switch (state) {
      case AppLifecycleState.resumed:
        plugins?.tryReLogin();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> initPermissions() async {
    await requestPermission(Permission.camera);
    await requestPermission(Permission.microphone);
  }

  Future<void> initContext() async {
    ZegoUIKit().login(widget.userID, widget.userName).then((value) {
      ZegoUIKit().init(appID: widget.appID, appSign: widget.appSign);

      ZegoUIKit.instance.turnCameraOn(false);
    });

    ZegoInvitationPageManager.instance.init(
      appID: widget.appID,
      appSign: widget.appSign,
      tokenServerUrl: widget.tokenServerUrl,
      userID: widget.userID,
      userName: widget.userName,
      prebuiltConfigQuery: widget.requireConfig ?? defaultConfig,
      contextQuery: () {
        return context;
      },
      notifyWhenAppRunningInBackgroundOrQuit:
          widget.notifyWhenAppRunningInBackgroundOrQuit,
      showDeclineButton: widget.showDeclineButton,
      androidNotificationConfig: widget.androidNotificationConfig,
      invitationEvents: widget.events,
      innerText: widget.innerText,
      ringtoneConfig: widget.ringtoneConfig,
    );
  }

  void uninitContext() async {
    ZegoInvitationPageManager.instance.uninit();
  }

  ZegoUIKitPrebuiltCallConfig defaultConfig(ZegoCallInvitationData data) {
    final config = (data.invitees.length > 1)
        ? ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        : ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return config;
  }
}

@Deprecated('Use [ZegoUIKitPrebuiltCallWithInvitation]')
typedef ZegoUIKitPrebuiltCallInvitationService
    = ZegoUIKitPrebuiltCallWithInvitation;
