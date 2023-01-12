// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

enum PluginNetworkState {
  unknown,
  offline,
  online,
}

class ZegoPrebuiltPlugins {
  final int appID;
  final String appSign;

  final String userID;
  final String userName;

  final List<IZegoUIKitPlugin> plugins;

  final VoidCallback? onPluginReLogin;

  ZegoPrebuiltPlugins(
      {required this.appID,
      required this.appSign,
      required this.userID,
      required this.userName,
      required this.plugins,
      this.onPluginReLogin}) {
    _install();
  }

  PluginNetworkState networkState = PluginNetworkState.unknown;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  var pluginUserStateNotifier =
      ValueNotifier<PluginConnectionState>(PluginConnectionState.disconnected);
  bool tryReLogging = false;
  bool initialized = false;

  bool get isEnabled => plugins.isNotEmpty;

  void _install() {
    ZegoUIKit().installPlugins(plugins);
    for (var pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        ZegoLoggerService.logInfo(
          "plugin-$pluginType:$version",
          tag: "call",
          subTag: "plugin",
        );
      });
    }

    subscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(onUserConnectionState))
      ..add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));
  }

  Future<void> init() async {
    ZegoLoggerService.logInfo(
      "plugins init",
      tag: "call",
      subTag: "plugin",
    );

    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) {
      ZegoLoggerService.logInfo(
        "plugins init done",
        tag: "call",
        subTag: "plugin",
      );
    });

    ZegoLoggerService.logInfo(
      "plugins init, login...",
      tag: "call",
      subTag: "plugin",
    );
    await ZegoUIKit()
        .getSignalingPlugin()
        .login(userID, userName)
        .then((value) async {
      ZegoLoggerService.logInfo(
        "plugins login done",
        tag: "call",
        subTag: "plugin",
      );
    });

    initialized = true;

    ZegoLoggerService.logInfo(
      "plugins init done",
      tag: "call",
      subTag: "plugin",
    );
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      "uninit",
      tag: "call",
      subTag: "plugin",
    );
    initialized = false;

    tryReLogging = false;

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().uninit();

    for (var streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<void> onUserInfoUpdate(String userID, String userName) async {
    var localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      ZegoLoggerService.logInfo(
        "same user, cancel this re-login",
        tag: "call",
        subTag: "plugin",
      );
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(userID, userName);
  }

  void onUserConnectionState(Map params) {
    ZegoLoggerService.logInfo(
      "onUserConnectionState, param: $params",
      tag: "call",
      subTag: "plugin",
    );

    pluginUserStateNotifier.value =
        PluginConnectionState.values[params['state']!];

    ZegoLoggerService.logInfo(
      "onUserConnectionState, user state: ${pluginUserStateNotifier.value}",
      tag: "call",
      subTag: "plugin",
    );

    if (tryReLogging &&
        pluginUserStateNotifier.value == PluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    ZegoLoggerService.logInfo(
      "onNetworkModeChanged $networkMode, previous network state: $networkState",
      tag: "call",
      subTag: "plugin",
    );

    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        networkState = PluginNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        if (PluginNetworkState.offline == networkState) {
          tryReLogin();
        }

        networkState = PluginNetworkState.online;
        break;
    }
  }

  Future<void> tryReLogin() async {
    ZegoLoggerService.logInfo(
      "tryReLogin, initialized:$initialized, state:${pluginUserStateNotifier.value}",
      tag: "call",
      subTag: "plugin",
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        "tryReLogin, plugin is not init",
        tag: "call",
        subTag: "plugin",
      );
      return;
    }

    if (pluginUserStateNotifier.value != PluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo(
        "tryReLogin, user state is not disconnected",
        tag: "call",
        subTag: "plugin",
      );
      return;
    }

    ZegoLoggerService.logInfo(
      "re-login, id:$userID, name:$userName",
      tag: "call",
      subTag: "plugin",
    );
    tryReLogging = true;
    return await ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(userID, userName);
    });
  }
}
