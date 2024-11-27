part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerPIP {
  final _pipImpl = ZegoCallControllerPIPImpl();

  ZegoCallControllerPIPImpl get pip => _pipImpl;
}

/// Here are the APIs related to audio video.
class ZegoCallControllerPIPImpl with ZegoCallControllerPIPImplPrivate {
  Future<ZegoPiPStatus> get status async =>
      (await private.floating.pipStatus).toZego();

  Future<bool> get available async => await private.floating.isPipAvailable;

  /// sourceRectHint: Rectangle<int>(0, 0, width, height)
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    if (!Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'enable, only support android',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return ZegoPiPStatus.unavailable;
    }

    final isPipAvailable = await private.floating.isPipAvailable;
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
      status = (await private.floating.enable(
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

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    if (!Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'enableWhenBackground, only support android',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return ZegoPiPStatus.unavailable;
    }

    var status = ZegoPiPStatus.unavailable;
    try {
      status = await private.enableWhenBackground(
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

  Future<void> cancelBackground() async {
    if (!Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'cancelBackground, only support android',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return;
    }

    /// back to app
    await ZegoUIKit().activeAppToForeground();

    try {
      await private.floating.cancelOnLeavePiP();
    } catch (e) {
      ZegoLoggerService.logInfo(
        'cancelOnLeavePiP exception:${e.toString()}',
        tag: 'call',
        subTag: 'controller.pip',
      );
    }
  }
}
