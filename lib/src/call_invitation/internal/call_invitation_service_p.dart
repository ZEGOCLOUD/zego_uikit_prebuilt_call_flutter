part of '../call_invitation_service.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltCallInvitationServicePrivate {
  bool _isInit = false;
  ContextQuery? _contextQuery;
  late ZegoUIKitPrebuiltCallInvitationServiceData _data;
  late ZegoInvitationPageManager _pageManager;
  late ZegoNotificationManager _notificationManager;
  late ZegoCallInvitationConfig _callInvitationConfig;
  late ZegoPrebuiltPlugins _plugins;

  /// callkit
  bool _enableIOSVoIP = false;
  String? _callKitCallID;

  Future<void> _initPermissions() async {
    ZegoLoggerService.logInfo(
      'init permissions',
      tag: 'call',
      subTag: 'call invitation service',
    );

    await requestPermission(Permission.notification);
  }

  Future<void> _initContext() async {
    ZegoLoggerService.logInfo(
      'init context',
      tag: 'call',
      subTag: 'call invitation service',
    );

    ZegoUIKit().login(_data.userID, _data.userName);
    await ZegoUIKit().init(appID: _data.appID, appSign: _data.appSign);

    ZegoUIKit.instance.turnCameraOn(false);

    _pageManager.init(
      ringtoneConfig: _data.ringtoneConfig,
    );
  }

  Future<void> _uninitContext() async {
    ZegoLoggerService.logInfo(
      'un-init context',
      tag: 'call',
      subTag: 'call invitation service',
    );

    _notificationManager.uninit();
    _pageManager.uninit();
    await _plugins.uninit();
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

/// @nodoc
class ZegoUIKitPrebuiltCallInvitationServiceData {
  ZegoUIKitPrebuiltCallInvitationServiceData({
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    required this.plugins,
    this.requireConfig,
    this.showDeclineButton = true,
    this.events,
    this.notifyWhenAppRunningInBackgroundOrQuit = true,
    this.isIOSSandboxEnvironment,
    // this.iOSNotificationConfig,
    this.androidNotificationConfig,
    this.controller,
    ZegoCallInvitationInnerText? innerText,
    ZegoRingtoneConfig? ringtoneConfig,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
        innerText = innerText ?? ZegoCallInvitationInnerText();

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// local user info
  final String userID;
  final String userName;

  final ZegoUIKitPrebuiltCallInvitationEvents? events;

  /// we need the [ZegoUIKitPrebuiltCallConfig] to show [ZegoUIKitPrebuiltCall]
  final PrebuiltConfigQuery? requireConfig;

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  ///
  final List<IZegoUIKitPlugin> plugins;

  /// whether to display the reject button, default is true
  final bool showDeclineButton;

  /// whether to enable offline notification, default is true
  final bool notifyWhenAppRunningInBackgroundOrQuit;

  /// iOS only
  final bool? isIOSSandboxEnvironment;

  // final ZegoIOSNotificationConfig? iOSNotificationConfig;

  /// only for Android
  final ZegoAndroidNotificationConfig? androidNotificationConfig;

  final ZegoCallInvitationInnerText innerText;

  final ZegoUIKitPrebuiltCallController? controller;
}
