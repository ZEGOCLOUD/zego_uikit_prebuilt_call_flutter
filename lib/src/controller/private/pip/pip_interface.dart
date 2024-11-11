// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

abstract class ZegoCallControllerPIPInterface {
  Future<ZegoPiPStatus> get status;

  Future<bool> get available;

  bool get isRestoredFromPIP;

  /// sourceRectHint: Rectangle<int>(0, 0, width, height)
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  });

  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  });

  Future<void> cancelBackground();

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  });

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt();
}
