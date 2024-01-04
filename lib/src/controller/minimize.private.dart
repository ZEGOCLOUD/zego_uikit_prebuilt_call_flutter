part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizePrivate {
  final _private = ZegoCallControllerMinimizePrivateImpl();

  /// Don't call that
  ZegoCallControllerMinimizePrivateImpl get private => _private;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoCallControllerMinimizePrivateImpl {
  ZegoUIKitPrebuiltCallMinimizeData? get minimizeData => _minimizeData;

  ZegoUIKitPrebuiltCallMinimizeData? _minimizeData;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallMinimizeData minimizeData,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = minimizeData;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    _minimizeData = null;
  }
}
