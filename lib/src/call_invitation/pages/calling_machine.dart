// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_page.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

// Project imports:

/// @nodoc
enum CallingState {
  kIdle,
  //  voice call request
  kCallingWithVoice,
  //  video call request
  kCallingWithVideo,
  //  in call
  kOnlineAudioVideo,
}

/// @nodoc
typedef CallingMachineStateChanged = void Function(CallingState);

/// @nodoc
/// State machine in the call
class ZegoCallingMachine {
  final ZegoInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  ZegoCallingMachine({
    required this.pageManager,
    required this.callInvitationData,
  });

  final machine = sm.Machine<CallingState>();
  CallingMachineStateChanged? onStateChanged;

  late sm.State<CallingState> stateIdle;
  late sm.State<CallingState> stateCallingWithVoice;
  late sm.State<CallingState> stateCallingWithVideo;
  late sm.State<CallingState> stateOnlineAudioVideo;

  bool isPagePushed = false;

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call',
      subTag: 'machine',
    );

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
    if (ZegoCallMiniOverlayPageState.calling ==
        ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state()) {
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

    try {
      final currentContext = callInvitationData.contextQuery?.call();
      Navigator.of(currentContext!).push(
        MaterialPageRoute(
          builder: (context) => ZegoCallingPage(
            pageManager: pageManager,
            callInvitationData: callInvitationData,
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
    } catch (e) {
      ZegoLoggerService.logError(
        'Navigator push exception:$e, '
        'contextQuery:${callInvitationData.contextQuery}, ',
        tag: 'call',
        subTag: 'machine',
      );
    }
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
