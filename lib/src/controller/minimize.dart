part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizing {
  final _minimizing = ZegoCallControllerMinimizingImpl();

  ZegoCallControllerMinimizingImpl get minimize => _minimizing;
}

class ZegoCallControllerMinimizingImpl with ZegoCallControllerMinimizePrivate {
  /// minimize state
  ZegoCallMiniOverlayPageState get state =>
      ZegoCallMiniOverlayMachine().state();

  /// Is it currently in the minimized state or not
  bool get isMinimizing => isMinimizingNotifier.value;
  ValueNotifier<bool> get isMinimizingNotifier => _private.isMinimizingNotifier;

  /// restore the ZegoUIKitPrebuiltCall from minimize
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    if (ZegoCallMiniOverlayPageState.minimizing != state) {
      ZegoLoggerService.logInfo(
        'restore, is not minimizing, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    final minimizeData = private.minimizeData;
    if (null == minimizeData) {
      ZegoLoggerService.logError(
        'restore, prebuiltData is null',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    /// re-enter prebuilt call
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.calling,
    );

    try {
      Navigator.of(context, rootNavigator: rootNavigator).push(
        MaterialPageRoute(builder: (context) {
          final prebuiltCall = ZegoUIKitPrebuiltCall(
            appID: minimizeData.appID,
            appSign: minimizeData.appSign,
            token: minimizeData.token,
            userID: minimizeData.userID,
            userName: minimizeData.userName,
            callID: minimizeData.callID,
            config: minimizeData.config,
            events: minimizeData.events,
            plugins: minimizeData.plugins,
            onDispose: minimizeData.onDispose,
          );
          return withSafeArea
              ? SafeArea(
                  child: prebuiltCall,
                )
              : prebuiltCall;
        }),
      );
    } catch (e) {
      ZegoLoggerService.logError(
        'restore, navigator push to call page exception:$e',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    return true;
  }

  /// To minimize the ZegoUIKitPrebuiltCall
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  }) {
    if (ZegoCallMiniOverlayPageState.minimizing ==
        ZegoCallMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'minimize, is minimizing, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.minimizing,
    );

    try {
      /// pop call page
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    } catch (e) {
      ZegoLoggerService.logError(
        'minimize, navigator pop exception:$e',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    return true;
  }

  /// if call ended in minimizing state, not need to navigate, just hide the minimize widget.
  void hide() {
    ZegoLoggerService.logError(
      'hide',
      tag: 'call',
      subTag: 'controller.minimize',
    );

    ZegoUIKitPrebuiltCallInvitationService().private.clearInvitation();

    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.idle,
    );
  }
}
