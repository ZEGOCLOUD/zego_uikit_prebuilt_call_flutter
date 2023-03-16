// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoUIKitPrebuiltCallController {
  final screenSharingViewController = ZegoScreenSharingViewController();

  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }
}
