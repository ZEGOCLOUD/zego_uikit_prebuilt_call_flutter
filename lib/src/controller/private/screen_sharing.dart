part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerScreenImplPrivate {
  final _private = ZegoCallControllerScreenImplPrivateImpl();

  /// Don't call that
  ZegoCallControllerScreenImplPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerScreenImplPrivateImpl {
  final viewController = ZegoScreenSharingViewController();

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  Future<void> initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.screenSharing.p',
    );

    if (null != config?.screenSharing.autoStop) {
      viewController.private.autoStopSettings.invalidCount =
          config!.screenSharing.autoStop.invalidCount;
      viewController.private.autoStopSettings.canEnd =
          config.screenSharing.autoStop.canEnd;
    }

    viewController.private.defaultFullScreen =
        config?.screenSharing.defaultFullScreen ?? false;

    viewController.private.sharingTipText =
        config?.translationText.screenSharingTipText;
    viewController.private.stopSharingButtonText =
        config?.translationText.stopScreenSharingButtonText;
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'live-streaming',
      subTag: 'controller.pip.p',
    );
  }
}
