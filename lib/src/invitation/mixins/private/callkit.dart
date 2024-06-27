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

    final callKitCallID = await getOfflineCallKitCallID();
    ZegoLoggerService.logInfo(
      'offline callkit call id: $callKitCallID',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    /// In iOS, it is not necessary to explicitly clear the call as it may result in automatically disconnecting the offline call.
    if (Platform.isAndroid) {
      await clearAllCallKitCalls();
    }

    _myPageManager = pageManager;

    _setCallKitVariables({
      CallKitInnerVariable.callIDVisibility:
          androidNotificationConfig?.callIDVisibility ?? true,
      CallKitInnerVariable.showFullScreen:
          androidNotificationConfig?.showFullScreen ?? false,
      CallKitInnerVariable.ringtonePath: androidNotificationConfig?.sound,
      CallKitInnerVariable.backgroundUrl:
          androidNotificationConfig?.fullScreenBackground ?? ''
    });

    ZegoLoggerService.logInfo(
      'register callkit incoming event listener',
      tag: 'call-invitation',
      subTag: 'callkit',
    );
    FlutterCallkitIncoming.onEvent.listen(_onOnlineCallKitIncomingEvent);
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

    clearOfflineCallKitCallID();
    clearOfflineCallKitCacheParams();
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

  /// for popup top notify window if app in background
  Future<void> _onOnlineCallKitIncomingEvent(CallEvent? event) async {
    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.event}, body:${event?.body}',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    switch (event!.event) {
      case Event.actionCallIncoming:
        ZegoCallPluginPlatform.instance.activeAudioByCallKit();
        break;
      case Event.actionCallAccept:
        getOfflineCallKitCallID().then((callKitCallID) async {
          await ZegoCallPluginPlatform.instance.activeAudioByCallKit();
          await ZegoCallKitBackgroundService()
              .acceptCallKitIncomingCauseInBackground(callKitCallID);
        });
        break;
      case Event.actionCallDecline:
        await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case Event.actionCallTimeout:
        if (Platform.isAndroid) {
          await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        } else {
          /// will call actionCallDecline before actionCallTimeout,
          /// iOS not need to do with actionCallTimeout
        }
        break;
      case Event.actionCallEnded:
        _myPageManager?.hasCallkitIncomingCauseAppInBackground = false;
        if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
          await ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
        }

        break;
      case Event.actionCallToggleMute:
        final params = event.body as Map<String, dynamic>? ?? {};
        final isMute = params['isMuted'] as bool? ?? false;
        ZegoUIKit().turnMicrophoneOn(!isMute);
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
      case Event.actionCallStart:
      case Event.actionCallCallback:
      case Event.actionCallToggleHold:
      case Event.actionCallToggleDmtf:
      case Event.actionCallToggleGroup:
      case Event.actionCallToggleAudioSession:
      case Event.actionCallCustom:
        break;
    }

    /// update ios callkit pop-up display state
    if (Platform.isIOS) {
      switch (event.event) {
        case Event.actionCallIncoming:
          ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(true);
          break;
        case Event.actionCallAccept:
        case Event.actionCallDecline:
        case Event.actionCallTimeout:
        case Event.actionCallEnded:
          ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(
            false,
          );
          break;
        default:
          break;
      }
    }
  }
}
