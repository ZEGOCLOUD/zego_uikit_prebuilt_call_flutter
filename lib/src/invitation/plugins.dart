// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';

/// @nodoc
enum ZegoCallPluginNetworkState {
  unknown,
  offline,
  online,
}

/// @nodoc
class ZegoCallPrebuiltPlugins {
  ZegoCallPrebuiltPlugins({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.plugins,
    this.onPluginReLogin,
    required this.onError,
  }) {
    _install();
  }

  final int appID;
  final String appSign;
  final String token;

  final String userID;
  final String userName;

  final List<IZegoUIKitPlugin> plugins;

  final VoidCallback? onPluginReLogin;

  Function(ZegoUIKitError)? onError;

  ZegoCallPluginNetworkState networkState = ZegoCallPluginNetworkState.unknown;
  List<StreamSubscription<dynamic>?> subscriptions = [];
  ValueNotifier<ZegoSignalingPluginConnectionState> pluginUserStateNotifier =
      ValueNotifier<ZegoSignalingPluginConnectionState>(
          ZegoSignalingPluginConnectionState.disconnected);
  bool tryReLogging = false;
  bool initialized = false;

  bool get isEnabled => plugins.isNotEmpty;

  void _install() {
    ZegoUIKit().installPlugins(plugins);
    for (final pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        ZegoLoggerService.logInfo(
          'plugin-$pluginType version: $version',
          tag: 'call-invitation',
          subTag: 'plugin',
        );
      });

      if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) !=
          null) {
        subscriptions.add(ZegoUIKit()
            .getSignalingPlugin()
            .getErrorStream()
            .listen(onSignalingError));
      }
    }

    pluginUserStateNotifier.value =
        ZegoUIKit().getSignalingPlugin().getConnectionState();

    subscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getConnectionStateStream()
          .listen(onInvitationConnectionState))
      ..add(ZegoUIKit().getNetworkModeStream().listen(onNetworkModeChanged));
  }

  Future<void> init({Future<void> Function()? onPluginInit}) async {
    ZegoLoggerService.logInfo(
      'plugins init',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
    await ZegoUIKit()
        .getSignalingPlugin()
        .init(appID, appSign: appSign)
        .then((value) async {
      await onPluginInit?.call();
    });

    ZegoLoggerService.logInfo(
      'plugins init done, login...',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
    await ZegoUIKit().getSignalingPlugin().login(
          id: userID,
          name: userName,
          token: token,
        );
    ZegoLoggerService.logInfo(
      'plugins login done',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
    initialized = true;

    setPreferenceString(serializationKeyAppSign, appSign, withEncode: true);

    ZegoLoggerService.logInfo(
      'plugins init done',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
  }

  Future<void> uninit() async {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
    initialized = false;

    removePreferenceValue(serializationKeyAppSign);
    removePreferenceValue(serializationKeyHandlerInfo);

    tryReLogging = false;

    /// not need logout
    // await ZegoUIKit().getSignalingPlugin().logout();
    /// not need destroy signaling sdk
    await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: false);

    for (final streamSubscription in subscriptions) {
      streamSubscription?.cancel();
    }
  }

  Future<void> onUserInfoUpdate(String userID, String userName) async {
    final localUser = ZegoUIKit().getLocalUser();

    ZegoLoggerService.logInfo(
      'on user info update, '
      'target user($userID, $userName), '
      'local user:($localUser) '
      'initialized:$initialized, '
      'user state:${pluginUserStateNotifier.value}',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        'onUserInfoUpdate, plugin is not init',
        tag: 'call-invitation',
        subTag: 'plugin',
      );
      return;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.connected) {
      ZegoLoggerService.logInfo(
        'onUserInfoUpdate, user state is not connected',
        tag: 'call-invitation',
        subTag: 'plugin',
      );
      return;
    }

    if (localUser.id == userID && localUser.name == userName) {
      ZegoLoggerService.logInfo(
        'same user, cancel this re-login',
        tag: 'call-invitation',
        subTag: 'plugin',
      );
      return;
    }

    await ZegoUIKit().getSignalingPlugin().logout();
    await ZegoUIKit().getSignalingPlugin().login(
          id: userID,
          name: userName,
          token: token,
        );
  }

  void onInvitationConnectionState(
      ZegoSignalingPluginConnectionStateChangedEvent event) {
    ZegoLoggerService.logInfo(
      '[call invitation] onInvitationConnectionState, $event',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    pluginUserStateNotifier.value = event.state;

    if (tryReLogging &&
        pluginUserStateNotifier.value ==
            ZegoSignalingPluginConnectionState.connected) {
      tryReLogging = false;
      onPluginReLogin?.call();
    }
  }

  void onSignalingError(ZegoSignalingError error) {
    ZegoLoggerService.logError(
      'on signaling error:$error',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    onError?.call(ZegoUIKitError(
      code: error.code,
      message: error.message,
      method: error.method,
    ));
  }

  void didChangeAppLifecycleState(bool isAppInBackground) {
    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState, isAppInBackground:$isAppInBackground',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    if (!isAppInBackground) {
      ZegoLoggerService.logInfo(
        'app active from background, try re-login',
        tag: 'call-invitation',
        subTag: 'plugin',
      );

      tryReLogin();
    }
  }

  void onNetworkModeChanged(ZegoNetworkMode networkMode) {
    ZegoLoggerService.logInfo(
      'onNetworkModeChanged $networkMode, previous '
      'network state: $networkState',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    switch (networkMode) {
      case ZegoNetworkMode.Offline:
      case ZegoNetworkMode.Unknown:
        networkState = ZegoCallPluginNetworkState.offline;
        break;
      case ZegoNetworkMode.Ethernet:
      case ZegoNetworkMode.WiFi:
      case ZegoNetworkMode.Mode2G:
      case ZegoNetworkMode.Mode3G:
      case ZegoNetworkMode.Mode4G:
      case ZegoNetworkMode.Mode5G:
        if (ZegoCallPluginNetworkState.offline == networkState) {
          tryReLogin();
        }

        networkState = ZegoCallPluginNetworkState.online;
        break;
    }
  }

  Future<void> tryReLogin() async {
    ZegoLoggerService.logInfo(
      'tryReLogin, initialized:$initialized, '
      'state:${pluginUserStateNotifier.value}',
      tag: 'call-invitation',
      subTag: 'plugin',
    );

    if (!initialized) {
      ZegoLoggerService.logInfo(
        'tryReLogin, plugin is not init',
        tag: 'call-invitation',
        subTag: 'plugin',
      );
      return;
    }

    if (pluginUserStateNotifier.value !=
        ZegoSignalingPluginConnectionState.disconnected) {
      ZegoLoggerService.logInfo(
        'tryReLogin, user state is not disconnected',
        tag: 'call-invitation',
        subTag: 'plugin',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      're-login, id:$userID, name:$userName',
      tag: 'call-invitation',
      subTag: 'plugin',
    );
    tryReLogging = true;
    await ZegoUIKit().getSignalingPlugin().logout().then((value) async {
      await ZegoUIKit().getSignalingPlugin().login(
            id: userID,
            name: userName,
            token: token,
          );
    });
  }
}
