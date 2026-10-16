// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/page/calling_page.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

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
  final ZegoCallInvitationPageManager pageManager;
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

  bool _isPagePushed = false;

  /// Whether the calling page currently owns the navigator route.
  bool get isPagePushed => _isPagePushed;

  /// Pushes [route] as the calling page, guarding against a second push.
  ///
  /// The flag is raised before `Navigator.push` rather than from the page's
  /// `initState`, so a state transition that happens between the push and the
  /// first frame cannot stack a second calling page. It is lowered when the
  /// route is done, which also covers a route that is removed before it ever
  /// gets mounted.
  ///
  /// Returns whether the route was pushed.
  bool pushCallingPage({
    required NavigatorState navigator,
    required MaterialPageRoute<void> route,
  }) {
    if (_isPagePushed) {
      return false;
    }

    _isPagePushed = true;
    try {
      navigator.push(route);
      route.completed.then((_) {
        _isPagePushed = false;
      });
      return true;
    } catch (_) {
      _isPagePushed = false;
      rethrow;
    }
  }

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call-invitation',
      subTag: 'machine',
    );

    machine.onAfterTransition.listen((event) {
      ZegoLoggerService.logInfo(
        'calling, from ${event.source} to ${event.target}',
        tag: 'call-invitation',
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
            tag: 'call-invitation',
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
    if (ZegoCallMiniOverlayPageState.inCall ==
        ZegoCallMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'entry is from calling by mini machine',
        tag: 'call-invitation',
        subTag: 'machine',
      );

      return;
    }

    // 如果页面已经推送，直接返回
    if (isPagePushed) {
      ZegoLoggerService.logInfo(
        'page had pushed',
        tag: 'call-invitation',
        subTag: 'machine',
      );
      return;
    }

    /// Capture the participants for this invitation before pushing. The page
    /// builder may run again while the route is alive (a rebuild, or a restore
    /// from the minimized overlay), and by then `invitationData` can already
    /// have been cleared by a reject, cancel or timeout.
    final inviter = pageManager.invitationData.inviter;
    if (inviter == null) {
      ZegoLoggerService.logInfo(
        'entry without an inviter, skip pushing the calling page',
        tag: 'call-invitation',
        subTag: 'machine',
      );
      return;
    }
    final invitees = List<ZegoUIKitUser>.of(
      pageManager.invitationData.invitees,
    );

    //
    // 如果当前是最小化状态，记录日志但不阻止进入通话界面
    if (ZegoCallMiniOverlayPageState.invitingMinimized ==
        ZegoCallMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'entry is from inviting minimized by mini machine, but allow to enter call',
        tag: 'call-invitation',
        subTag: 'machine',
      );
      // 不返回，继续执行进入通话界面的逻辑
    }

    ZegoLoggerService.logInfo(
      'entry, page state:${getPageState()}',
      tag: 'call-invitation',
      subTag: 'machine',
    );

    try {
      ZegoLoggerService.logInfo(
        'push from onCallingEntry, ',
        tag: 'call',
        subTag: 'machine, Navigator',
      );
      final currentContext = callInvitationData.contextQuery?.call();
      pushCallingPage(
        navigator: Navigator.of(currentContext!),
        route: MaterialPageRoute<void>(
          builder: (context) => ZegoCallingPage(
            pageManager: pageManager,
            callInvitationData: callInvitationData,
            inviter: inviter,
            invitees: invitees,
            onInitState: () {
              ZegoLoggerService.logInfo(
                'push from onCallingEntry, onInitState',
                tag: 'call',
                subTag: 'machine, Navigator',
              );
            },
            onDispose: () {
              ZegoLoggerService.logInfo(
                'push from onCallingEntry, onDispose',
                tag: 'call',
                subTag: 'machine, Navigator',
              );
            },
          ),
        ),
      );
    } catch (e) {
      ZegoLoggerService.logError(
        'Navigator push exception:$e, '
        'contextQuery:${callInvitationData.contextQuery}, ',
        tag: 'call-invitation',
        subTag: 'machine',
      );
    }
  }

  CallingState getPageState() {
    return machine.current?.identifier ?? CallingState.kIdle;
  }
}
