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
  set inCallPage(bool value) => _pageManager?.inCallPage = value;

  bool get isHidingInvitationTopSheetDuringSheetEmptyClicked =>
      _pageManager?.isHidingInvitationTopSheetDuringSheetEmptyClicked ?? false;

  List<IZegoUIKitPlugin> get plugins => _data?.plugins ?? [];

  bool isCurrentInvitationFromAcceptedAndroidOffline({
    bool selfDestructing = true,
  }) {
    final result =
        _pageManager?.isCurrentInvitationFromAcceptedAndroidOffline ?? false;

    if (selfDestructing) {
      ZegoLoggerService.logInfo(
        'reset _pageManager.isCurrentInvitationFromAcceptedAndroidOffline',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)})',
      );
      _pageManager?.isCurrentInvitationFromAcceptedAndroidOffline = false;
    }

    return result;
  }

  bool _isInit = false;
  bool waitingEnterAcceptedOfflineCallWhenInitNotDone = false;

  ZegoCallInvitationServiceAPIImpl? invitationImpl;

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

  final localInvitingUsersNotifier = ValueNotifier<List<ZegoCallUser>>([]);
  void removeUserFromLocalInvitingUsers(List<String> userIDList) {
    final oldValue = List<ZegoCallUser>.from(localInvitingUsersNotifier.value);
    for (var userID in userIDList) {
      oldValue.removeWhere((user) => user.id == userID);
    }
    updateLocalInvitingUsers(oldValue);
  }

  void updateLocalInvitingUsers(List<ZegoCallUser> users) {
    ZegoLoggerService.logInfo(
      'updateLocalInvitingUsers:$users',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    localInvitingUsersNotifier.value = users;
  }

  ZegoCallInvitationData get currentCallInvitationDataSafe =>
      _pageManager?.invitationData ?? ZegoCallInvitationData.empty();

  ZegoCallInvitationData? get currentCallInvitationData =>
      _pageManager?.invitationData;

  ZegoCallInvitationLocalParameter get localInvitationParameter =>
      _pageManager?.localInvitationParameter ??
      ZegoCallInvitationLocalParameter.empty();

  void updateInvitationData(
    ZegoCallInvitationSendRequestProtocol sendRequestProtocol,
    String invitationID,
    ZegoUIKitUser inviter,
    ZegoCallInvitationType type,
  ) {
    ZegoLoggerService.logInfo(
      'updateInvitationData, '
      'page manager is null:${null == _pageManager}',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    _pageManager?.updateInvitationData(
      sendRequestProtocol,
      invitationID,
      inviter,
      type,
    );
  }

  bool get isAdvanceInvitationMode =>
      (callInvitationConfig?.inCalling.canInvitingInCalling ?? false) ||
      (callInvitationConfig?.missedCall.enableDialBack ?? false);

  ZegoCallInvitationConfig? get callInvitationConfig => _data?.config;

  ZegoCallInvitationInnerText get innerText =>
      _data?.innerText ?? _defaultInnerText;

  ZegoCallRingtoneConfig get ringtoneConfig =>
      _data?.ringtoneConfig ?? _defaultRingtoneConfig;

  /// Invitation-related event notifications and callbacks.
  ZegoUIKitPrebuiltCallInvitationEvents? get events => _data?.invitationEvents;

  ZegoCallAndroidNotificationConfig? get androidNotificationConfig =>
      _data?.notificationConfig.androidNotificationConfig;

  Future<void> _initPrivate({
    required int appID,
    required String appSign,
    required String token,
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
    ZegoCallInvitationServiceAPIImpl? invitationImpl,
  }) async {
    ZegoLoggerService.logInfo(
      'init private, ',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    localInvitingUsersNotifier.addListener(onLocalInvitingUsersUpdated);

    _registerOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .registerMessageHandler(_onAppLifecycleStateChanged);

    /// sync innerText & ringtoneConfig which change before init call
    innerText?.syncFrom(_defaultInnerText);
    ringtoneConfig?.syncFrom(_defaultRingtoneConfig);

    this.invitationImpl = invitationImpl;

    if (null != _contextQuery) {
      ZegoLoggerService.logInfo(
        'update contextQuery in call invitation config',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)})',
      );

      _data!.contextQuery = _contextQuery;
    }

    _notificationManager = ZegoCallInvitationNotificationManager(
      callInvitationData: _data!,
    );
    try {
      await _notificationManager!.init(_data?.contextQuery?.call());
    } catch (e) {
      ZegoLoggerService.logInfo(
        'notificationManager init exception:$e',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)})',
      );
    }

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
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    localInvitingUsersNotifier.removeListener(onLocalInvitingUsersUpdated);
    _unregisterOfflineCallIsolateNameServer();

    ZegoUIKit()
        .adapterService()
        .unregisterMessageHandler(_onAppLifecycleStateChanged);

    invitationImpl = null;

    _notificationManager?.uninit();

    _pageManager?.uninit();

    ZegoCallInvitationInternalInstance.instance.unregister();
  }

  Future<void> _initPlugins({
    required int appID,
    required String appSign,
    required String token,
    required String userID,
    required String userName,
  }) async {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), init plugins',
    );

    _plugins = ZegoCallPrebuiltPlugins(
      appID: _data!.appID,
      appSign: _data!.appSign,
      token: _data!.token,
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
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)}), init plugins',
      );

      var certificateIndex =
          ZegoSignalingPluginMultiCertificate.firstCertificate;
      if (Platform.isAndroid) {
        certificateIndex = _data!.notificationConfig.androidNotificationConfig
                ?.certificateIndex ??
            ZegoSignalingPluginMultiCertificate.firstCertificate;
      } else if (Platform.isIOS) {
        certificateIndex =
            _data!.notificationConfig.iOSNotificationConfig?.certificateIndex ??
                ZegoSignalingPluginMultiCertificate.firstCertificate;
      }

      final androidChannelID = _data!.notificationConfig
              .androidNotificationConfig?.callChannel.channelID ??
          defaultCallChannelKey;
      final androidChannelName = _data!.notificationConfig
              .androidNotificationConfig?.callChannel.channelName ??
          defaultCallChannelName;
      setPreferenceString(
        serializationKeyHandlerInfo,
        HandlerPrivateInfo(
          appID: appID.toString(),
          token: token,
          userID: userID,
          userName: userName,
          canInvitingInCalling:
              _data?.config.inCalling.canInvitingInCalling ?? true,
          isIOSSandboxEnvironment: _data!
              .notificationConfig.iOSNotificationConfig?.isSandboxEnvironment,
          enableIOSVoIP: _enableIOSVoIP,
          certificateIndex: certificateIndex.id,
          appName:
              _data!.notificationConfig.iOSNotificationConfig?.appName ?? '',
          androidCallChannelID: androidChannelID,
          androidCallChannelName: androidChannelName,
          androidCallSound: _data!.notificationConfig.androidNotificationConfig
                  ?.callChannel.sound ??
              '',
          androidCallVibrate: _data!.notificationConfig
                  .androidNotificationConfig?.callChannel.vibrate ??
              true,
          androidMessageChannelID: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannel.channelID ??
              defaultMessageChannelID,
          androidMessageChannelName: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannel.channelName ??
              defaultMessageChannelName,
          androidMessageIcon: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannel.icon ??
              '',
          androidMessageSound: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannel.sound ??
              '',
          androidMessageVibrate: _data!.notificationConfig
                  .androidNotificationConfig?.messageChannel.vibrate ??
              false,
          androidMissedCallEnabled: _data!.config.missedCall.enabled,
          androidMissedCallChannelID: _data!.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.channelID ??
              defaultMissedCallChannelKey,
          androidMissedCallChannelName: _data!.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.channelName ??
              defaultMissedCallChannelName,
          androidMissedCallIcon: _data!.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.icon ??
              '',
          androidMissedCallSound: _data!.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.sound ??
              '',
          androidMissedCallVibrate: _data!.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.vibrate ??
              false,
          missedCallNotificationTitle: ZegoUIKitPrebuiltCallInvitationService()
              .private
              .innerText
              .missedCallNotificationTitle,
          missedGroupVideoCallNotificationContent:
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .innerText
                  .missedGroupVideoCallNotificationContent,
          missedGroupAudioCallNotificationContent:
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .innerText
                  .missedGroupAudioCallNotificationContent,
          missedVideoCallNotificationContent:
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .innerText
                  .missedVideoCallNotificationContent,
          missedAudioCallNotificationContent:
              ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .innerText
                  .missedAudioCallNotificationContent,
        ).toJsonString(),
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .enableNotifyWhenAppRunningInBackgroundOrQuit(
            true,
            isIOSSandboxEnvironment: _data!
                .notificationConfig.iOSNotificationConfig?.isSandboxEnvironment,
            enableIOSVoIP: _enableIOSVoIP,
            certificateIndex: certificateIndex.id,
            appName:
                _data!.notificationConfig.iOSNotificationConfig?.appName ?? '',
            androidChannelID: androidChannelID,
            androidChannelName: androidChannelName,
            androidSound: (_data!.notificationConfig.androidNotificationConfig
                        ?.callChannel.sound?.isEmpty ??
                    true)
                ? ''
                : '/raw/${_data!.notificationConfig.androidNotificationConfig?.callChannel.sound}',
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
          tag: 'call-invitation',
          subTag: 'service private(${identityHashCode(this)}), init plugins',
        );
      });
    }).then((value) {
      ZegoLoggerService.logInfo(
        'plugin init finished',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)}), init plugins',
      );

      _pageManager?.listenStream();

      if (Platform.isAndroid) {
        ZegoUIKitCallCache()
            .offlineCallKit
            .getCacheParams()
            .then((offlineCallKitCacheParameter) {
          ZegoLoggerService.logInfo(
            'offline callkit params: ${offlineCallKitCacheParameter.dict}',
            tag: 'call-invitation',
            subTag: 'service private(${identityHashCode(this)}), init plugins',
          );

          ZegoUIKitCallCache().offlineCallKit.clearCacheParams();

          if (offlineCallKitCacheParameter.isEmpty) {
            return;
          }

          ZegoLoggerService.logInfo(
            'exist offline call, '
            'room id:${ZegoUIKit().getRoom().id}, ',
            tag: 'call-invitation',
            subTag: 'service private(${identityHashCode(this)}), init plugins',
          );

          if (offlineCallKitCacheParameter.accept) {
            _pageManager?.onAndroidOfflineInvitationAccepted(
              offlineCallKitCacheParameter,
            );
          }
        });
      }
    });
  }

  Future<void> _uninitPlugins() async {
    ZegoLoggerService.logInfo(
      'uninit plugins',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), uninit plugins',
    );

    await ZegoUIKit().getSignalingPlugin().logout();

    await _plugins?.uninit();
  }

  void _initData({
    required int appID,
    required String appSign,
    required String token,
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
  }) {
    ZegoLoggerService.logInfo(
      'init data, ',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    _data = ZegoUIKitPrebuiltCallInvitationData(
      appID: appID,
      appSign: appSign,
      token: token,
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
  }

  Future<void> _initPermissions() async {
    ZegoLoggerService.logInfo(
      'init permissions',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    if (_data?.config.permissions.isEmpty ?? true) {
      ZegoLoggerService.logInfo(
        'skip permissions check due to empty permissions list',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)})',
      );
      return;
    }

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

  Future<void> _initContext({
    ZegoCallInvitationConfig? config,
  }) async {
    ZegoLoggerService.logInfo(
      'init context',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    ZegoUIKit().login(_data?.userID ?? '', _data?.userName ?? '');

    bool playingStreamInPIPUnderIOS = false;
    if (Platform.isIOS) {
      playingStreamInPIPUnderIOS = config?.pip.iOS.support ?? true;

      if (playingStreamInPIPUnderIOS) {
        final systemVersion = ZegoUIKit().getMobileSystemVersion();
        if (systemVersion.major < 15) {
          ZegoLoggerService.logInfo(
            'not support pip smaller than 15',
            tag: 'call-invitation',
            subTag: 'service private(${identityHashCode(this)})',
          );

          playingStreamInPIPUnderIOS = false;
        }
      }
    }
    await ZegoUIKit().init(
      appID: _data?.appID ?? 0,
      appSign: _data?.appSign ?? '',
      enablePlatformView: playingStreamInPIPUnderIOS,
      playingStreamInPIPUnderIOS: playingStreamInPIPUnderIOS,
      token: _data?.token ?? '',
    );

    await ZegoUIKit().enableCustomVideoRender(playingStreamInPIPUnderIOS);

    ZegoUIKit().enableCustomVideoProcessing(false);

    ZegoUIKit.instance.turnCameraOn(false);
  }

  void _registerOfflineCallIsolateNameServer() {
    if (flutterCallkitIncomingStreamSubscription != null) {
      /// Here we need to clear the status of background isolate and subscription.
      /// The problem occurs when an offline call is received, but the user
      /// directly clicks the appIcon to open the application. mainIsolate will create the zim,
      /// and fcmIsolate will accidentally destroy the zim.
      ZegoLoggerService.logInfo(
        'cancel The flutterCallkitIncomingStreamSubscription or not:'
        '(${flutterCallkitIncomingStreamSubscription?.hashCode})',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)}), isolate',
      );

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
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), isolate',
    );
    if (needClose) {
      lookupIsolate.send(backgroundMessageIsolateCloseCommand);
    }

    // register MainIsolatePort
    _backgroundPort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _backgroundPort!.sendPort,
      backgroundMessageIsolatePortName,
    );
    ZegoLoggerService.logInfo(
      'register, _backgroundPort(${_backgroundPort.hashCode}), '
      '_backgroundPort!.sendPort(${_backgroundPort!.sendPort.hashCode})',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), isolate',
    );

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(ZegoCallIsolateNameServerGuard(
      backgroundPort: _backgroundPort!,
      portName: backgroundMessageIsolatePortName,
    ));

    _backgroundPort!.listen((dynamic message) async {
      ZegoLoggerService.logInfo(
        'current port(${_backgroundPort!.hashCode}) receive, message:$message',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)}), isolate',
      );

      final messageMap = jsonDecode(message) as Map<String, dynamic>;
      final messageTitle = messageMap['title'] as String? ?? '';
      final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

      ZegoLoggerService.logInfo(
        'current port(${_backgroundPort!.hashCode}) receive, '
        'title:$messageTitle, '
        'extra:$messageExtras',
        tag: 'call-invitation',
        subTag: 'service private(${identityHashCode(this)}), isolate',
      );

      // final payload = messageExtras['payload'] as String? ?? '';
      // final payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};
      // var isKitProtocol = payloadMap.containsKey('inviter_name');

      var isKitProtocol = messageExtras.containsKey('zego');
      if (isKitProtocol) {
        /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
        await ZegoUIKit().activeAppToForeground();
        await ZegoUIKit().requestDismissKeyguard();
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
      'register offline call isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), isolate',
    );
  }

  void _unregisterOfflineCallIsolateNameServer() {
    ZegoLoggerService.logInfo(
      'unregister offline call isolate name server, port:${_backgroundPort?.hashCode}',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)}), isolate',
    );

    _backgroundPort?.close();
    IsolateNameServer.removePortNameMapping(backgroundMessageIsolatePortName);
  }

  void onLocalInvitingUsersUpdated() {
    ZegoLoggerService.logInfo(
      'onLocalInvitingUsersUpdated, users:${localInvitingUsersNotifier.value}, ',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );
  }

  /// sync app background state
  void _onAppLifecycleStateChanged(AppLifecycleState appLifecycleState) async {
    if (!_isInit) {
      return;
    }

    final isScreenLockEnabled = await ZegoUIKit().isLockScreen();
    var isAppInBackground = appLifecycleState != AppLifecycleState.resumed;
    if (isScreenLockEnabled) {
      isAppInBackground = true;
    }
    ZegoLoggerService.logInfo(
      'AppLifecycleStateChanged, state:$appLifecycleState, '
      'isAppInBackground:$isAppInBackground, '
      'isScreenLockEnabled:$isScreenLockEnabled',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    _pageManager?.didChangeAppLifecycleState(isAppInBackground);
    _plugins?.didChangeAppLifecycleState(isAppInBackground);
  }

  ZegoUIKitPrebuiltCallConfig _defaultConfig(ZegoCallInvitationData data) {
    final config = (data.invitees.length > 1)
        ? ZegoCallInvitationType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
            : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        : ZegoCallInvitationType.videoCall == data.type
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return config;
  }

  Future<void> clearInvitation() async {
    ZegoUIKitPrebuiltCallInvitationService().private.updateLocalInvitingUsers(
      [],
    );

    final invitationData =
        _pageManager?.invitationData ?? ZegoCallInvitationData.empty();
    final invitingInvitees = _pageManager?.invitingInvitees ?? [];
    final callInvitationData = _pageManager?.callInvitationData;
    final localInvitationParameter = _pageManager?.localInvitationParameter;

    ZegoLoggerService.logInfo(
      'clear advance invitation, ',
      tag: 'call-invitation',
      subTag: 'service private(${identityHashCode(this)})',
    );

    await cancelGroupCallInvitation(
      invitationData: invitationData,
      invitingInvitees: invitingInvitees,
    );

    await endQuitAdvanceInvitation(
      invitationData: invitationData,
      invitingInvitees: invitingInvitees,
      callInvitationData: callInvitationData,
      localInvitationParameter: localInvitationParameter,
    );

    _pageManager?.restoreToIdle(
      needPop: false,
      needClearCallKit: false,
    );
  }

  Future<void> cancelGroupCallInvitation({
    required ZegoCallInvitationData invitationData,
    required List<ZegoUIKitUser> invitingInvitees,
  }) async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) == null) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag:
            'service private(${identityHashCode(this)}), cancel group call invitation',
      );

      return;
    }

    /// because group call invitation enter call directly,
    /// so need cancel if end call

    ZegoLoggerService.logInfo(
      'invitationData:$invitationData, '
      'invitingInvitees:$invitingInvitees, ',
      tag: 'call-invitation',
      subTag:
          'service private(${identityHashCode(this)}), cancel group call invitation',
    );

    if (_pageManager?.isNobodyAccepted ?? false) {
      if (_pageManager?.isAdvanceInvitationMode ?? true) {
        await ZegoUIKit()
            .getSignalingPlugin()
            .cancelAdvanceInvitation(
              invitees: invitingInvitees.map((user) => user.id).toList(),
              invitationID: invitationData.invitationID,
              data: ZegoCallInvitationCancelRequestProtocol(
                callID: invitationData.callID,
              ).toJson(),
            )
            .then((result) {
          ZegoLoggerService.logInfo(
            'cancel result, $result',
            tag: 'call-invitation',
            subTag:
                'service private(${identityHashCode(this)}), cancel group call invitation',
          );
        });
      } else {
        await ZegoUIKit()
            .getSignalingPlugin()
            .cancelInvitation(
              invitees: invitingInvitees.map((user) => user.id).toList(),
              data: ZegoCallInvitationCancelRequestProtocol(
                callID: invitationData.callID,
              ).toJson(),
            )
            .then((result) {
          ZegoLoggerService.logInfo(
            'cancel result, $result',
            tag: 'call-invitation',
            subTag:
                'service private(${identityHashCode(this)}), cancel group call invitation',
          );
        });
      }
    } else {
      ZegoLoggerService.logInfo(
        'have already some one accept, not need to cancel',
        tag: 'call-invitation',
        subTag:
            'service private(${identityHashCode(this)}), cancel group call invitation',
      );
    }
  }

  Future<void> endQuitAdvanceInvitation({
    required ZegoCallInvitationData invitationData,
    required List<ZegoUIKitUser> invitingInvitees,
    required ZegoUIKitPrebuiltCallInvitationData? callInvitationData,
    required ZegoCallInvitationLocalParameter? localInvitationParameter,
  }) async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) == null) {
      ZegoLoggerService.logInfo(
        'signaling plugin is null',
        tag: 'call-invitation',
        subTag:
            'service private(${identityHashCode(this)}), end/quit advance invitation,',
      );

      return;
    }

    if (!(_pageManager?.isAdvanceInvitationMode ?? true)) {
      ZegoLoggerService.logInfo(
        'is not advance mode',
        tag: 'call-invitation',
        subTag:
            'service private(${identityHashCode(this)}), end/quit advance invitation,',
      );

      return;
    }

    final callInitiatorUserID = ZegoUIKit()
        .getSignalingPlugin()
        .getAdvanceInitiator(invitationData.invitationID)
        ?.userID;

    ZegoLoggerService.logInfo(
      'callInitiatorUserID:$callInitiatorUserID, '
      'invitationData:$invitationData, '
      'invitingInvitees:$invitingInvitees, '
      'callInvitationData:$callInvitationData, '
      'localInvitationParameter:$localInvitationParameter, '
      'local user id:${ZegoUIKit().getLocalUser().id}, '
      'endCallWhenInitiatorLeave:${_data?.config.endCallWhenInitiatorLeave}, ',
      tag: 'call-invitation',
      subTag:
          'service private(${identityHashCode(this)}), end/quit advance invitation,',
    );

    if (callInitiatorUserID?.isNotEmpty ?? false) {
      final isVideoCall =
          invitationData.type == ZegoCallInvitationType.videoCall;
      final pushConfig = ZegoNotificationConfig(
        resourceID: localInvitationParameter?.resourceID ?? '',
        title: getNotificationTitle(
          defaultTitle: localInvitationParameter?.notificationTitle,
          callees: invitingInvitees
              .map((e) => ZegoCallUser(
                    e.id,
                    e.name,
                  ))
              .toList(),
          isVideoCall: isVideoCall,
          innerText: callInvitationData?.innerText,
        ),
        message: getNotificationMessage(
          defaultMessage: localInvitationParameter?.notificationMessage,
          callees: invitingInvitees
              .map((e) => ZegoCallUser(
                    e.id,
                    e.name,
                  ))
              .toList(),
          isVideoCall: isVideoCall,
          innerText: callInvitationData?.innerText,
        ),
        voIPConfig: ZegoNotificationVoIPConfig(
          iOSVoIPHasVideo: isVideoCall,
        ),
      );

      if (ZegoUIKit().getLocalUser().id == callInitiatorUserID) {
        if (_data?.config.endCallWhenInitiatorLeave ?? true) {
          await ZegoUIKit().getSignalingPlugin().endAdvanceInvitation(
                invitationID: invitationData.invitationID,
                data: '',
                zegoNotificationConfig: pushConfig,
              );
        } else {
          await ZegoUIKit().getSignalingPlugin().quitAdvanceInvitation(
                data: '',
                invitationID: invitationData.invitationID,
                zegoNotificationConfig: pushConfig,
              );
        }
      } else {
        await ZegoUIKit().getSignalingPlugin().quitAdvanceInvitation(
              data: '',
              invitationID: invitationData.invitationID,
              zegoNotificationConfig: pushConfig,
            );
      }
    }
  }

  Future<void> requestPermissionsNeedManuallyByUser() async {
    if (!Platform.isAndroid) {
      return;
    }

    if (!_isInit) {
      ZegoLoggerService.logInfo(
        'service not init',
        tag: 'call-invitation',
        subTag:
            'service(${identityHashCode(this)}), requestPermissionsNeedManuallyByUser',
      );

      return;
    }

    const prefsKey = 'manual_permission_dialog_shown';

    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(prefsKey) ?? false;

    if (hasShown) {
      return;
    }

    await PackageInfo.fromPlatform().then((info) async {
      await showSystemConfirmationDialog(
        _data?.contextQuery?.call(),
        dialogConfig: _data!.config.systemWindowConfirmDialog!,
        dialogInfo: ZegoCallSystemConfirmDialogInfo(
          title: _data!.innerText.permissionManuallyConfirmDialogTitle,
          message: _data!.innerText.permissionManuallyConfirmDialogSubTitle,
          cancelButtonName:
              _data!.innerText.permissionConfirmDialogCancelButton,
          confirmButtonName: _data!.innerText.permissionConfirmDialogOKButton,
        ),
      ).then((isAllow) async {
        await prefs.setBool(prefsKey, true);

        if (!isAllow) {
          ZegoLoggerService.logInfo(
            'requestPermission of systemAlertWindow, not allow',
            tag: 'call-invitation',
            subTag: 'service(${identityHashCode(this)})',
          );

          return;
        }

        await ZegoUIKit().openAppSettings();
      });
    });
  }

  Future<bool> requestSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    if (!_isInit) {
      ZegoLoggerService.logInfo(
        'service not init',
        tag: 'call-invitation',
        subTag:
            'service(${identityHashCode(this)}), requestSystemAlertWindowPermission',
      );

      return false;
    }

    PermissionStatus status = await Permission.systemAlertWindow.status;
    if (status == PermissionStatus.granted) {
      return true;
    }

    if (null == _data?.config.systemWindowConfirmDialog) {
      return await requestSystemAlertWindowPermissionImpl();
    } else {
      return await PackageInfo.fromPlatform().then((info) async {
        return await showSystemConfirmationDialog(
          _data?.contextQuery?.call(),
          dialogConfig: _data!.config.systemWindowConfirmDialog!,
          dialogInfo: ZegoCallSystemConfirmDialogInfo(
            title:
                '${_data!.innerText.permissionConfirmDialogTitle.replaceFirst(param_1, info.packageName.isEmpty ? 'App' : info.appName)} ${_data!.innerText.systemAlertWindowConfirmDialogSubTitle}',
            cancelButtonName:
                _data!.innerText.permissionConfirmDialogDenyButton,
            confirmButtonName:
                _data!.innerText.permissionConfirmDialogAllowButton,
          ),
        ).then((isAllow) async {
          if (!isAllow) {
            ZegoLoggerService.logInfo(
              'requestPermission of systemAlertWindow, not allow',
              tag: 'call-invitation',
              subTag: 'service(${identityHashCode(this)})',
            );

            return false;
          }
          return await requestSystemAlertWindowPermissionImpl();
        });
      });
    }
  }

  Future<bool> requestSystemAlertWindowPermissionImpl() async {
    /// for bring app to foreground from background in Android 10
    return await requestPermission(Permission.systemAlertWindow)
        .then((bool hasPermission) {
      ZegoLoggerService.logInfo(
        'request system alert window permission result:$hasPermission',
        tag: 'call-invitation',
        subTag: 'service(${identityHashCode(this)})',
      );

      return hasPermission;
    });
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
