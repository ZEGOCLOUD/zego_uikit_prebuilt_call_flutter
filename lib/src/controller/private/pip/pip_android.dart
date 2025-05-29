// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:floating/floating.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/controller/private/pip/pip_interface.dart';

class ZegoCallControllerPIPAndroid implements ZegoCallControllerPIPInterface {
  final _private = ZegoCallControllerPIPImplPrivateAndroid();

  Floating get floating => _private.floating;

  @override
  bool get isRestoredFromPIP => _private.isRestoredFromPIP;

  @override
  Future<ZegoPiPStatus> get status async =>
      (await _private.floating.pipStatus).toZego();

  @override
  Future<bool> get available async => await _private.floating.isPipAvailable;

  @override
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final isPipAvailable = await _private.floating.isPipAvailable;
    if (!isPipAvailable) {
      ZegoLoggerService.logError(
        'enable, '
        'but pip is not available, ',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return ZegoPiPStatus.unavailable;
    }

    var status = ZegoPiPStatus.unavailable;
    try {
      status = (await _private.floating.enable(
        ImmediatePiP(
          aspectRatio: Rational(aspectWidth, aspectHeight),
        ),
      ))
          .toZego();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'enable exception:${e.toString()}',
        tag: 'call',
        subTag: 'controller.pip',
      );
    }
    return status;
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
  Future<void> cancelBackground() async {
    /// back to app
    await ZegoUIKit().activeAppToForeground();

    try {
      await _private.floating.cancelOnLeavePiP();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'cancelOnLeavePiP exception:${e.toString()}',
        tag: 'call',
        subTag: 'controller.pip',
      );
    }
  }

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

class ZegoCallControllerPIPImplPrivateAndroid {
  final floating = Floating();
  ZegoUIKitPrebuiltCallConfig? config;

  bool isInPIP = false;
  bool isRestoredFromPIP = false;

  StreamSubscription<dynamic>? subscription;

  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p android',
    );

    this.config = config;

    ZegoUIKitPrebuiltCallController()
        .minimize
        .private
        .isMinimizingNotifier
        .addListener(onMinimizeStateChanged);

    subscription = floating.pipStatusStream.listen(onPIPStatusUpdated);

    if (config?.pip.enableWhenBackground ?? true) {
      await enableWhenBackground(
        aspectWidth: config?.pip.aspectWidth ?? 9,
        aspectHeight: config?.pip.aspectHeight ?? 16,
      );
    }
  }

  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p android',
    );

    config = null;

    subscription?.cancel();
  }

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    final isPipAvailable = await floating.isPipAvailable;
    if (!isPipAvailable) {
      ZegoLoggerService.logError(
        'enableWhenBackground, '
        'but pip is not available, ',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return ZegoPiPStatus.unavailable;
    }

    try {
      return (await floating.enable(
        OnLeavePiP(
          aspectRatio: Rational(aspectWidth, aspectHeight),
        ),
      ))
          .toZego();
    } catch (e) {
      ZegoLoggerService.logWarn(
        'enableWhenBackground, '
        'exception:$e, ',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return ZegoPiPStatus.disabled;
    }
  }

  void onMinimizeStateChanged() async {
    if (!ZegoUIKitPrebuiltCallController().minimize.isMinimizing) {
      if (config?.pip.enableWhenBackground ?? true) {
        await enableWhenBackground(
          aspectWidth: config?.pip.aspectWidth ?? 9,
          aspectHeight: config?.pip.aspectHeight ?? 16,
        );
      }
    }
  }

  void onPIPStatusUpdated(PiPStatus status) {
    ZegoLoggerService.logInfo(
      'onPIPStatusUpdated, $status, '
      'lifecycleState: ${WidgetsBinding.instance.lifecycleState}',
      tag: 'call',
      subTag: 'controller.pip.p android',
    );

    switch (status) {
      case PiPStatus.enabled:
        isInPIP = true;
        break;
      case PiPStatus.disabled:
        if (isInPIP) {
          isRestoredFromPIP = true;
          isInPIP = false;

          if (AppLifecycleState.resumed !=
              WidgetsBinding.instance.lifecycleState) {
            ZegoUIKit().activeAppToForeground();
          }

          /// can't know when the rendering will end after restoration.
          /// get default value of camera/microphone in bottom bar
          Future.delayed(const Duration(seconds: 1), () {
            isRestoredFromPIP = false;
          });
        }

        if (config?.pip.enableWhenBackground ?? true) {
          enableWhenBackground(
            aspectWidth: config?.pip.aspectWidth ?? 9,
            aspectHeight: config?.pip.aspectHeight ?? 16,
          );
        }
        break;
      case PiPStatus.automatic:
        break;
      case PiPStatus.unavailable:
        break;
    }
  }
}
