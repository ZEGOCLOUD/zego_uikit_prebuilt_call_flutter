// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/prebuilt_call_config.dart';
import 'plugins.dart';

class ZegoUIKitPrebuiltCallWithInvitation extends StatefulWidget {
  const ZegoUIKitPrebuiltCallWithInvitation({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.child,
    required this.plugins,
    this.tokenServerUrl = '',
    this.requireConfig,
    ZegoRingtoneConfig? ringtoneConfig,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
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

  ///
  final ConfigQuery? requireConfig;

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  final Widget child;

  final List<IZegoUIKitPlugin> plugins;

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

    WidgetsBinding.instance?.addObserver(this);

    plugins = ZegoPrebuiltPlugins(
      appID: widget.appID,
      appSign: widget.appSign,
      userID: widget.userID,
      userName: widget.userName,
      plugins: widget.plugins,
    );
    plugins?.init();

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      debugPrint("versions: zego_uikit_prebuilt_call:1.2.9; $uikitVersion");
    });

    initPermissions().then((value) => initContext());
  }

  @override
  void dispose() async {
    super.dispose();

    WidgetsBinding.instance?.removeObserver(this);

    plugins?.uninit();

    uninitContext();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallWithInvitation oldWidget) {
    super.didUpdateWidget(oldWidget);

    plugins?.onUserInfoUpdate(widget.userID, widget.userName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("[call invitation] didChangeAppLifecycleState $state");

    switch (state) {
      case AppLifecycleState.resumed:
        plugins?.reconnectIfDisconnected();
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
      configQuery: widget.requireConfig ?? defaultConfig,
      contextQuery: () {
        return context;
      },
      ringtoneConfig: widget.ringtoneConfig,
    );
  }

  void uninitContext() async {
    ZegoInvitationPageManager.instance.uninit();
  }

  ZegoUIKitPrebuiltCallConfig defaultConfig(ZegoCallInvitationData data) {
    var config = (data.invitees.length > 1)
        ? ZegoInvitationType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        : ZegoInvitationType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return config;
  }
}

@Deprecated('Use [ZegoUIKitPrebuiltInvitationCall]')
typedef ZegoUIKitPrebuiltCallInvitationService
    = ZegoUIKitPrebuiltCallWithInvitation;
