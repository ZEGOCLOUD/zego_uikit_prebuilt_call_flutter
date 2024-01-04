part of '../service.dart';

/// @nodoc
mixin CallInvitationServicePrivate {
  bool _isInit = false;

  /// callkit
  bool _enableIOSVoIP = false;

  ReceivePort? _backgroundPort;

  ContextQuery? _contextQuery;
  ZegoUIKitPrebuiltCallInvitationData? _data;
  ZegoInvitationPageManager? _pageManager;
  ZegoNotificationManager? _notificationManager;
  ZegoPrebuiltPlugins? _plugins;

  Future<void> _initPrivate({
    required int appID,
    required String appSign,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    PrebuiltConfigQuery? requireConfig,
    ZegoRingtoneConfig? ringtoneConfig,
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
      'uiConfig:$uiConfig, '
      'notificationConfig:$notificationConfig, ',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    _registerOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

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
      uiConfig: uiConfig,
      notificationConfig: notificationConfig,
    );

    if (null != _contextQuery) {
      ZegoLoggerService.logInfo(
        'update contextQuery in call invitation config',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      _data!.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoNotificationManager(
      showDeclineButton: _data!.uiConfig.showDeclineButton,
      callInvitationData: _data!,
    );
    await _notificationManager!.init();

    _pageManager = ZegoInvitationPageManager(
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
      subTag: 'call invitation service(${identityHashCode(this)})',
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
      subTag: 'call invitation service(${identityHashCode(this)})',
    );

    _plugins = ZegoPrebuiltPlugins(
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
        subTag: 'call invitation service(${identityHashCode(this)})',
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

      ZegoUIKit()
          .getSignalingPlugin()
          .enableNotifyWhenAppRunningInBackgroundOrQuit(
            true,
            isIOSSandboxEnvironment: _data!
                .notificationConfig.iOSNotificationConfig?.isSandboxEnvironment,
            enableIOSVoIP: _enableIOSVoIP,
            certificateIndex: (_data!.notificationConfig.iOSNotificationConfig
                        ?.certificateIndex ??
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
          subTag: 'call invitation service(${identityHashCode(this)})',
        );
      });
    }).then((value) {
      ZegoLoggerService.logInfo(
        'plugin init finished',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      _pageManager?.listenStream();

      if (Platform.isAndroid) {
        getCurrentCallKitParams().then((paramsJson) {
          ZegoLoggerService.logInfo(
            'offline callkit param: $paramsJson',
            tag: 'call',
            subTag: 'call invitation service(${identityHashCode(this)})',
          );

          if (paramsJson?.isEmpty ?? true) {
            return;
          }

          ZegoLoggerService.logInfo(
            'exist offline call accept',
            tag: 'call',
            subTag: 'call invitation service(${identityHashCode(this)})',
          );

          /// exist accepted offline call, wait auto enter room
          _pageManager
                  ?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
              true;

          _pageManager?.onInvitationReceived(jsonDecode(paramsJson!));
        });
      }
    });
  }

  Future<void> _uninitPlugins() async {
    ZegoLoggerService.logInfo(
      'uninit plugins',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
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

    await requestPermission(Permission.camera);
    await requestPermission(Permission.microphone);
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
    _backgroundPort = ReceivePort();

    IsolateNameServer.registerPortWithName(
      _backgroundPort!.sendPort,
      backgroundMessageIsolatePortName,
    );

    _backgroundPort!.listen((dynamic message) async {
      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, message:$message',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      final messageMap = jsonDecode(message) as Map<String, dynamic>;
      final messageTitle = messageMap['title'] as String? ?? '';
      final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

      ZegoLoggerService.logInfo(
        'isolate: current port(${_backgroundPort!.hashCode}) receive, '
        'title:$messageTitle, '
        'extra:$messageExtras',
        tag: 'call',
        subTag: 'call invitation service(${identityHashCode(this)})',
      );

      /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
      await ZegoCallPluginPlatform.instance.activeAppToForeground();
      await ZegoCallPluginPlatform.instance.requestDismissKeyguard();

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
      subTag: 'call invitation service(${identityHashCode(this)})',
    );
  }

  void _unregisterOfflineCallIsolateNameServer() {
    ZegoLoggerService.logInfo(
      'isolate: unregister offline call  isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call',
      subTag: 'call invitation service(${identityHashCode(this)})',
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
      subTag: 'call invitation service(${identityHashCode(this)})',
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
}
