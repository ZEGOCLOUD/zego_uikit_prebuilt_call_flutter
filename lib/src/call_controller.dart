// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/mini_overlay_machine.dart';

part 'package:zego_uikit_prebuilt_call/src/internal/controller_p.dart';

/// Used to control the call functionality.
/// If the default call UI and interactions do not meet your requirements, you can use this [ZegoUIKitPrebuiltCallController] to actively control the business logic.
/// This class is used by setting the [controller] parameter in the constructor of [ZegoUIKitPrebuiltCall].
///
/// If you use `call invitation`, you can make it effective by setting the [controller] parameter in the [init] method of [ZegoUIKitPrebuiltCallInvitationService].
class ZegoUIKitPrebuiltCallController
    with ZegoUIKitPrebuiltCallControllerPrivate {
  /// This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
  /// You need to provide the user's ID [userID] to determine which user to perform the operation on.
  /// By using a boolean value [isFullscreen], you can specify whether the user enters or exits full-screen mode.
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }

  /// This function is used to end the current call.
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the call.
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [onHangUpConfirmation] and [onHangUp] settings in the config.
  Future<bool> hangUp(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
    if (null == prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'hang up, config is null',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    if (isHangUpRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'hang up, is hang up requesting...',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'hang up, show confirmation:$showConfirmation',
      tag: 'call',
      subTag: 'controller',
    );
    isHangUpRequestingNotifier.value = true;

    if (showConfirmation) {
      ///  if there is a user-defined event before the click,
      ///  wait the synchronize execution result
      final canHangUp =
          await prebuiltConfig?.onHangUpConfirmation?.call(context) ?? true;
      if (!canHangUp) {
        ZegoLoggerService.logInfo(
          'hang up, reject',
          tag: 'call',
          subTag: 'controller',
        );

        isHangUpRequestingNotifier.value = false;

        return false;
      }
    }

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'hang up, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'controller',
      );
      return 0 == result.errorCode;
    });

    ZegoLoggerService.logInfo(
      'hang up, restore mini state by hang up',
      tag: 'call',
      subTag: 'controller',
    );
    ZegoUIKitPrebuiltCallMiniOverlayMachine()
        .changeState(PrebuiltCallMiniOverlayPageState.idle);

    if (prebuiltConfig?.onHangUp != null) {
      prebuiltConfig?.onHangUp?.call();
    } else {
      /// default behaviour if hand up is null, back to previous page
      Navigator.of(context).pop();
    }

    ZegoLoggerService.logInfo(
      'hang up, finished',
      tag: 'call',
      subTag: 'controller',
    );

    return result;
  }

  /// This function is used to send call invitations to one or more specified users.
  ///
  /// You can provide a list of target users [invitees] and specify whether it is a video call [isVideoCall]. If it is not a video call, it defaults to an audio call.
  /// You can also pass additional custom data [customData] to the invitees.
  /// Additionally, you can specify the call ID [callID]. If not provided, the system will generate one automatically based on certain rules.
  /// If you want to set a ringtone for offline call invitations, set [resourceID] to a value that matches the push resource ID in the ZEGOCLOUD management console.
  /// Note that the [resourceID] setting will only take effect when [notifyWhenAppRunningInBackgroundOrQuit] is true.
  /// You can also set the notification title [notificationTitle] and message [notificationMessage].
  /// If the call times out, the call will automatically hang up after the specified timeout duration [timeoutSeconds] (in seconds).
  ///
  /// Note that this function behaves the same as [ZegoSendCallInvitationButton].
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
    if (null == _pageManager || null == _callInvitationConfig) {
      ZegoLoggerService.logInfo(
        'send call invitation, param is invalid, page manager:$_pageManager, invitation config:$_callInvitationConfig',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    final currentCallID = callID ??
        'call_${ZegoUIKit().getLocalUser().id}_${DateTime.now().millisecondsSinceEpoch}';

    final currentState =
        _pageManager?.callingMachine.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kIdle != currentState) {
      ZegoLoggerService.logInfo(
        'send call invitation, still in calling, $currentState',
        tag: 'call',
        subTag: 'controller',
      );
      return false;
    }

    ZegoLoggerService.logInfo(
      'send call invitation, start request',
      tag: 'call',
      subTag: 'controller',
    );

    if (_pageManager?.callingMachine.isPagePushed ?? false) {
      return _waitUntil(() {
        return !_pageManager!.callingMachine.isPagePushed;
      }).then((value) {
        return _sendInvitation(
          invitees: invitees,
          isVideoCall: isVideoCall,
          callID: currentCallID,
          customData: customData,
          resourceID: resourceID,
          timeoutSeconds: timeoutSeconds,
          notificationTitle: notificationTitle,
          notificationMessage: notificationMessage,
        );
      });
    }

    return _sendInvitation(
      invitees: invitees,
      isVideoCall: isVideoCall,
      callID: currentCallID,
      customData: customData,
      resourceID: resourceID,
      timeoutSeconds: timeoutSeconds,
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
    );
  }
}
