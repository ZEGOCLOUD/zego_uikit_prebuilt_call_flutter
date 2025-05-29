// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/controller/private/pip/pip_interface.dart';

class ZegoCallControllerIOSPIP extends ZegoCallControllerPIPInterface {
  final _private = ZegoCallControllerPIPImplPrivateIOS();

  bool get isSupportInConfig => _private.isSupportInConfig;

  @override
  bool get isRestoredFromPIP => false;

  @override
  Future<bool> get available async {
    return _private.available;
  }

  @override
  Future<void> cancelBackground() async {}

  @override
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'enablePIPInIOS',
      );

      return ZegoPiPStatus.unavailable;
    }

    if (!_private.isSupportInConfig) {
      ZegoLoggerService.logInfo(
        'not enable PIP in config',
        tag: 'uikit-channel',
        subTag: 'enablePIPInIOS',
      );

      return ZegoPiPStatus.unavailable;
    }

    ZegoUIKit().backToDesktop();
    return ZegoPiPStatus.enabled;
  }

  @override
  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    var status = ZegoPiPStatus.unavailable;
    try {
      status = await _private.enableWhenBackground(
        aspectWidth: aspectWidth,
        aspectHeight: aspectHeight,
      );
    } catch (e) {
      ZegoLoggerService.logInfo(
        'enableWhenBackground exception:${e.toString()}',
        tag: 'call',
        subTag: 'controller.pip',
      );
    }
    return status;
  }

  @override
  Future<ZegoPiPStatus> get status async => ZegoPiPStatus.unavailable;

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  @override
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    await _private.initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  @override
  void uninitByPrebuilt() {
    _private.uninitByPrebuilt();
  }
}

class ZegoCallControllerPIPImplPrivateIOS {
  ZegoUIKitPrebuiltCallConfig? config;
  StreamSubscription<dynamic>? subscription;
  bool? _isSupportInConfig;
  bool? _isAvailable;

  bool get available {
    if (null != _isAvailable) {
      return _isAvailable!;
    }

    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    _isAvailable == systemVersion.major >= 15;
    return _isAvailable!;
  }

  bool get isSupportInConfig {
    if (null == _isSupportInConfig) {
      _isSupportInConfig = config?.pip.iOS.support ?? true;
      if (_isSupportInConfig!) {
        final systemVersion = ZegoUIKit().getMobileSystemVersion();
        if (systemVersion.major < 15) {
          ZegoLoggerService.logInfo(
            'not support pip smaller than 15',
            tag: 'call',
            subTag: 'controller.pip',
          );

          _isSupportInConfig = false;
        }
      }
    }

    return _isSupportInConfig!;
  }

  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p ios',
    );

    this.config = config;

    if (!Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'initByPrebuilt, only support iOS',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return;
    }

    ZegoUIKitPrebuiltCallController()
        .minimize
        .private
        .activeUser
        .activeUserIDNotifier
        .addListener(onMinimizeActiveUserChanged);
    ZegoUIKitPrebuiltCallController()
        .minimize
        .private
        .isMinimizingNotifier
        .addListener(onMinimizeStateChanged);

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

    if (isSupportInConfig) {
      if (config?.pip.enableWhenBackground ?? true) {
        await enableWhenBackground(
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
    }
  }

  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p ios',
    );

    config = null;

    subscription?.cancel();

    ZegoUIKitPrebuiltCallController()
        .minimize
        .private
        .activeUser
        .activeUserIDNotifier
        .removeListener(onMinimizeActiveUserChanged);
    ZegoUIKitPrebuiltCallController()
        .minimize
        .private
        .isMinimizingNotifier
        .removeListener(onMinimizeStateChanged);

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);
  }

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final systemVersion = ZegoUIKit().getMobileSystemVersion();
    if (systemVersion.major < 15) {
      ZegoLoggerService.logInfo(
        'not support smaller than 15',
        tag: 'uikit-channel',
        subTag: 'enableWhenBackground',
      );

      return ZegoPiPStatus.unavailable;
    }

    if (isSupportInConfig) {
      await ZegoUIKit().enableIOSPIPAuto(
        true,
        aspectWidth: aspectWidth,
        aspectHeight: aspectHeight,
      );
      return ZegoPiPStatus.enabled;
    }

    return ZegoPiPStatus.unavailable;
  }

  void onMinimizeActiveUserChanged() {
    /// not support if ios pip, platform view will be render wrong user
    /// after changed
    // final targetUserID = ZegoUIKitPrebuiltCallController()
    //         .minimize
    //         .private
    //         .activeUser
    //         .activeUserIDNotifier
    //         .value ??
    //     '';
    //
    // ZegoLoggerService.logInfo(
    //   'onMinimizeActiveUserChanged, $targetUserID',
    //   tag: 'call',
    //   subTag: 'controller.pip.p ios',
    // );
    //
    // if (ZegoUIKit().getLocalUser().id != targetUserID) {
    //   ZegoUIKit().updateIOSPIPSource(
    //     ZegoUIKit().getUser(targetUserID).streamID,
    //   );
    // }
  }

  void onMinimizeStateChanged() async {
    await forceUpdatePIPVC();
  }

  Future<void> forceUpdatePIPVC() async {
    if (ZegoUIKitPrebuiltCallController().minimize.isMinimizing) {
      final currentActiveUserID = ZegoUIKitPrebuiltCallController()
              .minimize
              .private
              .activeUser
              .activeUserIDNotifier
              .value ??
          '';

      /// new pip vc
      if (ZegoUIKit().getLocalUser().id != currentActiveUserID) {
        await ZegoUIKit().enableIOSPIP(
          ZegoUIKit().getUser(currentActiveUserID).streamID,
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
    }
  }

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    ZegoLoggerService.logInfo(
      '_onAppLifecycleStateChanged, $appLifecycleState',
      tag: 'call',
      subTag: 'controller.pip.p ios',
    );

    if (!isSupportInConfig) {
      return;
    }

    if (AppLifecycleState.resumed == appLifecycleState) {
      await ZegoUIKit().stopIOSPIP();
      await forceUpdatePIPVC();
    } else if (AppLifecycleState.inactive == appLifecycleState) {
      /// pip need render remote user's stream, local can not render
      if (ZegoUIKitPrebuiltCallController().minimize.isMinimizing) {
        ZegoUIKitPrebuiltCallController()
            .minimize
            .private
            .activeUser
            .switchActiveUserToRemoteUser();
      }
    }
  }
}
