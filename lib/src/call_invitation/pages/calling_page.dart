// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'calling_machine.dart';
import 'calling_view.dart';
import 'page_manager.dart';

class ZegoCallingPage extends StatefulWidget {
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
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

  final ZegoCallingMachine machine =
      ZegoInvitationPageManager.instance.callingMachine;

  ZegoInvitationPageManager get pageManager =>
      ZegoInvitationPageManager.instance;

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
            ? ZegoCallingInviterView(
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: pageManager.invitationData.type,
                avatarBuilder: pageManager
                    .prebuiltConfigQuery(pageManager.invitationData)
                    .avatarBuilder,
              )
            : ZegoCallingInviteeView(
                inviter: widget.inviter,
                invitees: widget.invitees,
                invitationType: pageManager.invitationData.type,
                avatarBuilder: pageManager
                    .prebuiltConfigQuery(pageManager.invitationData)
                    .avatarBuilder,
                showDeclineButton: pageManager.showDeclineButton,
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
    pageManager.onHangUp();
  }

  Widget prebuiltCallPage() {
    callConfig = pageManager.prebuiltConfigQuery(pageManager.invitationData);

    callConfigHandUp = callConfig?.onHangUp;
    callConfig?.onHangUp = onCallHandUp;

    return ZegoUIKitPrebuiltCall(
      appID: pageManager.appID,
      appSign: pageManager.appSign,
      callID: pageManager.invitationData.callID,
      userID: pageManager.userID,
      userName: pageManager.userName,
      tokenServerUrl: pageManager.tokenServerUrl,
      config: callConfig!,
      onDispose: () {
        pageManager.onPrebuiltCallPageDispose();
      },
    );
  }
}
