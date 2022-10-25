// Dart imports:

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/prebuilt_call_config.dart';

class ZegoUIKitPrebuiltCallInvitationService extends StatefulWidget {
  const ZegoUIKitPrebuiltCallInvitationService({
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
  ///   ZegoUIKitPrebuiltCallInvitationServiceConfig(
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
  State<ZegoUIKitPrebuiltCallInvitationService> createState() =>
      _ZegoUIKitPrebuiltCallInvitationServiceState();
}

enum CallInvitationNetworkState {
  unknown,
  offline,
  online,
}

class _ZegoUIKitPrebuiltCallInvitationServiceState
    extends State<ZegoUIKitPrebuiltCallInvitationService>
    with WidgetsBindingObserver {
  CallInvitationNetworkState networkState = CallInvitationNetworkState.unknown;
  List<StreamSubscription<dynamic>?> streamSubscriptions = [];
  PluginConnectionState pluginConnectionState =
      PluginConnectionState.disconnected;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    ZegoUIKit().installPlugins(widget.plugins);

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      debugPrint("versions: zego_uikit_prebuilt_call:1.2.5; $uikitVersion");
    });

    for (var pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        debugPrint("plugin-$pluginType:$version");
      });
    }

    Permission.camera.status.then((PermissionStatus status) {
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.permanentlyDenied) {
        Permission.camera.request();
      }
    });

    streamSubscriptions.add(ZegoUIKitInvitationService()
        .getInvitationConnectionStateStream()
        .listen(onInvitationConnectionState));

    streamSubscriptions
        .add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));

    initContext();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance?.removeObserver(this);

    super.dispose();

    for (var streamSubscription in streamSubscriptions) {
      streamSubscription?.cancel();
    }

    uninitContext();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallInvitationService oldWidget) {
    super.didUpdateWidget(oldWidget);

    reLoginContext(widget.userID, widget.userName);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("[call invitation] didChangeAppLifecycleState $state");

    switch (state) {
      case AppLifecycleState.resumed:
        reconnectIfDisconnected();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> initContext() async {
    await ZegoUIKitInvitationService()
        .init(widget.appID, appSign: widget.appSign);
    await ZegoUIKitInvitationService().login(widget.userID, widget.userName);

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

    // TODO: 这里的生命周期看下是否合理
    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().uninit();
  }

  Future<void> reLoginContext(String userID, String userName) async {
    var localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      debugPrint("same user, cancel this reLogin");
      return;
    }

    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().login(userID, userName);
  }

  void onInvitationConnectionState(Map params) {
    debugPrint("[call invitation] onInvitationConnectionState, param: $params");

    pluginConnectionState = PluginConnectionState.values[params['state']!];

    debugPrint(
        "[call invitation] onInvitationConnectionState, state: $pluginConnectionState");
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    debugPrint("[call invitation] onNetworkModeChanged $networkMode, "
        "network state: $networkState");

    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        networkState = CallInvitationNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        if (CallInvitationNetworkState.offline == networkState) {
          reconnectIfDisconnected();
        }
        networkState = CallInvitationNetworkState.online;
        break;
    }
  }

  void reconnectIfDisconnected() {
    debugPrint(
        "[call invitation] reconnectIfDisconnected, state:$pluginConnectionState");
    if (pluginConnectionState == PluginConnectionState.disconnected) {
      debugPrint(
          "[call invitation] reconnect, id:${widget.userID}, name:${widget.userName}");
      ZegoUIKitInvitationService().logout().then((value) {
        ZegoUIKitInvitationService().login(widget.userID, widget.userName);
      });
    }
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
