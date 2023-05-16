// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_page.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/mini_overlay_machine.dart';

// Project imports:

/// @nodoc
enum CallingState {
  kIdle,
  //  voice call request
  kCallingWithVoice,
  //  video call request
  kCallingWithVideo,
  //  in voice call
  kOnlineAudioVideo,
}

/// @nodoc
typedef CallingMachineStateChanged = void Function(CallingState);

/// @nodoc
/// State machine in the call
class ZegoCallingMachine {
  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  ZegoCallingMachine({
    required this.pageManager,
    required this.callInvitationConfig,
  });

  final machine = sm.Machine<CallingState>();
  CallingMachineStateChanged? onStateChanged;

  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineAudioVideo;

  bool isPagePushed = false;

  BuildContext get context => callInvitationConfig.contextQuery!.call();

  void init() {
    machine.onAfterTransition.listen((event) {
      ZegoLoggerService.logInfo(
        'calling, from ${event.source} to ${event.target}',
        tag: 'call',
        subTag: 'machine',
      );

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    stateIdle = machine.newState(CallingState.kIdle)
      ..onEntry(
        () {
          ZegoLoggerService.logInfo(
            'calling machine to be idle',
            tag: 'call',
            subTag: 'machine',
          );
        },
      ); // default state

    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice)
      ..onEntry(onCallingEntry);
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo)
      ..onEntry(onCallingEntry);
    stateOnlineAudioVideo = machine.newState(CallingState.kOnlineAudioVideo)
      ..onEntry(onCallingEntry);

    machine.current = stateIdle;
  }

  void onCallingEntry() {
    if (PrebuiltCallMiniOverlayPageState.calling ==
        ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'entry is from calling by mini machine',
        tag: 'call',
        subTag: 'machine',
      );

      return;
    }

    if (isPagePushed) {
      ZegoLoggerService.logInfo(
        'page had pushed',
        tag: 'call',
        subTag: 'machine',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoCallingPage(
          pageManager: pageManager,
          callInvitationConfig: callInvitationConfig,
          inviter: pageManager.invitationData.inviter!,
          invitees: pageManager.invitationData.invitees,
          onInitState: () {
            isPagePushed = true;
          },
          onDispose: () {
            isPagePushed = false;
          },
        ),
      ),
    );
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
