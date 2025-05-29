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
  ZegoCallControllerPIPInterface? _pipImpl;

  ZegoCallControllerPIPInterface pipImpl() {
    if (null == _pipImpl) {
      if (Platform.isAndroid) {
        _pipImpl = ZegoCallControllerPIPAndroid();
      } else if (Platform.isIOS) {
        _pipImpl = ZegoCallControllerIOSPIP();
      } else {
        assert(false, 'platform not support');
      }
    }

    return _pipImpl!;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    await pipImpl().initByPrebuilt(config: config);
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    pipImpl().uninitByPrebuilt();
  }
}
