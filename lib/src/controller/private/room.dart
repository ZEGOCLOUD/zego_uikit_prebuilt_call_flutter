part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerRoomImplPrivate {
  final _private = ZegoCallControllerRoomImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerRoomImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerRoomImplPrivateImpl {
  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt() {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.room.p',
    );
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.room.p',
    );
  }
}
