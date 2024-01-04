part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizing {
  final _minimizing = ZegoCallControllerMinimizingImpl();

  ZegoCallControllerMinimizingImpl get minimize => _minimizing;
}

class ZegoCallControllerMinimizingImpl with ZegoCallControllerMinimizePrivate {
  /// minimize state
  PrebuiltCallMiniOverlayPageState get state =>
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state();

  /// Is it currently in the minimized state or not
  bool get isMinimizing =>
      ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().isMinimizing;

  /// restore the ZegoUIKitPrebuiltCall from minimize
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    if (PrebuiltCallMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state()) {
      ZegoLoggerService.logInfo(
        'is not minimizing, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    final minimizeData = private.minimizeData;
    if (null == minimizeData) {
      ZegoLoggerService.logError(
        'prebuiltData is null',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    /// re-enter prebuilt call
    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
      PrebuiltCallMiniOverlayPageState.calling,
    );

    try {
      Navigator.of(context, rootNavigator: rootNavigator).push(
        MaterialPageRoute(builder: (context) {
          final callPage = ZegoUIKitPrebuiltCall(
            appID: minimizeData.appID,
            appSign: minimizeData.appSign,
            userID: minimizeData.userID,
            userName: minimizeData.userName,
            callID: minimizeData.callID,
            config: minimizeData.config,
            onDispose: minimizeData.onDispose,
          );
          return withSafeArea
              ? SafeArea(
                  child: callPage,
                )
              : callPage;
        }),
      );
    } catch (e) {
      ZegoLoggerService.logError(
        'navigator push to call page exception:$e',
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
    if (PrebuiltCallMiniOverlayPageState.minimizing ==
        ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state()) {
      ZegoLoggerService.logInfo(
        'is minimizing, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
      PrebuiltCallMiniOverlayPageState.minimizing,
    );

    try {
      /// pop call page
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    } catch (e) {
      ZegoLoggerService.logError(
        'navigator pop exception:$e',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    return true;
  }

  /// if call ended in minimizing state, not need to navigate, just hide the minimize widget.
  void hide() {
    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
      PrebuiltCallMiniOverlayPageState.idle,
    );
  }
}
