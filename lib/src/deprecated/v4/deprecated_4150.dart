// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV4150 = ', '
    'deprecated since 4.15.0, '
    'will be removed after 4.20.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4150';

extension ZegoCallInvitationConfigDeprecated4150 on ZegoCallInvitationConfig {
  @Deprecated('use inCalling.canInvitingInCalling instead$deprecatedTipsV4150')
  bool get canInvitingInCalling => inCalling.canInvitingInCalling;
  @Deprecated('use inCalling.canInvitingInCalling instead$deprecatedTipsV4150')
  set canInvitingInCalling(bool value) =>
      inCalling.canInvitingInCalling = value;

  @Deprecated(
      'use inCalling.onlyInitiatorCanInvite instead$deprecatedTipsV4150')
  bool get onlyInitiatorCanInvite => inCalling.onlyInitiatorCanInvite;
  @Deprecated(
      'use inCalling.onlyInitiatorCanInvite instead$deprecatedTipsV4150')
  set onlyInitiatorCanInvite(bool value) =>
      inCalling.onlyInitiatorCanInvite = value;
}

extension ZegoCallAndroidNotificationConfigDeprecated4150
    on ZegoCallAndroidNotificationConfig {
  @Deprecated('use fullScreenBackgroundAssetURL instead$deprecatedTipsV4150')
  String? get fullScreenBackground => fullScreenBackgroundAssetURL;
  @Deprecated('use fullScreenBackgroundAssetURL instead$deprecatedTipsV4150')
  set fullScreenBackground(String? value) =>
      fullScreenBackgroundAssetURL = value;

  /// call
  @Deprecated('use callChannel.channelID instead$deprecatedTipsV4150')
  String get channelID => callChannel.channelID;
  @Deprecated('use callChannel.channelID instead$deprecatedTipsV4150')
  set channelID(String value) => callChannel.channelID = value;

  @Deprecated('use callChannel.channelName instead$deprecatedTipsV4150')
  String get channelName => callChannel.channelName;
  @Deprecated('use callChannel.channelName instead$deprecatedTipsV4150')
  set channelName(String value) => callChannel.channelName = value;

  @Deprecated('use callChannel.icon instead$deprecatedTipsV4150')
  String? get icon => callChannel.icon;
  @Deprecated('use callChannel.icon instead$deprecatedTipsV4150')
  set icon(String? value) => callChannel.icon = value;

  @Deprecated('use callChannel.sound instead$deprecatedTipsV4150')
  String? get sound => callChannel.sound;
  @Deprecated('use callChannel.sound instead$deprecatedTipsV4150')
  set sound(String? value) => callChannel.sound = value;

  @Deprecated('use callChannel.vibrate instead$deprecatedTipsV4150')
  bool get vibrate => callChannel.vibrate;
  @Deprecated('use callChannel.vibrate instead$deprecatedTipsV4150')
  set vibrate(bool value) => callChannel.vibrate = value;

  /// message
  @Deprecated('use messageChannel.channelID instead$deprecatedTipsV4150')
  String get messageChannelID => messageChannel.channelID;
  @Deprecated('use messageChannel.channelID instead$deprecatedTipsV4150')
  set messageChannelID(String value) => messageChannel.channelID = value;

  @Deprecated('use messageChannel.channelName instead$deprecatedTipsV4150')
  String get messageChannelName => messageChannel.channelName;
  @Deprecated('use messageChannel.channelName instead$deprecatedTipsV4150')
  set messageChannelName(String value) => messageChannel.channelName = value;

  @Deprecated('use messageChannel.icon instead$deprecatedTipsV4150')
  String? get messageIcon => messageChannel.icon;
  @Deprecated('use messageChannel.icon instead$deprecatedTipsV4150')
  set messageIcon(String? value) => messageChannel.icon = value;

  @Deprecated('use messageChannel.sound instead$deprecatedTipsV4150')
  String? get messageSound => messageChannel.sound;
  @Deprecated('use messageChannel.sound instead$deprecatedTipsV4150')
  set messageSound(String? value) => messageChannel.sound = value;

  @Deprecated('use messageChannel.vibrate instead$deprecatedTipsV4150')
  bool get messageVibrate => callChannel.vibrate;
  @Deprecated('use messageChannel.vibrate instead$deprecatedTipsV4150')
  set messageVibrate(bool value) => callChannel.vibrate = value;
}
