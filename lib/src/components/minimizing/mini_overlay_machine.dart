// Package imports:
import 'package:statemachine/statemachine.dart' as sm;

import 'package:zego_uikit/zego_uikit.dart';

import 'package:zego_uikit_prebuilt_call/src/components/prebuilt_data.dart';

enum MiniOverlayPageState {
  idle,
  calling,
  minimizing,
}

typedef MiniOverlayMachineStateChanged = void Function(MiniOverlayPageState);

class ZegoMiniOverlayMachine {
  factory ZegoMiniOverlayMachine() => _instance;

  ZegoUIKitPrebuiltCallData? get prebuiltCallData => _prebuiltCallData;

  sm.Machine<MiniOverlayPageState> get machine => _machine;

  void listenStateChanged(MiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.add(listener);
  }

  void removeListenStateChanged(MiniOverlayMachineStateChanged listener) {
    _onStateChangedListeners.remove(listener);
  }

  void init() {
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

    _stateIdle =
        _machine.newState(MiniOverlayPageState.idle); //  default state;
    _stateCalling = _machine.newState(MiniOverlayPageState.calling);
    _stateMinimizing = _machine.newState(MiniOverlayPageState.minimizing);
  }

  void changeState(
    MiniOverlayPageState state, {
    ZegoUIKitPrebuiltCallData? prebuiltCallData,
  }) {
    ZegoLoggerService.logInfo(
      'change state outside to $state',
      tag: 'call',
      subTag: 'overlay machine',
    );

    switch (state) {
      case MiniOverlayPageState.idle:
        _prebuiltCallData = null;
        _stateIdle.enter();
        break;
      case MiniOverlayPageState.calling:
        _prebuiltCallData = null;
        _stateCalling.enter();
        break;
      case MiniOverlayPageState.minimizing:
        ZegoLoggerService.logInfo(
          'data: ${_prebuiltCallData?.toString()}',
          tag: 'call',
          subTag: 'overlay machine',
        );
        assert(null != prebuiltCallData);
        _prebuiltCallData = prebuiltCallData;

        _stateMinimizing.enter();
        break;
    }
  }

  MiniOverlayPageState state() {
    return _machine.current?.identifier ?? MiniOverlayPageState.idle;
  }

  /// private variables

  ZegoMiniOverlayMachine._internal() {
    init();
  }

  static final ZegoMiniOverlayMachine _instance =
      ZegoMiniOverlayMachine._internal();

  final _machine = sm.Machine<MiniOverlayPageState>();
  final List<MiniOverlayMachineStateChanged> _onStateChangedListeners = [];

  late sm.State<MiniOverlayPageState> _stateIdle;
  late sm.State<MiniOverlayPageState> _stateCalling;
  late sm.State<MiniOverlayPageState> _stateMinimizing;

  ZegoUIKitPrebuiltCallData? _prebuiltCallData;
}
