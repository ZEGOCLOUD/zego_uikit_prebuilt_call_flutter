part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerScreenSharing {
  final _impl = ZegoCallControllerScreenSharingImpl();

  ZegoCallControllerScreenSharingImpl get screenSharing => _impl;
}

/// Screen sharing controller managing screen sharing display and fullscreen mode.
class ZegoCallControllerScreenSharingImpl
    with ZegoCallControllerScreenImplPrivate {
  ZegoScreenSharingViewController get viewController => private.viewController;

  /// Set fullscreen display mode for screen sharing.
  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  ///
  /// [userID] The ID of the user whose view to show in fullscreen mode.
  /// [isFullscreen] Whether to show the view in fullscreen mode.
  void showViewInFullscreenMode(String userID, bool isFullscreen) {
    ZegoLoggerService.logInfo(
      'showViewInFullscreenMode, '
      'userID:$userID, isFullscreen:$isFullscreen, ',
      tag: 'call',
      subTag: 'controller.screenSharing',
    );

    viewController.showScreenSharingViewInFullscreenMode(
      targetRoomID: ZegoUIKitPrebuiltCallController().private.roomID,
      userID,
      isFullscreen,
    );
  }
}
