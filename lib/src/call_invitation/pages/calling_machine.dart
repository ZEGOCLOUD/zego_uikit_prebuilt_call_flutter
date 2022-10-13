// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

// Project imports:
import 'calling_page.dart';
import 'page_manager.dart';

// Project imports:

enum CallingState {
  kIdle,
  //  voice call request
  kCallingWithVoice,
  //  video call request
  kCallingWithVideo,
  //  in voice call
  kOnlineAudioVideo,
}

typedef CallingMachineStateChanged = void Function(CallingState);

/// State machine in the call
class ZegoCallingMachine {
  final machine = sm.Machine<CallingState>();
  CallingMachineStateChanged? onStateChanged;

  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineAudioVideo;

  bool isPagePushed = false;

  BuildContext get context => ZegoInvitationPageManager.instance.contextQuery();

  void init() {
    machine.onAfterTransition.listen((event) {
      debugPrint('calling, from ${event.source} to ${event.target}');

      if (null != onStateChanged) {
        onStateChanged!(machine.current!.identifier);
      }
    });

    stateIdle = machine.newState(CallingState.kIdle)
      ..onEntry(
        () {
          debugPrint("calling machine to be idle");
        },
      ); // default state

    stateCallingWithVoice = machine.newState(CallingState.kCallingWithVoice)
      ..onEntry(onCallingEntry);
    stateCallingWithVideo = machine.newState(CallingState.kCallingWithVideo)
      ..onEntry(onCallingEntry);
    stateOnlineAudioVideo = machine.newState(CallingState.kOnlineAudioVideo)
      ..onEntry(onCallingEntry);
  }

  void onCallingEntry() {
    if (isPagePushed) {
      debugPrint("page had pushed");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZegoCallingPage(
          inviter: ZegoInvitationPageManager.instance.invitationData.inviter!,
          invitees: ZegoInvitationPageManager.instance.invitationData.invitees,
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
