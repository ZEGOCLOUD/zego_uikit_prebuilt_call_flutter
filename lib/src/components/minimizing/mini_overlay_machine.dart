// Package imports:
import 'package:statemachine/statemachine.dart' as sm;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/prebuilt_data.dart';

enum PrebuiltCallMiniOverlayPageState {
  idle,
  calling,
  minimizing,
}

typedef PrebuiltCallMiniOverlayMachineStateChanged = void Function(
    PrebuiltCallMiniOverlayPageState);

/// @deprecated Use ZegoUIKitPrebuiltCallMiniOverlayMachine
typedef ZegoMiniOverlayMachine = ZegoUIKitPrebuiltCallMiniOverlayMachine;

class ZegoUIKitPrebuiltCallMiniOverlayMachine {
  factory ZegoUIKitPrebuiltCallMiniOverlayMachine() => _instance;

  ZegoUIKitPrebuiltCallData? get prebuiltCallData => _prebuiltCallData;

  sm.Machine<PrebuiltCallMiniOverlayPageState> get machine => _machine;

  bool get isMinimizing =>
      PrebuiltCallMiniOverlayPageState.minimizing == state();

  PrebuiltCallMiniOverlayPageState state() {
    return _machine.current?.identifier ??
        PrebuiltCallMiniOverlayPageState.idle;
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
    ZegoUIKitPrebuiltCallData? prebuiltCallData,
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
        break;
      case PrebuiltCallMiniOverlayPageState.calling:
        _prebuiltCallData = null;
        _stateCalling.enter();
        break;
      case PrebuiltCallMiniOverlayPageState.minimizing:
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
}
