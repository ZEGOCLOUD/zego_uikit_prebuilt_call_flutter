// Project imports:
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_overlay_internal_machine.dart';

/// @nodoc
/// @deprecated
@Deprecated('Please Use ZegoUIKitPrebuiltCallMiniOverlayMachine')
typedef ZegoMiniOverlayMachine = ZegoUIKitPrebuiltCallMiniOverlayMachine;

class ZegoUIKitPrebuiltCallMiniOverlayMachine {
  PrebuiltCallMiniOverlayPageState state() =>
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state();

  bool get isMinimizing =>
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().isMinimizing;

  @Deprecated('Since 3.17.3, please use switchToIdle')
  void changeState(PrebuiltCallMiniOverlayPageState state) {
    switchToIdle();
  }

  void switchToIdle() {
    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
      PrebuiltCallMiniOverlayPageState.idle,
    );
  }

  factory ZegoUIKitPrebuiltCallMiniOverlayMachine() => _instance;

  ZegoUIKitPrebuiltCallMiniOverlayMachine._internal();

  static final ZegoUIKitPrebuiltCallMiniOverlayMachine _instance =
      ZegoUIKitPrebuiltCallMiniOverlayMachine._internal();
}
