part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizing {
  final _minimizing = ZegoCallControllerMinimizingImpl();

  ZegoCallControllerMinimizingImpl get minimize => _minimizing;
}

/// Minimization controller implementation providing call interface minimization and restoration functionality.
class ZegoCallControllerMinimizingImpl with ZegoCallControllerMinimizePrivate {
  /// Current minimization state
  ZegoCallMiniOverlayPageState get state =>
      ZegoCallMiniOverlayMachine().state();

  /// Is it currently in the minimized state or not
  bool get isMinimizing => isMinimizingNotifier.value;
  ValueNotifier<bool> get isMinimizingNotifier => _private.isMinimizingNotifier;

  /// Restore the ZegoUIKitPrebuiltCall from minimize.
  ///
  /// [context] The build context.
  /// [rootNavigator] Whether to use the root navigator.
  /// [withSafeArea] Whether to wrap with SafeArea.
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    if (ZegoCallMiniOverlayPageState.inCallMinimized != state) {
      ZegoLoggerService.logInfo(
        'restore, is not minimizing, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    final minimizeData = private.minimizeData;
    if (null == minimizeData || minimizeData.inCall == null) {
      ZegoLoggerService.logError(
        'restore, inCall data is null',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    /// ready for re-enter prebuilt call
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.inCall,
    );

    try {
      ZegoLoggerService.logInfo(
        'push from restore, ',
        tag: 'call',
        subTag: 'controller.minimize Navigator',
      );
      Navigator.of(context, rootNavigator: rootNavigator).push(
        MaterialPageRoute(builder: (context) {
          final prebuiltCall = ZegoUIKitPrebuiltCall(
            appID: minimizeData.appID,
            appSign: minimizeData.appSign,
            token: minimizeData.token,
            userID: minimizeData.userID,
            userName: minimizeData.userName,
            callID: minimizeData.callID,
            config: minimizeData.inCall!.config,
            events: minimizeData.inCall!.events,
            plugins: minimizeData.inCall!.plugins,
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

  /// Minimize the ZegoUIKitPrebuiltCall.
  ///
  /// [context] The build context.
  /// [rootNavigator] Whether to use the root navigator.
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  }) {
    if (ZegoCallMiniOverlayPageState.inCallMinimized ==
        ZegoCallMiniOverlayMachine().state()) {
      ZegoLoggerService.logInfo(
        'is minimizing now, ignore',
        tag: 'call',
        subTag: 'controller.minimize',
      );

      return false;
    }

    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.inCallMinimized,
    );

    ZegoUIKitPrebuiltCallInvitationService().private.inCallPage = false;

    try {
      ZegoLoggerService.logInfo(
        'pop from minimize, ',
        tag: 'call',
        subTag: 'controller.minimize, Navigator',
      );

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

  /// Minimize the inviting interface.
  ///
  /// [context] The build context.
  /// [rootNavigator] Whether to use the root navigator.
  /// [invitationType] The type of invitation (video or voice).
  /// [inviter] The user who initiated the invitation.
  /// [invitees] The list of users being invited.
  /// [isInviter] Whether the current user is the inviter.
  /// [pageManager] The invitation page manager.
  /// [callInvitationData] The call invitation data.
  /// [customData] Custom data to be passed with the invitation.
  bool minimizeInviting(
    BuildContext context, {
    bool rootNavigator = true,
    required ZegoCallInvitationType invitationType,
    required ZegoUIKitUser inviter,
    required List<ZegoUIKitUser> invitees,
    required bool isInviter,
    required ZegoCallInvitationPageManager pageManager,
    required ZegoUIKitPrebuiltCallInvitationData callInvitationData,
    String? customData,
  }) {
    final currentState = ZegoCallMiniOverlayMachine().state();
    if (currentState == ZegoCallMiniOverlayPageState.inCallMinimized ||
        currentState == ZegoCallMiniOverlayPageState.invitingMinimized) {
      ZegoLoggerService.logInfo(
        'is minimizing now, ignore',
        tag: 'call',
        subTag: 'controller.minimizeInviting',
      );
      return false;
    }

    // Create inviting minimized data
    final minimizeData = ZegoCallMinimizeData.inviting(
      appID: callInvitationData.appID,
      appSign: callInvitationData.appSign,
      token: callInvitationData.token,
      userID: callInvitationData.userID,
      userName: callInvitationData.userName,
      callID: pageManager.invitationData.callID,
      onDispose: null,
      invitingData: ZegoInvitingMinimizeData(
        invitationType: invitationType,
        inviter: inviter,
        invitees: invitees,
        isInviter: isInviter,
        pageManager: pageManager,
        callInvitationData: callInvitationData,
        customData: customData,
      ),
    );

    // Save minimized data
    private.updateMinimizeData(minimizeData);

    // Start listening for invitation state changes
    _listenInvitationStateChanged(pageManager);

    // Change state to inviting minimized
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.invitingMinimized,
    );

    try {
      ZegoLoggerService.logInfo(
        'pop from minimize, ',
        tag: 'call',
        subTag: 'controller.minimizeInviting, Navigator',
      );

      /// pop calling page
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    } catch (e) {
      ZegoLoggerService.logError(
        'minimize, navigator pop exception:$e',
        tag: 'call',
        subTag: 'controller.minimizeInviting',
      );

      return false;
    }

    return true;
  }

  /// Restore the inviting interface from minimized state.
  ///
  /// [context] The build context.
  /// [rootNavigator] Whether to use the root navigator.
  /// [withSafeArea] Whether to wrap with SafeArea.
  bool restoreInviting(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  }) {
    final state = ZegoCallMiniOverlayMachine().state();
    ZegoLoggerService.logInfo(
      'restoreInviting called, current state: $state',
      tag: 'call',
      subTag: 'controller.minimize',
    );

    if (state != ZegoCallMiniOverlayPageState.invitingMinimized) {
      ZegoLoggerService.logInfo(
        'restoreInviting failed, invalid state: $state',
        tag: 'call',
        subTag: 'controller.minimize',
      );
      return false;
    }

    final minimizeData = private.minimizeData;
    final invitingData = minimizeData?.inviting;

    if (invitingData == null) {
      ZegoLoggerService.logInfo(
        'restoreInviting failed, inviting data is null',
        tag: 'call',
        subTag: 'controller.minimize',
      );
      return false;
    }

    ZegoLoggerService.logInfo(
      'restoreInviting, pushing ZegoCallingPage',
      tag: 'call',
      subTag: 'controller.minimize',
    );

    // Recreate the inviting page
    try {
      Navigator.of(context, rootNavigator: rootNavigator).push(
        MaterialPageRoute(builder: (context) {
          return ZegoCallingPage(
            pageManager: invitingData.pageManager,
            callInvitationData: invitingData.callInvitationData,
            inviter: invitingData.inviter,
            invitees: invitingData.invitees,
            onInitState: () {
              ZegoLoggerService.logInfo(
                'ZegoCallingPage onInitState called, setting overlay state to idle',
                tag: 'call',
                subTag: 'controller.minimize',
              );
              invitingData.pageManager.callingMachine?.isPagePushed = true;
              // When the inviting interface is restored, set the overlay state to idle
              ZegoCallMiniOverlayMachine()
                  .changeState(ZegoCallMiniOverlayPageState.idle);
            },
            onDispose: () {
              ZegoLoggerService.logInfo(
                'ZegoCallingPage onDispose called',
                tag: 'call',
                subTag: 'controller.minimize',
              );
              invitingData.pageManager.callingMachine?.isPagePushed = false;
            },
          );
        }),
      );
      return true;
    } catch (e) {
      ZegoLoggerService.logError(
        'restoreInviting, navigator push exception:$e',
        tag: 'call',
        subTag: 'controller.minimize',
      );
      return false;
    }
  }

  /// if call ended in minimizing state, not need to navigate, just hide the minimize widget.
  void hide() {
    ZegoLoggerService.logInfo(
      'hide',
      tag: 'call',
      subTag: 'controller.minimize',
    );

    ZegoUIKitPrebuiltCallInvitationService().private.clearInvitation();

    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.idle,
    );
  }

  /// Listens for changes in the invitation state machine
  /// This method sets up callbacks to handle state transitions during the invitation process
  ///
  /// [pageManager] The invitation page manager that contains the calling state machine
  void _listenInvitationStateChanged(
      ZegoCallInvitationPageManager pageManager) {
    // Listen for state changes in the calling state machine
    pageManager.callingMachine?.onStateChanged = (CallingState state) {
      ZegoLoggerService.logInfo(
        'invitation state changed: $state, current overlay state: ${ZegoCallMiniOverlayMachine().state()}',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );

      if (state == CallingState.kOnlineAudioVideo) {
        // When transitioning from inviting to online audio/video, auto-convert minimization state
        // This handles the case where the invitation was accepted while minimized
        final currentState = ZegoCallMiniOverlayMachine().state();
        if (currentState == ZegoCallMiniOverlayPageState.invitingMinimized) {
          ZegoLoggerService.logInfo(
            'invitation accepted, auto convert to calling minimized state',
            tag: 'call-minimize',
            subTag: 'controller.minimize',
          );

          // Immediately convert the state to ensure the call page can initialize correctly
          _autoConvertToInCallMinimized();
        }
      } else if (state == CallingState.kCallingWithVideo ||
          state == CallingState.kCallingWithVoice) {
        // When the state changes to calling, don't convert the overlay state yet
        // This is just the invitation being sent successfully, not the call starting
        ZegoLoggerService.logInfo(
          'invitation state changed to calling, but not converting overlay state yet',
          tag: 'call-minimize',
          subTag: 'controller.minimize',
        );
      }
    };

    // Listen for invitation events to handle invitation termination scenarios
    _listenInvitationEvents(pageManager);
  }

  /// Listen for invitation events
  void _listenInvitationEvents(ZegoCallInvitationPageManager pageManager) {
    // Listen for invitation being declined
    pageManager.callInvitationData.invitationEvents
        ?.onIncomingCallDeclineButtonPressed = () {
      ZegoLoggerService.logInfo(
        'invitation declined, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for invitation being canceled
    pageManager.callInvitationData.invitationEvents
        ?.onOutgoingCallCancelButtonPressed = () {
      ZegoLoggerService.logInfo(
        'invitation canceled, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for invitation timeout
    pageManager.callInvitationData.invitationEvents?.onIncomingCallTimeout =
        (String callID, ZegoCallUser inviter) {
      ZegoLoggerService.logInfo(
        'invitation timeout, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for invitation response timeout
    pageManager.callInvitationData.invitationEvents?.onOutgoingCallTimeout =
        (String callID, List<ZegoCallUser> invitees, bool isVideoCall) {
      ZegoLoggerService.logInfo(
        'invitation response timeout, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for invitation being rejected (busy)
    pageManager.callInvitationData.invitationEvents
            ?.onOutgoingCallRejectedCauseBusy =
        (String callID, ZegoCallUser invitee, String customData) {
      ZegoLoggerService.logInfo(
        'invitation rejected (busy), hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for invitation being declined (actively declined)
    pageManager.callInvitationData.invitationEvents?.onOutgoingCallDeclined =
        (String callID, ZegoCallUser invitee, String customData) {
      ZegoLoggerService.logInfo(
        'invitation declined, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };

    // Listen for incoming call being canceled
    pageManager.callInvitationData.invitationEvents?.onIncomingCallCanceled =
        (String callID, ZegoCallUser caller, String customData) {
      ZegoLoggerService.logInfo(
        'incoming call canceled, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    };
  }

  /// Automatically convert to in-call minimized state
  void _autoConvertToInCallMinimized() {
    final minimizeData = private.minimizeData;
    final invitingData = minimizeData?.inviting;

    if (invitingData != null) {
      ZegoLoggerService.logInfo(
        'auto converting to in-call minimized, immediately hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );

      // Create in-call minimized data
      final inCallData = ZegoInCallMinimizeData(
        config: _convertCallingConfigToPrebuiltConfig(
            invitingData.pageManager.callingConfig),
        events: invitingData.callInvitationData.events ??
            ZegoUIKitPrebuiltCallEvents(),
        isPrebuiltFromMinimizing: true,
        plugins: invitingData.callInvitationData.plugins,
        durationStartTime: DateTime.now(),
      );

      // Create new minimized data
      final newMinimizeData = ZegoCallMinimizeData.inCall(
        appID: minimizeData!.appID,
        appSign: minimizeData.appSign,
        token: minimizeData.token,
        userID: minimizeData.userID,
        userName: minimizeData.userName,
        callID: minimizeData.callID,
        onDispose: minimizeData.onDispose,
        inCallData: inCallData,
      );

      // Update minimized data
      private.updateMinimizeData(newMinimizeData);

      // Immediately hide overlay to ensure call page initializes with idle state
      ZegoCallMiniOverlayMachine()
          .changeState(ZegoCallMiniOverlayPageState.idle);

      // Clear minimized data to prevent call page from detecting non-idle state during initialization
      private.clearMinimizeData();

      ZegoLoggerService.logInfo(
        'overlay hidden and data cleared, call page should initialize correctly',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
    }
  }

  /// Convert calling config to prebuilt call config
  ZegoUIKitPrebuiltCallConfig _convertCallingConfigToPrebuiltConfig(
    ZegoUIKitPrebuiltCallingConfig callingConfig,
  ) {
    // Here we need to create corresponding prebuiltConfig based on callingConfig
    // Temporarily return a default config, actual usage needs to be perfected based on business logic
    return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
  }
}
