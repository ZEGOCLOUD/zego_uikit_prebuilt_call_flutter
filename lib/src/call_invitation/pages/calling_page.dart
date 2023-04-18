// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_view.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoCallingPage extends StatefulWidget {
  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
    required this.pageManager,
    required this.callInvitationConfig,
    required this.inviter,
    required this.invitees,
    required this.onInitState,
    required this.onDispose,
  }) : super(key: key);

  @override
  ZegoCallingPageState createState() => ZegoCallingPageState();
}

class ZegoCallingPageState extends State<ZegoCallingPage> {
  CallingState currentState = CallingState.kIdle;

  VoidCallback? callConfigHandUp;
  ZegoUIKitPrebuiltCallConfig? callConfig;

  ZegoCallingMachine get machine => widget.pageManager.callingMachine;

  @override
  void initState() {
    super.initState();

    widget.onInitState();

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      machine.onStateChanged = (CallingState state) {
        setState(() {
          currentState = state;
        });
      };

      if (null != machine.machine.current) {
        machine.onStateChanged!(machine.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    widget.onDispose();

    machine.onStateChanged = null;

    callConfig = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localUserInfo = ZegoUIKit().getLocalUser();

    late Widget view;
    switch (currentState) {
      case CallingState.kIdle:
        view = const SizedBox();
        break;
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        callConfig = null;

        final localUserIsInviter = localUserInfo.id == widget.inviter.id;
        view = localUserIsInviter
            ? ZegoCallingInviterView(
                pageManager: widget.pageManager,
                callInvitationConfig: widget.callInvitationConfig,
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: widget.pageManager.invitationData.type,
                avatarBuilder: widget.callInvitationConfig
                    .prebuiltConfigQuery(widget.pageManager.invitationData)
                    .avatarBuilder,
              )
            : ZegoCallingInviteeView(
                pageManager: widget.pageManager,
                callInvitationConfig: widget.callInvitationConfig,
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: widget.pageManager.invitationData.type,
                avatarBuilder: widget.callInvitationConfig
                    .prebuiltConfigQuery(widget.pageManager.invitationData)
                    .avatarBuilder,
                showDeclineButton:
                    widget.callInvitationConfig.showDeclineButton,
              );
        break;
      case CallingState.kOnlineAudioVideo:
        view = prebuiltCallPage();
        break;
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(child: view),
    );
  }

  void onCallHandUp() {
    callConfigHandUp?.call();
    widget.pageManager.onHangUp();
  }

  Widget prebuiltCallPage() {
    callConfig = widget.callInvitationConfig
        .prebuiltConfigQuery(widget.pageManager.invitationData);

    callConfigHandUp = callConfig?.onHangUp;
    callConfig?.onHangUp = onCallHandUp;

    return ZegoUIKitPrebuiltCall(
      appID: widget.callInvitationConfig.appID,
      appSign: widget.callInvitationConfig.appSign,
      callID: widget.pageManager.invitationData.callID,
      userID: widget.callInvitationConfig.userID,
      userName: widget.callInvitationConfig.userName,
      config: callConfig!,
      onDispose: () {
        widget.pageManager.onPrebuiltCallPageDispose();
      },
      controller: widget.callInvitationConfig.controller,
    );
  }
}
