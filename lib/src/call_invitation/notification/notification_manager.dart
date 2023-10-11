// Dart imports:
import 'dart:io' show Platform;
import 'dart:math';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';

/// @nodoc
class ZegoNotificationManager {
  bool isInit = false;
  final bool showDeclineButton;
  final ZegoCallInvitationConfig callInvitationConfig;

  ZegoNotificationManager({
    required this.showDeclineButton,
    required this.callInvitationConfig,
  });

  static bool hasInvitation = false;

  String get channelKey =>
      callInvitationConfig.androidNotificationConfig?.channelID ??
      'CallInvitation';

  String get channelName =>
      callInvitationConfig.androidNotificationConfig?.channelName ??
      'Call Invitation';

  Future<void> init() async {
    if (isInit) {
      ZegoLoggerService.logInfo(
        'init already',
        tag: 'call',
        subTag: 'notification manager',
      );

      return;
    }

    isInit = true;

    ZegoLoggerService.logInfo(
      'init',
      tag: 'call',
      subTag: 'notification manager',
    );

    await requestPermission(Permission.notification).then((value) {
      ZegoLoggerService.logInfo(
        'request notification permission result:$value',
        tag: 'call',
        subTag: 'notification manager',
      );
    });

    /// for bring app to foreground from background in Android 10
    await requestPermission(Permission.systemAlertWindow).then((value) {
      ZegoLoggerService.logInfo(
        'request system alert window permission result:$value',
        tag: 'call',
        subTag: 'notification manager',
      );
    });

    initNotificationPlugin();
  }

  Future<void> initNotificationPlugin() async {
    await ZegoUIKit().getSignalingPlugin().createNotificationChannel(
          ZegoSignalingPluginOutgoingNotificationChannelConfig(
            channelID: channelKey,
            channelName: channelName,
            soundSource: getSoundSource(),
          ),
        );

    await ZegoUIKit().getSignalingPlugin().dismissAllNotifications();
  }

  Future<void> cancelAll() async {
    ZegoLoggerService.logInfo(
      'cancelAll',
      tag: 'call',
      subTag: 'notification manager',
    );

    /// clear notifications
    await ZegoUIKit().getSignalingPlugin().dismissAllNotifications();
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'call',
      subTag: 'notification manager',
    );

    isInit = false;
    cancelAll();
  }

  void showInvitationNotification(ZegoCallInvitationData invitationData) {
    if (!isInit) {
      ZegoLoggerService.logWarn(
        'not init',
        tag: 'call',
        subTag: 'notification manager',
      );
    }

    ZegoUIKit().getSignalingPlugin().dismissAllNotifications();

    ZegoNotificationManager.hasInvitation = true;

    ZegoUIKit().getSignalingPlugin().addLocalNotification(
          ZegoSignalingPluginOutgoingNotificationConfig(
              id: Random().nextInt(2147483647),
              channelID: channelKey,
              iconSource: getIconSource(),
              soundSource: getSoundSource(),
              title: invitationData.inviter?.name ?? 'unknown',
              content: ZegoCallType.videoCall == invitationData.type
                  ? ((invitationData.invitees.length > 1
                          ? callInvitationConfig
                              .innerText?.incomingGroupVideoCallDialogMessage
                          : callInvitationConfig
                              .innerText?.incomingVideoCallDialogMessage) ??
                      'Incoming video call...')
                  : ((invitationData.invitees.length > 1
                          ? callInvitationConfig
                              .innerText?.incomingGroupVoiceCallDialogMessage
                          : callInvitationConfig
                              .innerText?.incomingVoiceCallDialogMessage) ??
                      'Incoming voice call...'),
              acceptButtonText: callInvitationConfig
                      .innerText?.incomingCallPageAcceptButton ??
                  'Accept',
              rejectButtonText: callInvitationConfig
                      .innerText?.incomingCallPageDeclineButton ??
                  'Decline',
              acceptCallback: () async {
                ZegoLoggerService.logInfo(
                  'LocalNotification, acceptCallback',
                  tag: 'call',
                  subTag: 'notification manager',
                );

                ZegoNotificationManager.hasInvitation = false;

                await ZegoUIKit()
                    .getSignalingPlugin()
                    .dismissAllNotifications();
                await ZegoUIKit().getSignalingPlugin().activeAppToForeground();
                await ZegoUIKit().getSignalingPlugin().requestDismissKeyguard();

                ZegoCallKitBackgroundService().acceptInvitationInBackground();
              },
              rejectCallback: () async {
                ZegoLoggerService.logInfo(
                  'LocalNotification, rejectCallback',
                  tag: 'call',
                  subTag: 'notification manager',
                );

                ZegoNotificationManager.hasInvitation = false;

                await ZegoUIKit()
                    .getSignalingPlugin()
                    .dismissAllNotifications();

                ZegoCallKitBackgroundService().refuseInvitationInBackground();
              },
              cancelCallback: () {
                ZegoLoggerService.logInfo(
                  'LocalNotification, cancelCallback',
                  tag: 'call',
                  subTag: 'notification manager',
                );

                ZegoNotificationManager.hasInvitation = false;

                ZegoCallKitBackgroundService().refuseInvitationInBackground();
              },
              clickCallback: () async {
                ZegoLoggerService.logInfo(
                  'LocalNotification, clickCallback',
                  tag: 'call',
                  subTag: 'notification manager',
                );

                await ZegoUIKit()
                    .getSignalingPlugin()
                    .dismissAllNotifications();
                await ZegoUIKit().getSignalingPlugin().activeAppToForeground();
                await ZegoUIKit().getSignalingPlugin().requestDismissKeyguard();
              }),
        );
  }

  String? getIconSource() {
    String? iconSource;

    if (Platform.isAndroid &&
        (callInvitationConfig.androidNotificationConfig?.icon?.isNotEmpty ??
            false)) {
      var iconFileName =
          callInvitationConfig.androidNotificationConfig?.icon ?? '';
      final postfixIndex = iconFileName.indexOf('.');
      if (-1 != postfixIndex) {
        iconFileName = iconFileName.substring(0, postfixIndex);
      }

      iconSource = 'resource://drawable/$iconFileName';

      ZegoLoggerService.logInfo(
        "icon file, config name:${callInvitationConfig.androidNotificationConfig?.icon ?? ""}, "
        'file name:$iconFileName, source:$iconSource',
        tag: 'call',
        subTag: 'notification manager',
      );
    }

    return iconSource;
  }

  String? getSoundSource() {
    String? soundSource;

    if (Platform.isAndroid &&
        (callInvitationConfig.androidNotificationConfig?.sound?.isNotEmpty ??
            false)) {
      var soundFileName =
          callInvitationConfig.androidNotificationConfig?.sound ?? '';
      final postfixIndex = soundFileName.indexOf('.');
      if (-1 != postfixIndex) {
        soundFileName = soundFileName.substring(0, postfixIndex);
      }

      soundSource = 'resource://raw/$soundFileName';

      ZegoLoggerService.logInfo(
        "sound file, config name:${callInvitationConfig.androidNotificationConfig?.sound ?? ""}, "
        'file name:$soundFileName, source:$soundSource',
        tag: 'call',
        subTag: 'notification manager',
      );
    }

    return soundSource;
  }
}
