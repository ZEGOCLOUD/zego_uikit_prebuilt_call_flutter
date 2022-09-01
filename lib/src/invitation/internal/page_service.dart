// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'call_invitation_service.dart';
import 'defines.dart';
import 'notification_ring.dart';
import 'pages/calling_machine.dart';
import 'pages/invitation_notify.dart';

class ZegoInvitationPageService {
  factory ZegoInvitationPageService() => instance;
  static final ZegoInvitationPageService instance =
      ZegoInvitationPageService._internal();

  ZegoInvitationPageService._internal();

  var ring = ZegoNotificationRing();

  BuildContext get context => ZegoCallInvitationService.instance.contextQuery();

  ZegoUIKitPrebuiltCallConfig get config =>
      ZegoCallInvitationService.instance.configQuery(invitationData);

  void init() {
    ZegoUIKit().getInvitationReceivedStream().listen(onInvitationReceived);
    ZegoUIKit().getInvitationAcceptedStream().listen(onInvitationAccepted);
    ZegoUIKit().getInvitationTimeoutStream().listen(onInvitationTimeout);
    ZegoUIKit()
        .getInvitationResponseTimeoutStream()
        .listen(onInvitationResponseTimeout);
    ZegoUIKit().getInvitationRefusedStream().listen(onInvitationRefused);
    ZegoUIKit().getInvitationCanceledStream().listen(onInvitationCanceled);

    callingMachine = ZegoCallingMachine();
    callingMachine.init();

    //  ZegoUIKitCoreUser.localDefault() will set camera true at the first time
    //  reset to false, otherwise start preview will fail
    ZegoUIKit.instance.turnCameraOn(false);
  }

  late ZegoCallingMachine callingMachine;

  ZegoCallInvitationData invitationData = ZegoCallInvitationData.empty();

  bool invitationTopSheetVisibility = false;

  void onLocalSendInvitation(
    bool result,
    String callID,
    List<ZegoUIKitUser> invitees,
    ZegoInvitationType invitationType,
  ) {
    invitationData.callID = callID;
    invitationData.inviter = ZegoUIKit().getLocalUser();
    invitationData.invitees = invitees;
    invitationData.type = invitationType;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (result) {
      if (ZegoInvitationType.voiceCall == invitationData.type) {
        callingMachine.stateCallingWithVoice.enter();
      } else {
        if (config.turnOnCameraWhenJoining) {
          ZegoUIKit.instance.turnCameraOn(true);
        }

        callingMachine.stateCallingWithVideo.enter();
      }
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation() {
    debugPrint("local accept invitation");

    ring.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onLocalRefuseInvitation() {
    debugPrint("local refuse invitation");
    restoreToIdle();
  }

  void onLocalCancelInvitation() {
    debugPrint("local cancel invitation");

    restoreToIdle();
  }

  void onInvitationReceived(StreamDataInvitationReceived data) {
    if (CallingState.kIdle != callingMachine.getPageState()) {
      debugPrint("auto refuse this call, because call state is not idle, "
          "current state is ${callingMachine.getPageState()}");

      ZegoUIKit().refuseInvitation(data.inviter.id, '');

      return;
    }

    ring.startRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    var invitationInternalData = InvitationInternalData.fromJson(data.data);
    invitationData.callID = invitationInternalData.callID;
    invitationData.invitees = invitationInternalData.invitees;

    invitationData.inviter =
        ZegoUIKitUser(id: data.inviter.id, name: data.inviter.name);

    invitationData.type =
        ZegoInvitationTypeExtension.mapValue[data.type] as ZegoInvitationType;

    showInvitationTopSheet();
  }

  void onInvitationAccepted(StreamDataInvitationAccepted data) {
    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onInvitationTimeout(StreamDataInvitationTimeout data) {
    restoreToIdle();
  }

  void onInvitationResponseTimeout(StreamDataInvitationResponseTimeout data) {
    restoreToIdle();
  }

  void onInvitationRefused(StreamDataInvitationRefused data) {
    restoreToIdle();
  }

  void onInvitationCanceled(StreamDataInvitationCanceled data) {
    restoreToIdle();
  }

  void onHangUp() {
    restoreToIdle();
  }

  void restoreToIdle() {
    debugPrint("invitation page service to be idle");

    ring.stopRing();

    ZegoUIKit.instance.turnCameraOn(false);

    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine.machine.current?.identifier ?? CallingState.kIdle)) {
      debugPrint(
          'restore to idle, current state:${callingMachine.machine.current?.identifier}');

      Navigator.of(context).pop();

      callingMachine.stateIdle.enter();
    }

    invitationData = ZegoCallInvitationData.empty();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoInvitationType.voiceCall == invitationData.type) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      return;
    }

    invitationTopSheetVisibility = true;

    showTopModalSheet(
      context,
      GestureDetector(
        onTap: () {
          onInvitationTopSheetEmptyClicked();
        },
        child: ZegoCallInvitationDialog(
          invitationData: invitationData,
          avatarBuilder: config.audioVideoViewConfig.avatarBuilder,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      Navigator.of(context).pop();

      invitationTopSheetVisibility = false;
    }
  }
}
