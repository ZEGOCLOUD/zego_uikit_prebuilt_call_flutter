// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';

/// @nodoc
typedef ZegoCallMiniOverlayMachineStateChanged = void Function(
    ZegoCallMiniOverlayPageState);

/// @nodoc
class ZegoCallMiniOverlayMachine {
  factory ZegoCallMiniOverlayMachine() => _instance;

  sm.Machine<ZegoCallMiniOverlayPageState> get machine => _machine;

  /// Check if it's in-call minimized
  bool get isInCallMinimized =>
      ZegoCallMiniOverlayPageState.inCallMinimized == state();

  /// Check if it's inviting minimized
  bool get isInvitingMinimized =>
      ZegoCallMiniOverlayPageState.invitingMinimized == state();

  ZegoCallMiniOverlayPageState state() {
    return _machine.current?.identifier ?? ZegoCallMiniOverlayPageState.idle;
  }

  DateTime durationStartTime() {
    return _durationStartTime ?? DateTime.now();
  }

  ValueNotifier<Duration> durationNotifier() {
    return _durationNotifier;
  }

  void listenStateChanged(ZegoCallMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.add(listener);

    ZegoLoggerService.logInfo(
      'add listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call-minimize',
      subTag: 'overlay machine',
    );
  }

  void removeListenStateChanged(
      ZegoCallMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.remove(listener);

    ZegoLoggerService.logInfo(
      'remove listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call-minimize',
      subTag: 'overlay machine',
    );
  }

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call-minimize',
      subTag: 'overlay machine',
    );

    _machine.onAfterTransition.listen((event) {
      ZegoLoggerService.logInfo(
        'mini overlay, from ${event.source} to ${event.target}',
        tag: 'call-minimize',
        subTag: 'overlay machine',
      );

      for (final listener in _onStateChangedListeners) {
        listener.call(_machine.current!.identifier);
      }
    });

    _stateIdle = _machine.newState(ZegoCallMiniOverlayPageState.idle);
    _stateInCall = _machine.newState(ZegoCallMiniOverlayPageState.inCall);
    _stateInCallMinimized =
        _machine.newState(ZegoCallMiniOverlayPageState.inCallMinimized);
    _stateInvitingMinimized =
        _machine.newState(ZegoCallMiniOverlayPageState.invitingMinimized);

    // Set default state
    _machine.current = _stateIdle;
  }

  void changeState(ZegoCallMiniOverlayPageState state) {
    ZegoLoggerService.logInfo(
      'change state outside to $state',
      tag: 'call-minimize',
      subTag: 'overlay machine',
    );

    switch (state) {
      case ZegoCallMiniOverlayPageState.idle:
        _stateIdle.enter();
        stopDurationTimer();
        break;
      case ZegoCallMiniOverlayPageState.inCall:
        _stateInCall.enter();
        break;
      case ZegoCallMiniOverlayPageState.inCallMinimized:
        _stateInCallMinimized.enter();
        startDurationTimer();
        break;
      case ZegoCallMiniOverlayPageState.invitingMinimized:
        _stateInvitingMinimized.enter();
        break;
    }
  }

  void startDurationTimer() {
    final durationConfig = ZegoUIKitPrebuiltCallController
        .instance.minimize.private.minimizeData?.inCall?.config.duration;
    final isVisible = durationConfig?.isVisible ?? true;
    if (!isVisible) {
      return;
    }

    _durationStartTime = ZegoUIKitPrebuiltCallController.instance.minimize
            .private.minimizeData?.inCall?.durationStartTime ??
        DateTime.now();
    _durationNotifier.value = DateTime.now().difference(_durationStartTime!);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationNotifier.value = DateTime.now().difference(_durationStartTime!);
      durationConfig?.onDurationUpdate?.call(_durationNotifier.value);
    });
  }

  void stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// private variables

  ZegoCallMiniOverlayMachine._internal() {
    init();
  }

  static final ZegoCallMiniOverlayMachine _instance =
      ZegoCallMiniOverlayMachine._internal();

  final _machine = sm.Machine<ZegoCallMiniOverlayPageState>();
  final List<ZegoCallMiniOverlayMachineStateChanged> _onStateChangedListeners =
      [];

  late sm.State<ZegoCallMiniOverlayPageState> _stateIdle;
  late sm.State<ZegoCallMiniOverlayPageState> _stateInCall;
  late sm.State<ZegoCallMiniOverlayPageState> _stateInCallMinimized;
  late sm.State<ZegoCallMiniOverlayPageState> _stateInvitingMinimized;

  DateTime? _durationStartTime;
  Timer? _durationTimer;
  final _durationNotifier = ValueNotifier<Duration>(Duration.zero);
}
