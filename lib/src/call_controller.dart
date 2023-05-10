// Package imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

part 'package:zego_uikit_prebuilt_call/src/internal/controller_p.dart';

class ZegoUIKitPrebuiltCallController
    with ZegoUIKitPrebuiltCallControllerPrivate {
  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
  }

  ///  actively ending the current call.
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
