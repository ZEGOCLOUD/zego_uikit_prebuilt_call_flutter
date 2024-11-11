part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerPIP {
  final _pipImpl = ZegoCallControllerPIPImpl();

  ZegoCallControllerPIPImpl get pip => _pipImpl;
}

/// Here are the APIs related to audio video.
class ZegoCallControllerPIPImpl with ZegoCallControllerPIPImplPrivate {
  Future<ZegoPiPStatus> get status async => await private.pipImpl().status;

  Future<bool> get available async => await private.pipImpl().available;

  /// sourceRectHint: Rectangle<int>(0, 0, width, height)
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    return private.pipImpl().enable(
          aspectWidth: aspectWidth,
          aspectHeight: aspectHeight,
        );
  }

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  }) async {
    return private.pipImpl().enableWhenBackground(
          aspectWidth: aspectWidth,
          aspectHeight: aspectHeight,
        );
  }

  Future<void> cancelBackground() async {
    return private.pipImpl().cancelBackground();
  }
}
