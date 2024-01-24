// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_view.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';

/// @nodoc
class ZegoCallingPage extends StatefulWidget {
  final ZegoInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitees,
    required this.onInitState,
    required this.onDispose,
  }) : super(key: key);

  @override
  ZegoCallingPageState createState() => ZegoCallingPageState();
}

/// @nodoc
class ZegoCallingPageState extends State<ZegoCallingPage> {
  CallingState currentState = CallingState.kIdle;

  CallEndCallback? previousOnCallEnd;

  ZegoCallingMachine? get machine => widget.pageManager.callingMachine;

  @override
  void initState() {
    super.initState();

    widget.onInitState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      machine?.onStateChanged = (CallingState state) {
        setState(() {
          currentState = state;
        });
      };

      if (null != machine?.machine.current) {
        machine!.onStateChanged!(machine!.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    widget.onDispose();

    machine?.onStateChanged = null;

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
        final localUserIsInviter = localUserInfo.id == widget.inviter.id;
        final invitationView = localUserIsInviter
            ? ZegoCallingInviterView(
                pageManager: widget.pageManager,
                callInvitationData: widget.callInvitationData,
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: widget.pageManager.invitationData.type,
                avatarBuilder: widget.callInvitationData
                    .requireConfig(widget.pageManager.invitationData)
                    .avatarBuilder,
              )
            : ZegoCallingInviteeView(
                pageManager: widget.pageManager,
                callInvitationData: widget.callInvitationData,
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: widget.pageManager.invitationData.type,
                avatarBuilder: widget.callInvitationData
                    .requireConfig(widget.pageManager.invitationData)
                    .avatarBuilder,
                showDeclineButton:
                    widget.callInvitationData.uiConfig.showDeclineButton,
              );
        view = SafeArea(
          child: invitationView,
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
      child: view,
    );
  }

  Future<void> onCallEnd(
    ZegoUIKitCallEndEvent event,
    VoidCallback defaultAction,
  ) async {
    previousOnCallEnd?.call(event, defaultAction);

    /// If the customer overrides callConfig?.onHangUp and it is not null,
    /// then the customer is responsible for popping the screen.
    widget.pageManager.onHangUp(
      needPop: null == previousOnCallEnd,
    );
  }

  Widget prebuiltCallPage() {
    previousOnCallEnd = widget.callInvitationData.events?.onCallEnd;
    widget.callInvitationData.events?.onCallEnd = onCallEnd;

    /// assign if not set
    widget.callInvitationData.events?.onError ??=
        widget.callInvitationData.invitationEvents?.onError;

    final prebuiltCall = ZegoUIKitPrebuiltCall(
      appID: widget.callInvitationData.appID,
      appSign: widget.callInvitationData.appSign,
      callID: widget.pageManager.invitationData.callID,
      userID: widget.callInvitationData.userID,
      userName: widget.callInvitationData.userName,
      config: widget.callInvitationData.requireConfig(
        widget.pageManager.invitationData,
      ),
      events: widget.callInvitationData.events,
      onDispose: () {
        widget.pageManager.onPrebuiltCallPageDispose();
      },
      plugins: widget.callInvitationData.plugins,
    );

    return widget.callInvitationData.uiConfig.prebuiltWithSafeArea
        ? SafeArea(
            child: prebuiltCall,
          )
        : prebuiltCall;
  }
}
