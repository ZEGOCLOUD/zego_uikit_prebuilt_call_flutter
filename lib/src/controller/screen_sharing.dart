part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerScreenSharing {
  final _impl = ZegoCallControllerScreenSharingImpl();

  ZegoCallControllerScreenSharingImpl get screenSharing => _impl;
}

class ZegoCallControllerScreenSharingImpl {
  final _viewController = ZegoScreenSharingViewController();

  ZegoScreenSharingViewController get viewController => _viewController;

  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  ///
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  void showViewInFullscreenMode(String userID, bool isFullscreen) {
    ZegoLoggerService.logInfo(
      'showViewInFullscreenMode, '
      'userID:$userID, isFullscreen:$isFullscreen, ',
      tag: 'call',
      subTag: 'controller.screenSharing',
    );

    _viewController.showScreenSharingViewInFullscreenMode(userID, isFullscreen);
  }
}
