part of 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
mixin ZegoCallInvitationServicePrivate {
  final _private = ZegoCallInvitationServicePrivateImpl();

  ZegoCallInvitationServicePrivateImpl get private => _private;
}

/// Here are the APIs related to invitation.
class ZegoCallInvitationServicePrivateImpl
    with
        ZegoCallInvitationServiceCallKitPrivate,
        ZegoCallInvitationServiceIOSCallKitPrivatePrivate {
  bool _isInit = false;

  /// callkit
  bool _enableIOSVoIP = false;

  ReceivePort? _backgroundPort;

  ContextQuery? _contextQuery;

  /// for change innerText before service.init()
  final _defaultInnerText = ZegoCallInvitationInnerText();
  final _defaultRingtoneConfig = ZegoCallRingtoneConfig();
  ZegoUIKitPrebuiltCallInvitationData? _data;

  ZegoCallInvitationPageManager? _pageManager;
  ZegoCallInvitationNotificationManager? _notificationManager;
  ZegoCallPrebuiltPlugins? _plugins;

  Future<void> _initPrivate({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    ZegoCallPrebuiltConfigQuery? requireConfig,
    ZegoCallInvitationConfig? config,
    ZegoCallRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationNotificationConfig? notificationConfig,
    ZegoCallInvitationInnerText? innerText,
    ZegoUIKitPrebuiltCallEvents? events,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
  }) async {
    ZegoLoggerService.logInfo(
      'init private, '
      'appID:$appID, '
      'userID:$userID, '
      'userName:$userName, '
      'plugins:$plugins, '
      'ringtoneConfig:$ringtoneConfig, '
      'config:$config, '
      'uiConfig:$uiConfig, '
      'notificationConfig:$notificationConfig, ',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _registerOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

    /// sync innerText & ringtoneConfig which change before init call
    innerText?.syncFrom(_defaultInnerText);
    ringtoneConfig?.syncFrom(_defaultRingtoneConfig);

    _data = ZegoUIKitPrebuiltCallInvitationData(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      plugins: plugins,
      requireConfig: requireConfig ?? _defaultConfig,
      events: events,
      invitationEvents: invitationEvents,
      innerText: innerText,
      ringtoneConfig: ringtoneConfig,
      config: config,
      uiConfig: uiConfig,
      notificationConfig: notificationConfig,
    );

    if (null != _contextQuery) {
      ZegoLoggerService.logInfo(
        'update contextQuery in call invitation config',
        tag: 'call',
        subTag: 'call invitation service private(${identityHashCode(this)})',
      );

      _data!.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoCallInvitationNotificationManager(
      callInvitationData: _data!,
    );
    await _notificationManager!.init();

    _pageManager = ZegoCallInvitationPageManager(
      callInvitationData: _data!,
    );
    _pageManager!.init(
      ringtoneConfig: _data!.ringtoneConfig,
      notificationManager: _notificationManager!,
    );

    ZegoCallInvitationInternalInstance.instance.register(
      pageManager: _pageManager!,
      callInvitationData: _data!,
    );
  }

  Future<void> _uninitPrivate() async {
    ZegoLoggerService.logInfo(
      'uninit private',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _unregisterOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);

    _notificationManager?.uninit();

    _pageManager?.uninit();

    ZegoCallInvitationInternalInstance.instance.unregister();
  }

  Future<void> _initPlugins({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
  }) async {
    ZegoLoggerService.logInfo(
      'init plugins',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _plugins = ZegoCallPrebuiltPlugins(
      appID: _data!.appID,
      appSign: _data!.appSign,
      userID: _data!.userID,
      userName: _data!.userName,
      plugins: _data!.plugins,
      onError: _data?.invitationEvents?.onError,
    );
    await _plugins!.init(onPluginInit: () async {
      ZegoLoggerService.logInfo(
        'try enable notification, '
        'iOSNotificationConfig:${_data!.notificationConfig.iOSNotificationConfig}, '
        'enableIOSVoIP:$_enableIOSVoIP ',
        tag: 'call',
        subTag: 'call invitation service private(${identityHashCode(this)})',
      );

      final androidChannelID =
          _data!.notificationConfig.androidNotificationConfig?.channelID ??
              defaultCallChannelKey;
      final androidChannelName =
          _data!.notificationConfig.androidNotificationConfig?.channelName ??
              defaultCallChannelName;
      setPreferenceString(
        serializationKeyHandlerInfo,
        HandlerPrivateInfo(
          appID: appID.toString(),
          userID: userID,
          userName: userName,
          isIOSSandboxEnvironment: _data!
              .notificationConfig.iOSNotificationConfig?.isSandboxEnvironment,
          enableIOSVoIP: _enableIOSVoIP,
          certificateIndex: (_data!.notificationConfig.iOSNotificationConfig
                      ?.certificateIndex ??
                  ZegoSignalingPluginMultiCertificate.firstCertificate)
              .id,
          appName:
              _data!.notificationConfig.iOSNotificationConfig?.appName ?? '',
          androidCallChannelID: androidChannelID,
          androidCallChannelName: androidChannelName,
          androidCallSound:
              _data!.notificationConfig.androidNotificationConfig?.sound ?? '',
          androidCallVibrate:
              _data!.notificationConfig.androidNotificationConfig?.vibrate ??
                  true,
          androidMessageChannelID: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannelID ??
              defaultMessageChannelID,
          androidMessageChannelName: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannelName ??
              defaultMessageChannelName,
          androidMessageIcon: _data!
                  .notificationConfig.androidNotificationConfig?.messageIcon ??
              '',
          androidMessageSound: _data!
                  .notificationConfig.androidNotificationConfig?.messageSound ??
              '',
          androidMessageVibrate: _data!.notificationConfig
                  .androidNotificationConfig?.messageVibrate ??
              false,
        ).toJsonString(),
      );

      ZegoSignalingPluginMultiCertificate? certificateIndex;
      if (Platform.isAndroid) {
        certificateIndex = _data!
            .notificationConfig.androidNotificationConfig?.certificateIndex;
      } else if (Platform.isIOS) {
        certificateIndex =
            _data!.notificationConfig.iOSNotificationConfig?.certificateIndex;
      }
      ZegoUIKit()
          .getSignalingPlugin()
          .enableNotifyWhenAppRunningInBackgroundOrQuit(
            true,
            isIOSSandboxEnvironment: _data!
                .notificationConfig.iOSNotificationConfig?.isSandboxEnvironment,
            enableIOSVoIP: _enableIOSVoIP,
            certificateIndex: (certificateIndex ??
                    ZegoSignalingPluginMultiCertificate.firstCertificate)
                .id,
            appName:
                _data!.notificationConfig.iOSNotificationConfig?.appName ?? '',
            androidChannelID: androidChannelID,
            androidChannelName: androidChannelName,
            androidSound: (_data!.notificationConfig.androidNotificationConfig
                        ?.sound?.isEmpty ??
                    true)
                ? ''
                : '/raw/${_data!.notificationConfig.androidNotificationConfig?.sound}',
          )
          .then((result) {
        if (_enableIOSVoIP) {
          ZegoUIKit().getSignalingPlugin().setInitConfiguration(
                ZegoSignalingPluginProviderConfiguration(
                  localizedName: _data!
                          .notificationConfig.iOSNotificationConfig?.appName ??
                      '',
                  iconTemplateImageName: _data!.notificationConfig
                          .iOSNotificationConfig?.systemCallingIconName ??
                      '',
                  supportsVideo: false,
                  maximumCallsPerCallGroup: 1,
                  maximumCallGroups: 1,
                ),
              );
        }

        ZegoLoggerService.logInfo(
          'enable notification result: $result',
          tag: 'call',
          subTag: 'call invitation service private(${identityHashCode(this)})',
        );
      });
    }).then((value) {
      ZegoLoggerService.logInfo(
        'plugin init finished',
        tag: 'call',
        subTag: 'call invitation service private(${identityHashCode(this)})',
      );

      _pageManager?.listenStream();

      if (Platform.isAndroid) {
        getOfflineCallKitCacheParams().then((offlineCallKitCacheParameter) {
          ZegoLoggerService.logInfo(
            'offline callkit params: ${offlineCallKitCacheParameter.dict}',
            tag: 'call',
            subTag:
                'call invitation service private(${identityHashCode(this)})',
          );

          if (offlineCallKitCacheParameter.isEmpty) {
            return;
          }
          ZegoLoggerService.logInfo(
            'exist offline call, accept:${offlineCallKitCacheParameter.accept}',
            tag: 'call',
            subTag:
                'call invitation service private(${identityHashCode(this)})',
          );

          /// exist offline call, wait auto enter room, or popup incoming call dialog
          _pageManager
                  ?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
              offlineCallKitCacheParameter.accept;

          _pageManager?.onInvitationReceived(offlineCallKitCacheParameter.dict);
        });
      }
    });
  }

  Future<void> _uninitPlugins() async {
    ZegoLoggerService.logInfo(
      'uninit plugins',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    await ZegoUIKit().getSignalingPlugin().logout();

    await _plugins?.uninit();
  }

  Future<void> _initPermissions() async {
    ZegoLoggerService.logInfo(
      'init permissions',
      tag: 'call',
      subTag: 'call invitation service',
    );

    if (_data?.config.permissions
            .contains(ZegoCallInvitationPermission.camera) ??
        true) {
      await requestPermission(Permission.camera);
    }
    if (_data?.config.permissions
            .contains(ZegoCallInvitationPermission.microphone) ??
        true) {
      await requestPermission(Permission.microphone);
    }
  }

  Future<void> _initContext() async {
    ZegoLoggerService.logInfo(
      'init context',
      tag: 'call',
      subTag: 'call invitation service',
    );

    ZegoUIKit().login(_data?.userID ?? '', _data?.userName ?? '');
    await ZegoUIKit()
        .init(appID: _data?.appID ?? 0, appSign: _data?.appSign ?? '');

    // enableCustomVideoProcessing
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().enableCustomVideoProcessing(true);
    }

    ZegoUIKit.instance.turnCameraOn(false);
  }

  void _registerOfflineCallIsolateNameServer() {
    // Here we need to clear the status of background isolate and subscription.
    // The problem occurs when an offline call is received, but the user
    // directly clicks the appIcon to open the application. mainIsolate will create the zim,
    // and fcmIsolate will accidentally destroy the zim.
    ZegoLoggerService.logInfo(
      'Cancel The flutterCallkitIncomingStreamSubscription or not:'
      '(${flutterCallkitIncomingStreamSubscription?.hashCode})',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );
    if (flutterCallkitIncomingStreamSubscription != null) {
      flutterCallkitIncomingStreamSubscription?.cancel();
      flutterCallkitIncomingStreamSubscription = null;
    }
    final lookupIsolate =
        IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
    final isMainIsolatePort =
        (_backgroundPort?.sendPort.hashCode == lookupIsolate.hashCode);
    final needClose = !isMainIsolatePort && (lookupIsolate != null);
    ZegoLoggerService.logInfo(
      'Close The lookupIsolate or not, needClose:$needClose, '
      'hash(${lookupIsolate?.hashCode}), isMainIsolatePort:$isMainIsolatePort',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );
    if (needClose) {
      lookupIsolate.send('close');
    }

    // register MainIsolatePort
    _backgroundPort = ReceivePort();

    IsolateNameServer.registerPortWithName(
      _backgroundPort!.sendPort,
      backgroundMessageIsolatePortName,
    );
    ZegoLoggerService.logInfo(
      'isolate: register, _backgroundPort(${_backgroundPort.hashCode}), '
      '_backgroundPort!.sendPort(${_backgroundPort!.sendPort.hashCode})',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );
    _backgroundPort!.listen((dynamic message) async {
      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, message:$message',
        tag: 'call',
        subTag: 'call invitation service private(${identityHashCode(this)})',
      );

      final messageMap = jsonDecode(message) as Map<String, dynamic>;
      final messageTitle = messageMap['title'] as String? ?? '';
      final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, '
        'title:$messageTitle, '
        'extra:$messageExtras',
        tag: 'call',
        subTag: 'call invitation service private(${identityHashCode(this)})',
      );

      // final payload = messageExtras['payload'] as String? ?? '';
      // final payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};
      // var isKitProtocol = payloadMap.containsKey('inviter_name');

      var isKitProtocol = messageExtras.containsKey('zego');
      if (isKitProtocol) {
        /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
        await ZegoCallPluginPlatform.instance.activeAppToForeground();
        await ZegoCallPluginPlatform.instance.requestDismissKeyguard();
      }

      /// There is no need for additional processing.
      /// When the app is suspended after being screen-locked for more than 10
      /// minutes, it will receives offline calls from ZPNS.
      ///
      /// At this time, the offline handler wakes up the app through isolate
      /// and then ZIM been reconnected and receive online call.
      /// After receiving an online call, because the app is in the background,
      /// it will run the logic code of background online calls and then pops
      /// up the CallKit UI.
    });

    ZegoLoggerService.logInfo(
      'isolate: register offline call isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );
  }

  void _unregisterOfflineCallIsolateNameServer() {
    ZegoLoggerService.logInfo(
      'isolate: unregister offline call  isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _backgroundPort?.close();
    IsolateNameServer.removePortNameMapping(backgroundMessageIsolatePortName);
  }

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    if (!_isInit) {
      return;
    }

    final isScreenLockEnabled = await isLockScreen() ?? false;
    var isAppInBackground = appLifecycleState != AppLifecycleState.resumed;
    if (isScreenLockEnabled) {
      isAppInBackground = true;
    }
    ZegoLoggerService.logInfo(
      'AppLifecycleStateChanged, state:$appLifecycleState, '
      'isAppInBackground:$isAppInBackground, '
      'isScreenLockEnabled:$isScreenLockEnabled',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _pageManager?.didChangeAppLifecycleState(isAppInBackground);
    _plugins?.didChangeAppLifecycleState(isAppInBackground);
  }

  ZegoUIKitPrebuiltCallConfig _defaultConfig(ZegoCallInvitationData data) {
    final config = (data.invitees.length > 1)
        ? ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        : ZegoCallType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return config;
  }

  void cancelGroupCallInvitation() {
    ZegoLoggerService.logInfo(
      'cancelGroupCallInvitation',
      tag: 'call',
      subTag: 'call invitation service private(${identityHashCode(this)})',
    );

    _pageManager?.cancelGroupCallInvitation();
  }
}

extension ZegoCallInvitationInnerTextForCallInvitationServicePrivate
    on ZegoCallInvitationInnerText {
  void syncFrom(ZegoCallInvitationInnerText innerText) {
    var defaultValue = ZegoCallInvitationInnerText();

    if (defaultValue.incomingVideoCallDialogTitle !=
        innerText.incomingVideoCallDialogTitle) {
      incomingVideoCallDialogTitle = innerText.incomingVideoCallDialogTitle;
    }
    if (defaultValue.incomingVideoCallDialogMessage !=
        innerText.incomingVideoCallDialogMessage) {
      incomingVideoCallDialogMessage = innerText.incomingVideoCallDialogMessage;
    }
    if (defaultValue.incomingVoiceCallDialogTitle !=
        innerText.incomingVoiceCallDialogTitle) {
      incomingVoiceCallDialogTitle = innerText.incomingVoiceCallDialogTitle;
    }
    if (defaultValue.incomingVoiceCallDialogMessage !=
        innerText.incomingVoiceCallDialogMessage) {
      incomingVoiceCallDialogMessage = innerText.incomingVoiceCallDialogMessage;
    }
    if (defaultValue.incomingVideoCallPageTitle !=
        innerText.incomingVideoCallPageTitle) {
      incomingVideoCallPageTitle = innerText.incomingVideoCallPageTitle;
    }
    if (defaultValue.incomingVideoCallPageMessage !=
        innerText.incomingVideoCallPageMessage) {
      incomingVideoCallPageMessage = innerText.incomingVideoCallPageMessage;
    }
    if (defaultValue.incomingVoiceCallPageTitle !=
        innerText.incomingVoiceCallPageTitle) {
      incomingVoiceCallPageTitle = innerText.incomingVoiceCallPageTitle;
    }
    if (defaultValue.incomingVoiceCallPageMessage !=
        innerText.incomingVoiceCallPageMessage) {
      incomingVoiceCallPageMessage = innerText.incomingVoiceCallPageMessage;
    }
    if (defaultValue.outgoingVideoCallPageTitle !=
        innerText.outgoingVideoCallPageTitle) {
      outgoingVideoCallPageTitle = innerText.outgoingVideoCallPageTitle;
    }
    if (defaultValue.outgoingVideoCallPageMessage !=
        innerText.outgoingVideoCallPageMessage) {
      outgoingVideoCallPageMessage = innerText.outgoingVideoCallPageMessage;
    }
    if (defaultValue.outgoingVoiceCallPageTitle !=
        innerText.outgoingVoiceCallPageTitle) {
      outgoingVoiceCallPageTitle = innerText.outgoingVoiceCallPageTitle;
    }
    if (defaultValue.outgoingVoiceCallPageMessage !=
        innerText.outgoingVoiceCallPageMessage) {
      outgoingVoiceCallPageMessage = innerText.outgoingVoiceCallPageMessage;
    }
    if (defaultValue.incomingGroupVideoCallDialogTitle !=
        innerText.incomingGroupVideoCallDialogTitle) {
      incomingGroupVideoCallDialogTitle =
          innerText.incomingGroupVideoCallDialogTitle;
    }
    if (defaultValue.incomingGroupVideoCallDialogMessage !=
        innerText.incomingGroupVideoCallDialogMessage) {
      incomingGroupVideoCallDialogMessage =
          innerText.incomingGroupVideoCallDialogMessage;
    }
    if (defaultValue.incomingGroupVoiceCallDialogTitle !=
        innerText.incomingGroupVoiceCallDialogTitle) {
      incomingGroupVoiceCallDialogTitle =
          innerText.incomingGroupVoiceCallDialogTitle;
    }
    if (defaultValue.incomingGroupVoiceCallDialogMessage !=
        innerText.incomingGroupVoiceCallDialogMessage) {
      incomingGroupVoiceCallDialogMessage =
          innerText.incomingGroupVoiceCallDialogMessage;
    }
    if (defaultValue.incomingGroupVideoCallPageTitle !=
        innerText.incomingGroupVideoCallPageTitle) {
      incomingGroupVideoCallPageTitle =
          innerText.incomingGroupVideoCallPageTitle;
    }
    if (defaultValue.incomingGroupVideoCallPageMessage !=
        innerText.incomingGroupVideoCallPageMessage) {
      incomingGroupVideoCallPageMessage =
          innerText.incomingGroupVideoCallPageMessage;
    }
    if (defaultValue.incomingGroupVoiceCallPageTitle !=
        innerText.incomingGroupVoiceCallPageTitle) {
      incomingGroupVoiceCallPageTitle =
          innerText.incomingGroupVoiceCallPageTitle;
    }
    if (defaultValue.incomingGroupVoiceCallPageMessage !=
        innerText.incomingGroupVoiceCallPageMessage) {
      incomingGroupVoiceCallPageMessage =
          innerText.incomingGroupVoiceCallPageMessage;
    }
    if (defaultValue.outgoingGroupVideoCallPageTitle !=
        innerText.outgoingGroupVideoCallPageTitle) {
      outgoingGroupVideoCallPageTitle =
          innerText.outgoingGroupVideoCallPageTitle;
    }
    if (defaultValue.outgoingGroupVideoCallPageMessage !=
        innerText.outgoingGroupVideoCallPageMessage) {
      outgoingGroupVideoCallPageMessage =
          innerText.outgoingGroupVideoCallPageMessage;
    }
    if (defaultValue.outgoingGroupVoiceCallPageTitle !=
        innerText.outgoingGroupVoiceCallPageTitle) {
      outgoingGroupVoiceCallPageTitle =
          innerText.outgoingGroupVoiceCallPageTitle;
    }
    if (defaultValue.outgoingGroupVoiceCallPageMessage !=
        innerText.outgoingGroupVoiceCallPageMessage) {
      outgoingGroupVoiceCallPageMessage =
          innerText.outgoingGroupVoiceCallPageMessage;
    }
    if (defaultValue.incomingCallPageDeclineButton !=
        innerText.incomingCallPageDeclineButton) {
      incomingCallPageDeclineButton = innerText.incomingCallPageDeclineButton;
    }
    if (defaultValue.incomingCallPageAcceptButton !=
        innerText.incomingCallPageAcceptButton) {
      incomingCallPageAcceptButton = innerText.incomingCallPageAcceptButton;
    }
  }
}

extension ZegoCallRingtoneConfigForCallInvitationServicePrivate
    on ZegoCallRingtoneConfig {
  void syncFrom(ZegoCallRingtoneConfig config) {
    var defaultValue = ZegoCallRingtoneConfig();

    if (defaultValue.incomingCallPath != config.incomingCallPath) {
      incomingCallPath = config.incomingCallPath;
    }
    if (defaultValue.outgoingCallPath != config.outgoingCallPath) {
      outgoingCallPath = config.outgoingCallPath;
    }
  }
}
