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

    ZegoCallKitBackgroundService.instance.register(pageManager: pageManager);

    final callKitCallID = await ZegoUIKitCallCache().offlineCallKit.getCallID();
    ZegoLoggerService.logInfo(
      'offline callkit call id: $callKitCallID',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    /// Close the offline incoming call pop-up window
    ZegoCallPluginPlatform.instance.dismissAllNotifications();

    _myPageManager = pageManager;

    _setCallKitVariables({
      CallKitInnerVariable.callIDVisibility:
          androidNotificationConfig?.callIDVisibility ?? true,
      CallKitInnerVariable.showFullLockedScreen:
          androidNotificationConfig?.showOnLockedScreen ?? false,
      CallKitInnerVariable.ringtonePath:
          androidNotificationConfig?.callChannel.sound,
      CallKitInnerVariable.backgroundUrl:
          androidNotificationConfig?.fullScreenBackgroundAssetURL ?? '',
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
          case CallKitInnerVariable.showFullLockedScreen:
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
    final callKitEvent = adaptCallKitIncomingEvent(event);
    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.eventName}',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    switch (callKitEvent?.action) {
      case CallKitIncomingAction.incoming:
        break;
      case CallKitIncomingAction.accept:
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
      case CallKitIncomingAction.decline:
      //  slide to cancel notification
      case CallKitIncomingAction.timeout:
        ZegoLoggerService.logInfo(
          'LocalNotification, rejectCallback',
          tag: 'call-invitation',
          subTag: 'notification manager',
        );

        ZegoCallInvitationNotificationManager.hasInvitation = false;

        ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case CallKitIncomingAction.ended:
      case CallKitIncomingAction.toggleAudioSession:
      case CallKitIncomingAction.toggleMute:
      case null:
        break;
    }
  }

  /// for popup top notify window if app in background
  Future<void> _onIOSCallKitIncomingEvent(CallEvent? event) async {
    if (!Platform.isIOS) {
      return;
    }

    final callKitEvent = adaptCallKitIncomingEvent(event);
    ZegoLoggerService.logInfo(
      'online callkit incoming event, event:${event?.eventName}',
      tag: 'call-invitation',
      subTag: 'callkit',
    );

    switch (callKitEvent?.action) {
      case CallKitIncomingAction.accept:
        // Online invitations are accepted through flutter_callkit_incoming. Clear the
        // previous call's state and select the event source expected for this answer.
        ZegoUIKitPrebuiltCallInvitationService().private.iOSCallkit
            .resetCallKitAudioActivation(source: 'flutter_callkit_incoming');
        ZegoUIKitCallCache().offlineCallKit.getCallID().then((
          callKitCallID,
        ) async {
          /// https://zegocloud.feishu.cn/wiki/IDAgwKcXMisFmBkfyiic7Iw3nXb
          await ZegoUIKit().setAdvanceConfigs({
            "support_apple_callkit": "true",
          });

          await ZegoCallKitBackgroundService()
              .acceptCallKitIncomingCauseInBackground(callKitCallID);
        });
        break;
      case CallKitIncomingAction.decline:
        await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        break;
      case CallKitIncomingAction.incoming:
        break;
      case CallKitIncomingAction.toggleAudioSession:
        // Online invitations report AVAudioSession activation through this event.
        // Forward it to the shared iOS wait state used by both CallKit event sources.
        final isActive = callKitEvent?.isActive;
        if (isActive != null) {
          ZegoUIKitPrebuiltCallInvitationService().private.iOSCallkit
              .onFlutterCallKitAudioSessionChanged(isActive);
        } else {
          ZegoLoggerService.logWarn(
            'ignore CallKit audio session event without isActive state',
            tag: 'call-invitation',
            subTag: 'ios callkit audio sequencing',
          );
        }
        break;
      case CallKitIncomingAction.ended:

        /// https://zegocloud.feishu.cn/wiki/IDAgwKcXMisFmBkfyiic7Iw3nXb
        await ZegoUIKit().setAdvanceConfigs({"support_apple_callkit": "false"});

        if (ZegoUIKitPrebuiltCallInvitationService().isInCall) {
          await ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
        } else {
          await ZegoCallKitBackgroundService().refuseInvitationInBackground();
        }
        _myPageManager?.hasCallkitIncomingCauseAppInBackground = false;
        break;
      case CallKitIncomingAction.toggleMute:
        final isMute = callKitEvent?.isMuted ?? false;
        ZegoUIKit().turnMicrophoneOn(!isMute);
        break;
      case CallKitIncomingAction.timeout:
      case null:
        break;
    }

    /// update ios callkit pop-up display state
    if (callKitEvent?.action == CallKitIncomingAction.incoming) {
      ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(true);
    } else if (callKitEvent?.action == CallKitIncomingAction.decline ||
        callKitEvent?.action == CallKitIncomingAction.timeout ||
        callKitEvent?.action == CallKitIncomingAction.ended ||
        callKitEvent?.action == CallKitIncomingAction.accept) {
      ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);
    }
  }
}
