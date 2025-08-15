part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizing {
  final _minimizing = ZegoCallControllerMinimizingImpl();

  ZegoCallControllerMinimizingImpl get minimize => _minimizing;
}

class ZegoCallControllerMinimizingImpl with ZegoCallControllerMinimizePrivate {
  /// minimize state
  ZegoCallMiniOverlayPageState get state =>
      ZegoCallMiniOverlayMachine().state();

  /// Is it currently in the minimized state or not
  bool get isMinimizing => isMinimizingNotifier.value;
  ValueNotifier<bool> get isMinimizingNotifier => _private.isMinimizingNotifier;

  /// 恢复通话中界面
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

    /// re-enter prebuilt call
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.idle,
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

  /// To minimize the ZegoUIKitPrebuiltCall
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

  /// 最小化邀请中界面
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

    // 创建邀请中最小化数据
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

    // 保存最小化数据
    private.updateMinimizeData(minimizeData);

    // 开始监听邀请状态变化
    _listenInvitationStateChanged(pageManager);

    // 改变状态为邀请中最小化
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

  /// 恢复邀请中界面
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

    // 重新创建邀请中页面
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
              // 当邀请界面被恢复后，将悬浮窗口状态设置为idle
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

  /// 监听邀请状态变化
  void _listenInvitationStateChanged(
      ZegoCallInvitationPageManager pageManager) {
    // 监听邀请状态机变化
    pageManager.callingMachine?.onStateChanged = (CallingState state) {
      ZegoLoggerService.logInfo(
        'invitation state changed: $state, current overlay state: ${ZegoCallMiniOverlayMachine().state()}',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );

      if (state == CallingState.kOnlineAudioVideo) {
        // 如果从邀请中跳转到通话中，自动转换最小化状态
        final currentState = ZegoCallMiniOverlayMachine().state();
        if (currentState == ZegoCallMiniOverlayPageState.invitingMinimized) {
          ZegoLoggerService.logInfo(
            'invitation accepted, auto convert to calling minimized state',
            tag: 'call-minimize',
            subTag: 'controller.minimize',
          );

          // 自动转换为通话中最小化状态
          _autoConvertToInCallMinimized();
        }
      } else if (state == CallingState.kCallingWithVideo ||
          state == CallingState.kCallingWithVoice) {
        // 当状态变为邀请中时，不要转换悬浮窗口状态
        // 这只是邀请发送成功，不是通话开始
        ZegoLoggerService.logInfo(
          'invitation state changed to calling, but not converting overlay state yet',
          tag: 'call-minimize',
          subTag: 'controller.minimize',
        );
      }
    };

    // 监听邀请事件，处理邀请结束的情况
    _listenInvitationEvents(pageManager);
  }

  /// 监听邀请事件
  void _listenInvitationEvents(ZegoCallInvitationPageManager pageManager) {
    // 监听邀请被拒绝
    pageManager.callInvitationData.invitationEvents
        ?.onIncomingCallDeclineButtonPressed = () {
      ZegoLoggerService.logInfo(
        'invitation declined, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请被取消
    pageManager.callInvitationData.invitationEvents
        ?.onOutgoingCallCancelButtonPressed = () {
      ZegoLoggerService.logInfo(
        'invitation canceled, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请超时
    pageManager.callInvitationData.invitationEvents?.onIncomingCallTimeout =
        (String callID, ZegoCallUser inviter) {
      ZegoLoggerService.logInfo(
        'invitation timeout, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请响应超时
    pageManager.callInvitationData.invitationEvents?.onOutgoingCallTimeout =
        (String callID, List<ZegoCallUser> invitees, bool isVideoCall) {
      ZegoLoggerService.logInfo(
        'invitation response timeout, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请被拒绝（忙碌）
    pageManager.callInvitationData.invitationEvents
            ?.onOutgoingCallRejectedCauseBusy =
        (String callID, ZegoCallUser invitee, String customData) {
      ZegoLoggerService.logInfo(
        'invitation rejected (busy), hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请被拒绝（主动拒绝）
    pageManager.callInvitationData.invitationEvents?.onOutgoingCallDeclined =
        (String callID, ZegoCallUser invitee, String customData) {
      ZegoLoggerService.logInfo(
        'invitation declined, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };

    // 监听邀请被取消（来电方）
    pageManager.callInvitationData.invitationEvents?.onIncomingCallCanceled =
        (String callID, ZegoCallUser caller, String customData) {
      ZegoLoggerService.logInfo(
        'incoming call canceled, hiding overlay',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );
      _hideOverlayIfInvitingMinimized();
    };
  }

  /// 如果当前是邀请中最小化状态，则隐藏悬浮窗口
  void _hideOverlayIfInvitingMinimized() {
    final currentState = ZegoCallMiniOverlayMachine().state();
    if (currentState == ZegoCallMiniOverlayPageState.invitingMinimized) {
      ZegoLoggerService.logInfo(
        'hiding overlay for invitation ended',
        tag: 'call-minimize',
        subTag: 'controller.minimize',
      );

      // 清除最小化数据
      private.clearMinimizeData();

      // 改变状态为空闲
      ZegoCallMiniOverlayMachine()
          .changeState(ZegoCallMiniOverlayPageState.idle);
    }
  }

  /// 自动转换为通话中最小化
  void _autoConvertToInCallMinimized() {
    final minimizeData = private.minimizeData;
    final invitingData = minimizeData?.inviting;

    if (invitingData != null) {
      // 创建通话中最小化数据
      final inCallData = ZegoInCallMinimizeData(
        config: _convertCallingConfigToPrebuiltConfig(
            invitingData.pageManager.callingConfig),
        events: invitingData.callInvitationData.events ??
            ZegoUIKitPrebuiltCallEvents(),
        isPrebuiltFromMinimizing: true,
        plugins: invitingData.callInvitationData.plugins,
        durationStartTime: DateTime.now(),
      );

      // 创建新的最小化数据
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

      // 更新最小化数据
      private.updateMinimizeData(newMinimizeData);

      // 改变状态
      ZegoCallMiniOverlayMachine()
          .changeState(ZegoCallMiniOverlayPageState.inCallMinimized);
    }
  }

  /// 转换邀请配置为通话配置
  ZegoUIKitPrebuiltCallConfig _convertCallingConfigToPrebuiltConfig(
    ZegoUIKitPrebuiltCallingConfig callingConfig,
  ) {
    // 这里需要根据callingConfig创建对应的prebuiltConfig
    // 暂时返回一个默认配置，实际使用时需要根据业务逻辑完善
    return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
  }
}
