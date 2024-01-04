// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';

/// @nodoc
typedef PrebuiltCallMiniOverlayMachineStateChanged = void Function(
    PrebuiltCallMiniOverlayPageState);

/// @nodoc
class ZegoUIKitPrebuiltCallMiniOverlayInternalMachine {
  factory ZegoUIKitPrebuiltCallMiniOverlayInternalMachine() => _instance;

  sm.Machine<PrebuiltCallMiniOverlayPageState> get machine => _machine;

  bool get isMinimizing =>
      PrebuiltCallMiniOverlayPageState.minimizing == state();

  PrebuiltCallMiniOverlayPageState state() {
    return _machine.current?.identifier ??
        PrebuiltCallMiniOverlayPageState.idle;
  }

  DateTime durationStartTime() {
    return _durationStartTime ?? DateTime.now();
  }

  ValueNotifier<Duration> durationNotifier() {
    return _durationNotifier;
  }

  void listenStateChanged(PrebuiltCallMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.add(listener);

    ZegoLoggerService.logInfo(
      'add listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call',
      subTag: 'overlay machine',
    );
  }

  void removeListenStateChanged(
      PrebuiltCallMiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.remove(listener);

    ZegoLoggerService.logInfo(
      'remove listener:$listener, size:${_onStateChangedListeners.length}',
      tag: 'call',
      subTag: 'overlay machine',
    );
  }

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call',
      subTag: 'overlay machine',
    );

    _machine.onAfterTransition.listen((event) {
      ZegoLoggerService.logInfo(
        'mini overlay, from ${event.source} to ${event.target}',
        tag: 'call',
        subTag: 'overlay machine',
      );

      for (final listener in _onStateChangedListeners) {
        listener.call(_machine.current!.identifier);
      }
    });

    _stateIdle = _machine
        .newState(PrebuiltCallMiniOverlayPageState.idle); //  default state;
    _stateCalling = _machine.newState(PrebuiltCallMiniOverlayPageState.calling);
    _stateMinimizing =
        _machine.newState(PrebuiltCallMiniOverlayPageState.minimizing);
  }

  void changeState(PrebuiltCallMiniOverlayPageState state) {
    ZegoLoggerService.logInfo(
      'change state outside to $state',
      tag: 'call',
      subTag: 'overlay machine',
    );

    switch (state) {
      case PrebuiltCallMiniOverlayPageState.idle:
        _stateIdle.enter();

        stopDurationTimer();
        break;
      case PrebuiltCallMiniOverlayPageState.calling:
        _stateCalling.enter();
        break;
      case PrebuiltCallMiniOverlayPageState.minimizing:
        _stateMinimizing.enter();

        startDurationTimer();
        break;
    }
  }

  void startDurationTimer() {
    final durationConfig = ZegoUIKitPrebuiltCallController
        .instance.minimize.private.minimizeData?.config.durationConfig;
    final isVisible = durationConfig?.isVisible ?? true;
    if (!isVisible) {
      return;
    }

    _durationStartTime = ZegoUIKitPrebuiltCallController
            .instance.minimize.private.minimizeData?.durationStartTime ??
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

  ZegoUIKitPrebuiltCallMiniOverlayInternalMachine._internal() {
    init();
  }

  static final ZegoUIKitPrebuiltCallMiniOverlayInternalMachine _instance =
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine._internal();

  final _machine = sm.Machine<PrebuiltCallMiniOverlayPageState>();
  final List<PrebuiltCallMiniOverlayMachineStateChanged>
      _onStateChangedListeners = [];

  late sm.State<PrebuiltCallMiniOverlayPageState> _stateIdle;
  late sm.State<PrebuiltCallMiniOverlayPageState> _stateCalling;
  late sm.State<PrebuiltCallMiniOverlayPageState> _stateMinimizing;

  DateTime? _durationStartTime;
  Timer? _durationTimer;
  final _durationNotifier = ValueNotifier<Duration>(Duration.zero);
}
