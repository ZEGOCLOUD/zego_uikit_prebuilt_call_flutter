// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/deprecated/v4/deprecated_419.dart';
import 'package:zego_uikit_prebuilt_call/src/deprecated/v4/deprecated_4_1_10.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

const deprecatedTipsV400 = ', '
    'deprecated since 4.0.0, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#400';

@Deprecated(
    'use ZegoUIKitPrebuiltCallController().minimize instead$deprecatedTipsV400')
class ZegoUIKitPrebuiltCallMiniOverlayMachine {
  @Deprecated(
      'use ZegoUIKitPrebuiltCallController().minimize.state instead$deprecatedTipsV400')
  PrebuiltCallMiniOverlayPageState state() =>
      ZegoUIKitPrebuiltCallController().minimize.state;

  @Deprecated(
      'use ZegoUIKitPrebuiltCallController().minimize.isMinimizing instead$deprecatedTipsV400')
  bool get isMinimizing =>
      ZegoUIKitPrebuiltCallController().minimize.isMinimizing;

  @Deprecated(
      'use ZegoUIKitPrebuiltCallController().minimize.hide instead$deprecatedTipsV400')
  void switchToIdle() {
    ZegoUIKitPrebuiltCallController().minimize.hide();
  }
}

extension ZegoUIKitPrebuiltCallControllerDeprecated
    on ZegoUIKitPrebuiltCallController {
  @Deprecated('use minimize.isMinimizing instead$deprecatedTipsV400')
  bool get isMinimizing => minimize.isMinimizing;

  @Deprecated('use screenSharing.viewController instead$deprecatedTipsV400')
  ZegoScreenSharingViewController get screenSharingViewController =>
      screenSharing.viewController;

  @Deprecated(
      'use screenSharing.showViewInFullscreenMode instead$deprecatedTipsV400')
  void showScreenSharingViewInFullscreenMode(
          String userID, bool isFullscreen) =>
      screenSharing.showViewInFullscreenMode(userID, isFullscreen);
}

extension ZegoUIKitPrebuiltCallControllerInvitationDeprecated
    on ZegoUIKitPrebuiltCallController {
  @Deprecated('use invitation.send instead$deprecatedTipsV400')
  Future<bool> sendCallInvitation({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) async {
    return invitation.send(
      invitees: invitees,
      isVideoCall: isVideoCall,
      customData: customData,
      callID: callID,
      resourceID: resourceID,
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
      timeoutSeconds: timeoutSeconds,
    );
  }

  @Deprecated('use invitation.cancel instead$deprecatedTipsV400')
  Future<bool> cancelCallInvitation({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    return invitation.cancel(
      callees: callees,
      customData: customData,
    );
  }

  @Deprecated('use invitation.reject instead$deprecatedTipsV400')
  Future<bool> rejectCallInvitation({
    String customData = '',
  }) async {
    return invitation.reject(customData: customData);
  }

  @Deprecated('use invitation.accept instead$deprecatedTipsV400')
  Future<bool> acceptCallInvitation({
    String customData = '',
  }) async {
    return invitation.accept(customData: customData);
  }
}
