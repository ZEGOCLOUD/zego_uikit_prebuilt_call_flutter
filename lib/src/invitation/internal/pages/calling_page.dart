// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/call_invitation_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/page_service.dart';
import 'calling_machine.dart';
import 'calling_view.dart';

class ZegoCallingPage extends StatefulWidget {
  final ZegoUIKitUser inviter;
  final ZegoUIKitUser invitee;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
    required this.inviter,
    required this.invitee,
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

  final ZegoCallingMachine machine =
      ZegoInvitationPageService.instance.callingMachine;

  ZegoInvitationPageService get pageService =>
      ZegoInvitationPageService.instance;

  ZegoCallInvitationService get callInvitationService =>
      ZegoCallInvitationService.instance;

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
    var localUserInfo = ZegoUIKit().getLocalUser();

    late Widget view;
    switch (currentState) {
      case CallingState.kIdle:
        view = const SizedBox();
        break;
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        callConfig = null;

        var localUserIsInviter = localUserInfo.id == widget.inviter.id;
        var callingView = localUserIsInviter
            ? ZegoInviterCallingView(
                inviter: widget.inviter,
                invitee: widget.invitee,
                invitationType: pageService.invitationData.type,
                avatarBuilder: callInvitationService
                    .configQuery(pageService.invitationData)
                    .audioVideoViewConfig
                    .avatarBuilder,
              )
            : ZegoCallingInviteeView(
                inviter: widget.inviter,
                invitee: widget.invitee,
                invitationType: pageService.invitationData.type,
                avatarBuilder: callInvitationService
                    .configQuery(pageService.invitationData)
                    .audioVideoViewConfig
                    .avatarBuilder,
              );
        view = ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return callingView;
          },
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
        child: SafeArea(
          child: view,
        ));
  }

  void onCallHandUp() {
    callConfigHandUp?.call();
    pageService.onHangUp();
  }

  Widget prebuiltCallPage() {
    callConfig = callInvitationService.configQuery(pageService.invitationData);

    callConfigHandUp = callConfig?.onHangUp;
    callConfig?.onHangUp = onCallHandUp;

    if (ZegoInvitationType.videoCall != pageService.invitationData.type) {
      var list = List<ZegoMenuBarButtonName>.from(
          callConfig?.bottomMenuBarConfig.buttons ?? []);
      list.remove(ZegoMenuBarButtonName.toggleCameraButton);
      list.remove(ZegoMenuBarButtonName.switchCameraButton);
      callConfig?.bottomMenuBarConfig.buttons = list;
    }

    return ZegoUIKitPrebuiltCall(
      appID: callInvitationService.appID,
      appSign: callInvitationService.appSign,
      callID: pageService.invitationData.callID,
      userID: callInvitationService.userID,
      userName: callInvitationService.userName,
      tokenServerUrl: callInvitationService.tokenServerUrl,
      config: callConfig!,
    );
  }
}
