part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerUserImplPrivate {
  final _private = ZegoCallControllerUserImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerUserImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerUserImplPrivateImpl {
  ZegoUIKitPrebuiltCallConfig? config;

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.user.p',
    );

    this.config = config;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.user.p',
    );

    config = null;
  }
}
