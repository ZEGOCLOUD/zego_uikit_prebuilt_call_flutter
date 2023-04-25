// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/call_invitation_service.dart';

mixin ZegoPrebuiltCallKitService {
  bool _callkitServiceInited = false;
  final List<StreamSubscription<dynamic>> callkitServiceSubscriptions = [];

  void initCallkitService() {
    if (_callkitServiceInited) {
      ZegoLoggerService.logInfo(
        'callkit service had been inited',
        tag: 'call',
        subTag: 'callkit service',
      );

      return;
    }

    _callkitServiceInited = true;
    callkitServiceSubscriptions
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
  }

  void uninitCallkitService() {
    if (!_callkitServiceInited) {
      ZegoLoggerService.logInfo(
        'callkit service had not been inited',
        tag: 'call',
        subTag: 'callkit service',
      );

      return;
    }

    _callkitServiceInited = false;
    for (final subscription in callkitServiceSubscriptions) {
      subscription.cancel();
    }
  }

  void _onCallkitProviderDidResetEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit provider did reset',
      tag: 'call',
      subTag: 'callkit service',
    );
  }

  void _onCallkitProviderDidBeginEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit provider did begin',
      tag: 'call',
      subTag: 'callkit service',
    );

    ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
  }

  void _onCallkitActivateAudioEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit activate audio',
      tag: 'call',
      subTag: 'callkit service',
    );
  }

  void _onCallkitDeactivateAudioEvent(
    ZegoSignalingPluginCallKitVoidEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit deactivate audio',
      tag: 'call',
      subTag: 'callkit service',
    );
  }

  void _onCallkitTimedOutPerformingActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit timeout performing action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();
  }

  void _onCallkitPerformStartCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform start call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();

    event.action.fulfill();
  }

  void _onCallkitPerformAnswerCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform answer call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();

    event.action.fulfill();

    ZegoUIKitPrebuiltCallInvitationService()
        .acceptCallKitIncomingCauseInBackground(
            ZegoUIKitPrebuiltCallInvitationService().callKitCallID);
    ZegoUIKitPrebuiltCallInvitationService().callKitCallID = null;
  }

  void _onCallkitPerformEndCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform end call call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();

    if (ZegoUIKitPrebuiltCallInvitationService().isInCalling) {
      /// exit call
      ZegoUIKitPrebuiltCallInvitationService().handUpCurrentCallByCallKit();
    } else {
      /// refuse call request
      ZegoUIKitPrebuiltCallInvitationService()
          .refuseCallKitIncomingCauseInBackground();
    }
  }

  void _onCallkitPerformSetHeldCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set held call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();
  }

  void _onCallkitPerformSetMutedCallActionEvent(
    ZegoSignalingPluginCallKitSetMutedCallActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set muted call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();

    ZegoUIKit().turnMicrophoneOn(!event.action.muted);
  }

  void _onCallkitPerformSetGroupCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform set group call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();
  }

  void _onCallkitPerformPlayDTMFCallActionEvent(
    ZegoSignalingPluginCallKitActionEvent event,
  ) {
    ZegoLoggerService.logInfo(
      'on callkit perform play DTMF call action',
      tag: 'call',
      subTag: 'callkit service',
    );

    event.action.fulfill();
  }
}
