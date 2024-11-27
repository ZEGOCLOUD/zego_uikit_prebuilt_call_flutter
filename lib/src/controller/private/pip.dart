part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

extension ZegoCallPipStatus on PiPStatus {
  ZegoPiPStatus toZego() {
    switch (this) {
      case PiPStatus.enabled:
        return ZegoPiPStatus.enabled;
      case PiPStatus.disabled:
        return ZegoPiPStatus.disabled;
      case PiPStatus.automatic:
        return ZegoPiPStatus.automatic;
      case PiPStatus.unavailable:
        return ZegoPiPStatus.unavailable;
    }
  }
}

/// @nodoc
mixin ZegoCallControllerPIPImplPrivate {
  final _private = ZegoCallControllerPIPImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerPIPImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerPIPImplPrivateImpl {
  final floating = Floating();
  ZegoUIKitPrebuiltCallConfig? config;

  bool isInPIP = false;
  bool isRestoreFromPIP = false;

  StreamSubscription<dynamic>? subscription;

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

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p',
    );

    this.config = config;

    if (!Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'initByPrebuilt, only support android',
        tag: 'call',
        subTag: 'controller.pip',
      );

      return;
    }

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

    subscription = floating.pipStatusStream.listen(onPIPStatusUpdated);

    if (config?.pip.enableWhenBackground ?? true) {
      await enableWhenBackground(
        aspectWidth: config?.pip.aspectWidth ?? 9,
        aspectHeight: config?.pip.aspectHeight ?? 16,
      );
    }
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.pip.p',
    );

    config = null;

    subscription?.cancel();

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);
  }

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    ZegoLoggerService.logInfo(
      '_onAppLifecycleStateChanged, $appLifecycleState',
      tag: 'call',
      subTag: 'controller.pip.p',
    );

    /// app -> desktop  AppLifecycleState.inactive
    /// desktop -> app AppLifecycleState.resumed
    if (AppLifecycleState.resumed == appLifecycleState) {}
  }

  void onPIPStatusUpdated(PiPStatus status) {
    ZegoLoggerService.logInfo(
      'onPIPStatusUpdated, $status',
      tag: 'call',
      subTag: 'controller.pip.p',
    );

    switch (status) {
      case PiPStatus.enabled:
        isInPIP = true;
        break;
      case PiPStatus.disabled:
        if (isInPIP) {
          isRestoreFromPIP = true;
          isInPIP = false;

          /// can't know when the rendering will end after restoration.
          /// get default value of camera/microphone in bottom bar
          Future.delayed(const Duration(seconds: 1), () {
            isRestoreFromPIP = false;
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
