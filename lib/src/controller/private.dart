part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerPrivate {
  final _private = ZegoCallControllerPrivateImpl();

  /// Don't call that
  ZegoCallControllerPrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerPrivateImpl {
  /// Whether the call hang-up operation is in progress
  /// such as clicking the close button in the upper right corner or calling the `hangUp` function of the controller.
  /// If it is not handled completely, it is considered as in progress.
  final ValueNotifier<bool> isHangUpRequestingNotifier =
      ValueNotifier<bool>(false);

  /// ZegoUIKitPrebuiltCall's config
  ZegoUIKitPrebuiltCallConfig? get prebuiltConfig => _prebuiltConfig;

  ZegoUIKitPrebuiltCallEvents? get events => _events;

  ZegoUIKitPrebuiltCallConfig? _prebuiltConfig;
  ZegoUIKitPrebuiltCallEvents? _events;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig prebuiltConfig,
    required ZegoUIKitPrebuiltCallEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.p',
    );

    _prebuiltConfig = prebuiltConfig;
    _events = events;
  }

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.p',
    );

    isHangUpRequestingNotifier.value = false;

    _prebuiltConfig = null;
    _events = null;
  }

  Future<void> defaultCallEndEvent(
    ZegoUIKitCallEndEvent event,
    BuildContext context,
    bool rootNavigator,
  ) async {
    ZegoLoggerService.logInfo(
      'default call end event, event:$event',
      tag: 'call',
      subTag: 'controller.p',
    );

    if (PrebuiltCallMiniOverlayPageState.idle !=
        ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state()) {
      /// now is minimizing state, not need to navigate, just switch to idle
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
        PrebuiltCallMiniOverlayPageState.idle,
      );
    } else {
      try {
        Navigator.of(
          context,
          rootNavigator: rootNavigator,
        ).pop(true);
      } catch (e) {
        ZegoLoggerService.logError(
          'call end, navigator exception:$e, event:$event',
          tag: 'call',
          subTag: 'controller.p',
        );
      }
    }
  }
}
