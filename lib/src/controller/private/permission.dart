part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerPermissionImplPrivate {
  final _private = ZegoCallControllerPermissionImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerPermissionImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerPermissionImplPrivateImpl {
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
