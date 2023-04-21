// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoUIKitPrebuiltCallController {
  final screenSharingViewController = ZegoScreenSharingViewController();

  void showScreenSharingViewInFullscreenMode(String userID, bool isFullscreen) {
    screenSharingViewController.showScreenSharingViewInFullscreenMode(
        userID, isFullscreen);
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
    if (!isValid()) {
      ZegoLoggerService.logInfo(
        'controller is not valid',
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
        'still in calling, $currentState',
        tag: 'call',
        subTag: 'controller',
      );
      return false;
    }

    ZegoLoggerService.logInfo(
      'start request',
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

  Future<bool> _sendInvitation({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    required String callID,
    String customData = '',
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) {
    return ZegoUIKit()
        .getSignalingPlugin()
        .sendInvitation(
          inviterName: ZegoUIKit().getLocalUser().name,
          invitees: invitees.map((user) {
            return user.id;
          }).toList(),
          timeout: timeoutSeconds,
          type: ZegoCallTypeExtension(
            isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
          ).value,
          data: InvitationInternalData(
            callID,
            invitees
                .map((invitee) => ZegoUIKitUser(
                      id: invitee.id,
                      name: invitee.name,
                    ))
                .toList(),
            customData,
          ).toJson(),
          zegoNotificationConfig: ZegoNotificationConfig(
            resourceID: resourceID ?? '',
            title: notificationTitle ??
                (isVideoCall
                        ? ((invitees.length > 1
                                ? _innerText?.incomingGroupVideoCallDialogTitle
                                : _innerText?.incomingVideoCallDialogTitle) ??
                            param_1)
                        : ((invitees.length > 1
                                ? _innerText?.incomingGroupVoiceCallDialogTitle
                                : _innerText?.incomingVoiceCallDialogTitle) ??
                            param_1))
                    .replaceFirst(param_1, ZegoUIKit().getLocalUser().name),
            message: notificationMessage ??
                (isVideoCall
                    ? ((invitees.length > 1
                            ? _innerText?.incomingGroupVideoCallDialogMessage
                            : _innerText?.incomingVideoCallDialogMessage) ??
                        'Incoming video call...')
                    : ((invitees.length > 1
                            ? _innerText?.incomingGroupVoiceCallDialogMessage
                            : _innerText?.incomingVoiceCallDialogMessage) ??
                        'Incoming voice call...')),
          ),
        )
        .then((result) {
      _pageManager?.onLocalSendInvitation(
        callID,
        invitees
            .map((invitee) => ZegoUIKitUser(
                  id: invitee.id,
                  name: invitee.name,
                ))
            .toList(),
        isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
        result.error?.code ?? '',
        result.error?.message ?? '',
        result.invitationID,
        result.errorInvitees.keys.toList(),
      );

      return result.error?.code.isNotEmpty ?? true;
    });
  }

  Future<int> _waitUntil(
    bool Function() test, {
    final int maxIterations = 100,
    final Duration step = const Duration(milliseconds: 10),
  }) async {
    var iterations = 0;
    for (; iterations < maxIterations; iterations++) {
      await Future.delayed(step);
      if (test()) {
        break;
      }
    }
    if (iterations >= maxIterations) {
      return iterations;
    }
    return iterations;
  }

  ZegoInvitationPageManager? get _pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoCallInvitationConfig? get _callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationConfig;

  ZegoCallInvitationInnerText? get _innerText =>
      _callInvitationConfig?.innerText;

  bool isValid() {
    return null != _pageManager && null != _callInvitationConfig;
  }
}
