part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServiceCallKitPrivate {
  final _callkitImpl = ZegoCallInvitationServiceCallKitPrivateImpl();

  /// Don't call that
  ZegoCallInvitationServiceCallKitPrivateImpl get callkit => _callkitImpl;
}

/// @nodoc
/// Here are the APIs related to invitation.
class ZegoCallInvitationServiceCallKitPrivateImpl {
  bool _callKitServiceInit = false;

  ZegoCallInvitationPageManager? _myPageManager;

  Future<void> _initCallKit({
    required ZegoCallInvitationPageManager pageManager,
    ZegoCallAndroidNotificationConfig? androidNotificationConfig,
  }) async {
    if (_callKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had been init',
        tag: 'call-invitation',
        subTag: 'callkit',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'callkit service init',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    _callKitServiceInit = true;

    ZegoCallKitBackgroundService.instance.register(
      pageManager: pageManager,
    );

    final callKitCallID = await ZegoUIKitCallCache().offlineCallKit.getCallID();
    ZegoLoggerService.logInfo(
      'offline callkit call id: $callKitCallID',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    _myPageManager = pageManager;

    _setCallKitVariables({
      CallKitInnerVariable.callIDVisibility:
          androidNotificationConfig?.callIDVisibility ?? true,
      CallKitInnerVariable.showFullScreen:
          androidNotificationConfig?.showFullScreen ?? false,
      CallKitInnerVariable.ringtonePath:
          androidNotificationConfig?.callChannel.sound,
      CallKitInnerVariable.backgroundUrl:
          androidNotificationConfig?.fullScreenBackgroundAssetURL ?? ''
    });

    ZegoLoggerService.logInfo(
      'request permission',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    ZegoLoggerService.logInfo(
      'register callkit incoming event listener',
      tag: 'call-invitation',
      subTag: 'callkit',
    );
    if (Platform.isIOS) {
      FlutterCallkitIncoming.onEvent.listen(_onIOSCallKitIncomingEvent);
    } else if (Platform.isAndroid) {
      FlutterCallkitIncoming.onEvent.listen(_onAndroidCallKitIncomingEvent);
    }
  }

  Future<void> _uninitCallKit() async {
    if (!_callKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had not been init',
        tag: 'call-invitation',
        subTag: 'callkit',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'callkit service uninit',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    _callKitServiceInit = false;

    FlutterCallkitIncoming.onEvent.listen(null);

    ZegoUIKitCallCache().offlineCallKit.clearCallID();
    ZegoUIKitCallCache().offlineCallKit.clearCacheParams();
  }

  void _setCallKitVariables(Map<CallKitInnerVariable, dynamic> variables) {
    ZegoLoggerService.logInfo(
      'set callkit variables:$variables',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    SharedPreferences.getInstance().then((prefs) {
      variables.forEach((key, value) {
        switch (key) {
          case CallKitInnerVariable.callIDVisibility:
          case CallKitInnerVariable.showFullScreen:
            prefs.setBool(key.cacheKey, value as bool? ?? key.defaultValue);
            break;
          case CallKitInnerVariable.textAccept:
          case CallKitInnerVariable.textDecline:
          case CallKitInnerVariable.textMissedCall:
          case CallKitInnerVariable.textCallback:
          case CallKitInnerVariable.backgroundColor:
          case CallKitInnerVariable.backgroundUrl:
          case CallKitInnerVariable.actionColor:
          case CallKitInnerVariable.textAppName:
          case CallKitInnerVariable.ringtonePath:
            prefs.setString(key.cacheKey, value as String? ?? key.defaultValue);
            break;
        }
      });
    });
  }

  Future<void> _onAndroidCallKitIncomingEvent(CallEvent? event) async {
    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.event}, body:${event?.body}',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    switch (event!.event) {
      case Event.actionCallIncoming:
        break;
      case Event.actionCallStart:
        break;
      case Event.actionCallAccept:
        ZegoLoggerService.logInfo(
          'LocalNotification, acceptCallback',
          tag: 'call-invitation',
          subTag: 'notification manager',
        );

        ZegoCallInvitationNotificationManager.hasInvitation = false;

        await ZegoUIKit().activeAppToForeground();
        await ZegoUIKit().requestDismissKeyguard();

        ZegoCallKitBackgroundService().acceptInvitationInBackground();
        break;
      case Event.actionCallDecline:
      //  slide to cancel notification
      case Event.actionCallTimeout:
        ZegoLoggerService.logInfo(
          'LocalNotification, rejectCallback',
          tag: 'call-invitation',
          subTag: 'notification manager',
        );

        ZegoCallInvitationNotificationManager.hasInvitation = false;

        ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case Event.actionCallEnded:
        break;
      case Event.actionCallCallback:
        break;
      case Event.actionCallCustom:
        break;
      default:
        break;
    }
  }

  /// for popup top notify window if app in background
  Future<void> _onIOSCallKitIncomingEvent(CallEvent? event) async {
    if (!Platform.isIOS) {
      return;
    }

    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.event}, body:${event?.body}',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    switch (event?.event) {
      case Event.actionCallAccept:
        ZegoUIKitCallCache()
            .offlineCallKit
            .getCallID()
            .then((callKitCallID) async {
          await ZegoCallPluginPlatform.instance.activeAudioByCallKit();
          await ZegoCallKitBackgroundService()
              .acceptCallKitIncomingCauseInBackground(callKitCallID);
        });
        break;
      case Event.actionCallDecline:
        await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case Event.actionCallIncoming:
        ZegoCallPluginPlatform.instance.activeAudioByCallKit();
        break;
      case Event.actionCallEnded:
        if (ZegoUIKitPrebuiltCallInvitationService().isInCall) {
          await ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
        } else {
          await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        }
        _myPageManager?.hasCallkitIncomingCauseAppInBackground = false;
        break;
      case Event.actionCallToggleMute:
        final params = event?.body as Map<String, dynamic>? ?? {};
        final isMute = params['isMuted'] as bool? ?? false;
        ZegoUIKit().turnMicrophoneOn(!isMute);
        break;
      default:
        break;
    }

    /// update ios callkit pop-up display state
    if (event?.event == Event.actionCallIncoming) {
      ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(true);
    } else if (event?.event == Event.actionCallDecline ||
        event?.event == Event.actionCallTimeout ||
        event?.event == Event.actionCallEnded ||
        event?.event == Event.actionCallAccept) {
      ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);
    }
  }
}
