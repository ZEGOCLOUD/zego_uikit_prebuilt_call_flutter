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

  ZegoCallPopUpManager? _popUpManager;
  ZegoUIKitPrebuiltCallConfig? _prebuiltConfig;
  ZegoUIKitPrebuiltCallEvents? _events;

  /// Please do not call this interface. It is the internal logic of ZegoUIKitPrebuiltCall.
  void initByPrebuilt({
    required ZegoUIKitPrebuiltCallConfig prebuiltConfig,
    required ZegoCallPopUpManager popUpManager,
    required ZegoUIKitPrebuiltCallEvents? events,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.p',
    );

    _prebuiltConfig = prebuiltConfig;
    _popUpManager = _popUpManager;
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
    _popUpManager = null;
    _events = null;
  }

  Future<bool> defaultHangUpConfirmationAction(
    ZegoCallHangUpConfirmationEvent event,
    BuildContext context,
  ) async {
    if (_prebuiltConfig?.hangUpConfirmDialog.info == null) {
      return true;
    }

    final key = DateTime.now().millisecondsSinceEpoch;
    _popUpManager?.addAPopUpSheet(key);

    final dialogInfo = _prebuiltConfig?.hangUpConfirmDialog.info ??
        ZegoCallHangUpConfirmDialogInfo();
    return showAlertDialog(
      event.context,
      dialogInfo.title,
      dialogInfo.message,
      [
        CupertinoDialogAction(
          child: Text(
            dialogInfo.cancelButtonName,
            style: TextStyle(fontSize: 26.zR, color: const Color(0xff0055FF)),
          ),
          onPressed: () {
            //  pop this dialog
            try {
              Navigator.of(
                context,
                rootNavigator: _prebuiltConfig?.rootNavigator ?? false,
              ).pop(false);
            } catch (e) {
              ZegoLoggerService.logError(
                'call hangup confirmation, '
                'navigator exception:$e, '
                'event:$event',
                tag: 'call',
                subTag: 'controller.p',
              );
            }
          },
        ),
        CupertinoDialogAction(
          child: Text(
            dialogInfo.confirmButtonName,
            style: TextStyle(fontSize: 26.zR, color: Colors.white),
          ),
          onPressed: () {
            //  pop this dialog
            try {
              Navigator.of(
                context,
                rootNavigator: _prebuiltConfig?.rootNavigator ?? false,
              ).pop(true);
            } catch (e) {
              ZegoLoggerService.logError(
                'call hangup confirmation, '
                'navigator exception:$e, '
                'event:$event',
                tag: 'call',
                subTag: 'controller.p',
              );
            }
          },
        ),
      ],
      titleStyle: _prebuiltConfig?.hangUpConfirmDialog.titleStyle,
      contentStyle: _prebuiltConfig?.hangUpConfirmDialog.contentStyle,
      backgroundBrightness:
          _prebuiltConfig?.hangUpConfirmDialog.backgroundBrightness,
    ).then((result) {
      _popUpManager?.removeAPopUpSheet(key);

      return result;
    });
  }

  Future<void> defaultEndEvent(
    ZegoCallEndEvent event,
    BuildContext context,
  ) async {
    ZegoLoggerService.logInfo(
      'default call end event, event:$event',
      tag: 'call',
      subTag: 'controller.p',
    );

    if (ZegoCallMiniOverlayPageState.idle !=
        ZegoCallMiniOverlayMachine().state()) {
      /// now is minimizing state, not need to navigate, just switch to idle
      ZegoUIKitPrebuiltCallController().minimize.hide();
    } else {
      try {
        Navigator.of(
          context,
          rootNavigator: _prebuiltConfig?.rootNavigator ?? false,
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
