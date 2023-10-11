part of '../call_invitation_service.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltCallInvitationServiceCallKit {
  bool _callKitServiceInit = false;

  ZegoInvitationPageManager? _myPageManager;
  ZegoNotificationManager? _notificationManager;

  Future<void> _initCallKit({
    required ZegoInvitationPageManager pageManager,
    required bool showDeclineButton,
    required ZegoCallInvitationConfig callInvitationConfig,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
  }) async {
    if (_callKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had been init',
        tag: 'call',
        subTag: 'callkit service',
      );

      return;
    }

    _callKitServiceInit = true;

    ZegoCallKitBackgroundService.instance.register(
      pageManager: pageManager,
    );

    final callKitCallID = await getOfflineCallKitCallID();
    ZegoLoggerService.logInfo(
      'offline callkit call id: $callKitCallID',
      tag: 'call',
      subTag: 'callkit service',
    );

    /// In iOS, it is not necessary to explicitly clear the call as it may result in automatically disconnecting the offline call.
    if (Platform.isAndroid) {
      await clearAllCallKitCalls();
    }

    _myPageManager = pageManager;

    _setCallKitVariables({
      CallKitInnerVariable.callIDVisibility:
          androidNotificationConfig?.callIDVisibility ?? true,
      CallKitInnerVariable.ringtonePath: androidNotificationConfig?.sound,
    });

    ZegoLoggerService.logInfo(
      'register callkit incoming event listener',
      tag: 'call',
      subTag: 'callkit service',
    );
    FlutterCallkitIncoming.onEvent.listen(_onOnlineCallKitIncomingEvent);
  }

  Future<void> _uninitCallKit() async {
    if (!_callKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had not been init',
        tag: 'call',
        subTag: 'callkit service',
      );

      return;
    }

    _callKitServiceInit = false;

    ZegoLoggerService.logInfo(
      'unregister callkit incoming event listener',
      tag: 'call',
      subTag: 'callkit service',
    );
    FlutterCallkitIncoming.onEvent.listen(null);

    clearOfflineCallKitCallID();
    clearOfflineCallKitParams();
  }

  void _setCallKitVariables(Map<CallKitInnerVariable, dynamic> variables) {
    ZegoLoggerService.logInfo(
      'set callkit variables:$variables',
      tag: 'call',
      subTag: 'callkit service',
    );

    SharedPreferences.getInstance().then((prefs) {
      variables.forEach((key, value) {
        switch (key) {
          case CallKitInnerVariable.callIDVisibility:
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
  void _onOnlineCallKitIncomingEvent(CallEvent? event) {
    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.event}, body:${event?.body}',
      tag: 'call',
      subTag: 'callkit service',
    );

    switch (event!.event) {
      case Event.actionCallIncoming:
        ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
        break;
      case Event.actionCallAccept:
        getOfflineCallKitCallID().then((callKitCallID) {
          ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
          ZegoCallKitBackgroundService()
              .acceptCallKitIncomingCauseInBackground(callKitCallID);
        });
        break;
      case Event.actionCallDecline:
        ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case Event.actionCallTimeout:
        if (Platform.isAndroid) {
          ZegoCallKitBackgroundService().refuseInvitationInBackground();
        } else {
          /// will call actionCallDecline before actionCallTimeout,
          /// iOS not need to do with actionCallTimeout
        }
        break;
      case Event.actionCallEnded:
        _myPageManager?.hasCallkitIncomingCauseAppInBackground = false;

        if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
          ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
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
  }
}
