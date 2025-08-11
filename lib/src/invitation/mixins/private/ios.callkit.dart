part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServiceIOSCallKitPrivatePrivate {
  final _iOSCallkitImpl =
      ZegoCallInvitationServiceIOSCallKitPrivatePrivateImpl();

  ZegoCallInvitationServiceIOSCallKitPrivatePrivateImpl get iOSCallkit =>
      _iOSCallkitImpl;
}

/// Here are the APIs related to invitation.
class ZegoCallInvitationServiceIOSCallKitPrivatePrivateImpl {
  ///
  bool _iOSCallKitServiceInit = false;

  /// callkit event subscriptions
  final List<StreamSubscription<dynamic>> _callkitServiceSubscriptions = [];

  /// init callkit service
  void _initIOSCallkitService() {
    if (_iOSCallKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had been init',
        tag: 'call-invitation',
        subTag: 'ios callkit',
      );

      return;
    }

    _iOSCallKitServiceInit = true;

    _callkitServiceSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitProviderDidResetEventStream()
          .listen(_onCallkitProviderDidResetEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitProviderDidBeginEventStream()
          .listen(_onCallkitProviderDidBeginEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitActivateAudioEventStream()
          .listen(_onCallkitActivateAudioEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitDeactivateAudioEventStream()
          .listen(_onCallkitDeactivateAudioEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitTimedOutPerformingActionEventStream()
          .listen(_onCallkitTimedOutPerformingActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformStartCallActionEventStream()
          .listen(_onCallkitPerformStartCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformAnswerCallActionEventStream()
          .listen(_onCallkitPerformAnswerCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformEndCallActionEventStream()
          .listen(_onCallkitPerformEndCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformSetHeldCallActionEventStream()
          .listen(_onCallkitPerformSetHeldCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformSetMutedCallActionEventStream()
          .listen(_onCallkitPerformSetMutedCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformSetGroupCallActionEventStream()
          .listen(_onCallkitPerformSetGroupCallActionEvent))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getCallkitPerformPlayDTMFCallActionEventStream()
          .listen(_onCallkitPerformPlayDTMFCallActionEvent));

    ZegoLoggerService.logInfo(
      'service has been inited',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );
  }

  /// un-init callkit service
  void _uninitIOSCallkitService() {
    if (!_iOSCallKitServiceInit) {
      ZegoLoggerService.logInfo(
        'callkit service had not been init',
        tag: 'call-invitation',
        subTag: 'ios callkit',
      );

      return;
    }

    _iOSCallKitServiceInit = false;
    for (final subscription in _callkitServiceSubscriptions) {
      subscription.cancel();
    }

    ZegoLoggerService.logInfo(
      'service has been uninit',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );
  }

  void _onCallkitProviderDidResetEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit provider did reset',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );
  }

  void _onCallkitProviderDidBeginEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit provider did begin',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    ZegoCallPluginPlatform.instance.activeAudioByCallKit();
  }

  void _onCallkitActivateAudioEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit activate audio',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );
  }

  void _onCallkitDeactivateAudioEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit deactivate audio',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );
  }

  void _onCallkitTimedOutPerformingActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit timeout performing action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();

    ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);
  }

  void _onCallkitPerformStartCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform start call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    ZegoCallPluginPlatform.instance.activeAudioByCallKit();

    event.fulfill?.call();

    ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);
  }

  void _onCallkitPerformAnswerCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform answer call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();

    onAnswerCallPerform() {
      ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);

      ZegoUIKitCallCache().offlineCallKit.getCallID().then((callKitCallID) {
        ZegoCallKitBackgroundService()
            .acceptCallKitIncomingCauseInBackground(callKitCallID);
        ZegoUIKitCallCache().offlineCallKit.clearCallID();
      });

      ZegoCallPluginPlatform.instance.activeAudioByCallKit();
    }

    final currentCallInvitationData = ZegoUIKitPrebuiltCallInvitationService()
        .private
        .currentCallInvitationDataSafe;
    ZegoLoggerService.logInfo(
      'currentCallInvitationData:$currentCallInvitationData',
      tag: 'call-invitation',
      subTag: 'ios callkit, on callkit perform answer call action',
    );
    if (currentCallInvitationData.isEmpty) {
      const checkMaxIterations = 10;

      /// At this point, iOS should have received an online notification
      /// Otherwise, wait
      _waitUntil(
        () {
          final currentCallInvitationData =
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .currentCallInvitationDataSafe;
          final needWait = currentCallInvitationData.isEmpty;
          if (needWait) {
            ZegoLoggerService.logInfo(
              'currentCallInvitationData:$currentCallInvitationData, is empty, waiting...',
              tag: 'call-invitation',
              subTag: 'ios callkit, on callkit perform answer call action',
            );
          }
          return !needWait;
        },
        maxIterations: checkMaxIterations,
        step: const Duration(milliseconds: 200),
      ).then((count) {
        if (count >= checkMaxIterations) {
          ZegoLoggerService.logInfo(
            'currentCallInvitationData:$currentCallInvitationData, now is failed, ',
            tag: 'call-invitation',
            subTag: 'ios callkit, on callkit perform answer call action',
          );

          ZegoCallKitBackgroundService()
              .setIOSCallKitCallingDisplayState(false);
          clearAllCallKitCalls();
        } else {
          ZegoLoggerService.logInfo(
            'currentCallInvitationData:$currentCallInvitationData, now is fine, '
            'count:$count.',
            tag: 'call-invitation',
            subTag: 'ios callkit, on callkit perform answer call action',
          );

          onAnswerCallPerform.call();
        }
      });
    } else {
      onAnswerCallPerform.call();
    }
  }

  Future<void> _onCallkitPerformEndCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) async {
    ZegoLoggerService.logInfo(
      'on callkit perform end call call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    ZegoCallKitBackgroundService().setIOSCallKitCallingDisplayState(false);

    try {
      if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
        /// exit call
        await ZegoCallKitBackgroundService().handUpCurrentCallByCallKit();
      } else {
        /// There is no need to clear CallKit here;  manually clear the CallKit ID.
        ///
        /// This is because offline calls on iOS will wake up the app,
        /// and when you reject the call for the first time,
        /// you need to wait for a certain period of time for the refusal callback.
        /// Otherwise, it will automatically reject the second offline call that comes immediately after.
        await ZegoUIKitCallCache().offlineCallKit.clearCallID();

        /// refuse call request
        await ZegoCallKitBackgroundService().refuseInvitationInBackground(
          needClearCallKit: false,
        );

        ZegoLoggerService.logInfo(
          'refuse done',
          tag: 'call-invitation',
          subTag: 'ios callkit, perform end call call action',
        );
      }
    } finally {
      ZegoLoggerService.logInfo(
        'start fulfill event action',
        tag: 'call-invitation',
        subTag: 'ios callkit, perform end call call action',
      );

      /// Delayed until zim interaction is completed
      event.fulfill?.call();
    }
  }

  void _onCallkitPerformSetHeldCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set held call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();
  }

  void _onCallkitPerformSetMutedCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set muted call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();

    // 从 actionData 中获取 muted 状态
    final actionData =
        event.actionData as ZegoSignalingPluginCallKitSetMutedActionData;
    ZegoUIKit().turnMicrophoneOn(!actionData.muted);
  }

  void _onCallkitPerformSetGroupCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set group call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();
  }

  void _onCallkitPerformPlayDTMFCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform play DTMF call action',
      tag: 'call-invitation',
      subTag: 'ios callkit',
    );

    event.fulfill?.call();
  }

  /// Waits until the specified condition is met.
  Future<int> _waitUntil(
    bool Function() test, {
    final int maxIterations = 100,
    final Duration step = const Duration(milliseconds: 10),
  }) async {
    var iterations = 0;
    for (; iterations < maxIterations; iterations++) {
      await Future.delayed(step);
      if (test()) {
        break;
      }
    }
    if (iterations >= maxIterations) {
      return iterations;
    }
    return iterations;
  }
}
