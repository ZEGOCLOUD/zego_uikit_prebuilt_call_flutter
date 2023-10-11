part of '../call_invitation_service.dart';

/// @nodoc
mixin ZegoUIKitPrebuiltCallInvitationServicePrivate {
  ContextQuery? _contextQuery;
  ZegoUIKitPrebuiltCallInvitationServiceData? _data;
  ZegoInvitationPageManager? _pageManager;
  ZegoCallInvitationConfig? _callInvitationConfig;
  ZegoPrebuiltPlugins? _plugins;

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

  Future<void> _uninitContext() async {
    ZegoLoggerService.logInfo(
      'un-init context',
      tag: 'call',
      subTag: 'call invitation service',
    );

    _pageManager?.uninit();
    await _plugins?.uninit();
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
    this.showCancelInvitationButton = true,
    this.events,
    this.notifyWhenAppRunningInBackgroundOrQuit = true,
    this.iOSNotificationConfig,
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

  /// whether to display the invitation cancel button, default is true
  final bool showCancelInvitationButton;

  /// whether to enable offline notification, default is true
  final bool notifyWhenAppRunningInBackgroundOrQuit;

  ZegoIOSNotificationConfig? iOSNotificationConfig;

  /// only for Android
  final ZegoAndroidNotificationConfig? androidNotificationConfig;

  final ZegoCallInvitationInnerText innerText;

  final ZegoUIKitPrebuiltCallController? controller;
}
