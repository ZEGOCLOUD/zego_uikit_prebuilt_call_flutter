// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/minimizing/prebuilt_data.dart';

/// @nodoc
enum PrebuiltCallMiniOverlayPageState {
  idle,
  calling,
  minimizing,
}

/// @nodoc
typedef PrebuiltCallMiniOverlayMachineStateChanged = void Function(
    PrebuiltCallMiniOverlayPageState);

/// @nodoc
/// @deprecated Use ZegoUIKitPrebuiltCallMiniOverlayMachine
typedef ZegoMiniOverlayMachine = ZegoUIKitPrebuiltCallMiniOverlayMachine;

/// @nodoc
class ZegoUIKitPrebuiltCallMiniOverlayMachine {
  factory ZegoUIKitPrebuiltCallMiniOverlayMachine() => _instance;

  ZegoUIKitPrebuiltCallData? get prebuiltData => _prebuiltCallData;

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

  void changeState(
    PrebuiltCallMiniOverlayPageState state, {
    ZegoUIKitPrebuiltCallData? prebuiltData,
  }) {
    ZegoLoggerService.logInfo(
      'change state outside to $state',
      tag: 'call',
      subTag: 'overlay machine',
    );

    switch (state) {
      case PrebuiltCallMiniOverlayPageState.idle:
        _prebuiltCallData = null;
        _stateIdle.enter();

        stopDurationTimer();
        break;
      case PrebuiltCallMiniOverlayPageState.calling:
        _prebuiltCallData = null;
        _stateCalling.enter();
        break;
      case PrebuiltCallMiniOverlayPageState.minimizing:
        ZegoLoggerService.logInfo(
          'data: $_prebuiltCallData',
          tag: 'call',
          subTag: 'overlay machine',
        );
        assert(null != prebuiltData);
        _prebuiltCallData = prebuiltData;

        _stateMinimizing.enter();

        startDurationTimer();
        break;
    }
  }

  void startDurationTimer() {
    if (!(prebuiltData?.config.durationConfig.isVisible ?? true)) {
      return;
    }

    _durationStartTime = prebuiltData?.durationStartTime ?? DateTime.now();
    _durationNotifier.value = DateTime.now().difference(_durationStartTime!);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationNotifier.value = DateTime.now().difference(_durationStartTime!);
      prebuiltData?.config.durationConfig.onDurationUpdate
          ?.call(_durationNotifier.value);
    });
  }

  void stopDurationTimer() {
    _durationTimer?.cancel();

    _durationTimer = null;
  }

  /// private variables

  ZegoUIKitPrebuiltCallMiniOverlayMachine._internal() {
    init();
  }

  static final ZegoUIKitPrebuiltCallMiniOverlayMachine _instance =
      ZegoUIKitPrebuiltCallMiniOverlayMachine._internal();

  final _machine = sm.Machine<PrebuiltCallMiniOverlayPageState>();
  final List<PrebuiltCallMiniOverlayMachineStateChanged>
      _onStateChangedListeners = [];

  late sm.State<PrebuiltCallMiniOverlayPageState> _stateIdle;
  late sm.State<PrebuiltCallMiniOverlayPageState> _stateCalling;
  late sm.State<PrebuiltCallMiniOverlayPageState> _stateMinimizing;

  ZegoUIKitPrebuiltCallData? _prebuiltCallData;

  DateTime? _durationStartTime;
  Timer? _durationTimer;
  final _durationNotifier = ValueNotifier<Duration>(Duration.zero);
}
