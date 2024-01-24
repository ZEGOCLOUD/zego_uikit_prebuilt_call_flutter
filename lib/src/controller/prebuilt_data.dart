// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

mixin ZegoCallPrebuiltData {
  /// Whether the call hang-up operation is in progress
  /// such as clicking the close button in the upper right corner or calling the `hangUp` function of the controller.
  /// If it is not handled completely, it is considered as in progress.
  final ValueNotifier<bool> isHangUpRequestingNotifier =
      ValueNotifier<bool>(false);

  /// ZegoUIKitPrebuiltCall's config
  ZegoUIKitPrebuiltCallConfig? get prebuiltConfig => _prebuiltConfig;

  ZegoUIKitPrebuiltCallConfig? _prebuiltConfig;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({required ZegoUIKitPrebuiltCallConfig prebuiltConfig}) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.prebuilt_data',
    );

    _prebuiltConfig = prebuiltConfig;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.prebuilt_data',
    );

    isHangUpRequestingNotifier.value = false;

    _prebuiltConfig = null;
  }
}
