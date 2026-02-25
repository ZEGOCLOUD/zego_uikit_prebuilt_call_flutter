part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerPIP {
  final _pipImpl = ZegoCallControllerPIPImpl();

  ZegoCallControllerPIPImpl get pip => _pipImpl;
}

/// Picture-in-Picture (PIP) controller for enabling and disabling PIP functionality.
class ZegoCallControllerPIPImpl with ZegoCallControllerPIPImplPrivate {
  /// Get the current PIP status.
  Future<ZegoPiPStatus> get status async => await private.pipImpl().status;

  /// Check if PIP is available on this device.
  Future<bool> get available async => await private.pipImpl().available;

  /// Enable Picture-in-Picture mode.
  ///
  /// [aspectWidth] The width of the aspect ratio for PIP (default 9).
  /// [aspectHeight] The height of the aspect ratio for PIP (default 16).
  /// Returns the status of the PIP operation.
  Future<ZegoPiPStatus> enable({

    /// The width of the aspect ratio for PIP.
    int aspectWidth = 9,

    /// The height of the aspect ratio for PIP.
    int aspectHeight = 16,
  }) async {
    return private.pipImpl().enable(
          aspectWidth: aspectWidth,
          aspectHeight: aspectHeight,
        );
  }

  /// Enable Picture-in-Picture mode when the app is in background.
  ///
  /// [aspectWidth] The width of the aspect ratio for PIP (default 9).
  /// [aspectHeight] The height of the aspect ratio for PIP (default 16).
  /// Returns the status of the PIP operation.
  Future<ZegoPiPStatus> enableWhenBackground({

    /// The width of the aspect ratio for PIP.
    int aspectWidth = 9,

    /// The height of the aspect ratio for PIP.
    int aspectHeight = 16,
  }) async {
    return private.pipImpl().enableWhenBackground(
          aspectWidth: aspectWidth,
          aspectHeight: aspectHeight,
        );
  }

  /// Cancel the background PIP.
  Future<void> cancelBackground() async {
    return private.pipImpl().cancelBackground();
  }
}
