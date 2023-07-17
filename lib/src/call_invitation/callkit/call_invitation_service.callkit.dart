part of '../call_invitation_service.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltCallInvitationServiceCallKit {
  bool _callKitServiceInit = false;

  late ZegoInvitationPageManager _pageManager;
  late ZegoNotificationManager _notificationManager;

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

    final callKitCallID = await getCurrentCallKitCallID();
    ZegoLoggerService.logInfo(
      'callkit call id: $callKitCallID',
      tag: 'call',
      subTag: 'callkit service',
    );
    await clearAllCallKitCalls();

    _pageManager = pageManager;

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
    FlutterCallkitIncoming.onEvent.listen(_initCallKitIncomingEvent);
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

    clearCurrentCallKitCallID();
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
          case CallKitInnerVariable.iconName:
          case CallKitInnerVariable.textAppName:
          case CallKitInnerVariable.ringtonePath:
            prefs.setString(key.cacheKey, value as String? ?? key.defaultValue);
            break;
        }
      });
    });
  }

  /// for popup top notify window if app in background
  void _initCallKitIncomingEvent(CallEvent? event) {
    ZegoLoggerService.logInfo(
      'callkit incoming event, event:${event?.event}, body:${event?.body}',
      tag: 'call',
      subTag: 'callkit service',
    );

    switch (event!.event) {
      case Event.actionDidUpdateDevicePushTokenVoip:
      case Event.actionCallIncoming:
      case Event.actionCallStart:
        break;
      case Event.actionCallAccept:
        getCurrentCallKitCallID().then((callKitCallID) {
          ZegoCallKitBackgroundService()
              .acceptCallKitIncomingCauseInBackground(callKitCallID);
        });
        break;
      case Event.actionCallDecline:
      case Event.actionCallTimeout:
        ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case Event.actionCallEnded:
        _pageManager.hasCallkitIncomingCauseAppInBackground = false;

        if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
          ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
        }
        break;
      case Event.actionCallCallback:
      case Event.actionCallToggleHold:
      case Event.actionCallToggleMute:
      case Event.actionCallToggleDmtf:
      case Event.actionCallToggleGroup:
      case Event.actionCallToggleAudioSession:
        break;
      case Event.actionCallCustom:
        // TODO: Handle this case.
        break;
    }
  }
}
