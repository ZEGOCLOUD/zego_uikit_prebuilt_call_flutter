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
import 'package:zego_uikit_prebuilt_call/src/call_invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';

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

  String get callChannelKey =>
      callInvitationConfig.androidNotificationConfig?.channelID ??
      defaultCallChannelKey;

  String get callChannelName =>
      callInvitationConfig.androidNotificationConfig?.channelName ??
      defaultCallChannelName;

  String get messageChannelID =>
      callInvitationConfig.androidNotificationConfig?.messageChannelID ??
      defaultMessageChannelID;

  String get messageChannelName =>
      callInvitationConfig.androidNotificationConfig?.messageChannelName ??
      defaultMessageChannelName;

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

    await ZegoCallPluginPlatform.instance.createNotificationChannel(
      ZegoSignalingPluginLocalNotificationChannelConfig(
        channelID: callChannelKey,
        channelName: callChannelName,
        vibrate:
            callInvitationConfig.androidNotificationConfig?.vibrate ?? true,
        soundSource: getSoundSource(
          callInvitationConfig.androidNotificationConfig?.sound,
        ),
      ),
    );

    await ZegoCallPluginPlatform.instance.createNotificationChannel(
      ZegoSignalingPluginLocalNotificationChannelConfig(
        channelID: messageChannelID,
        channelName: messageChannelName,
        vibrate:
            callInvitationConfig.androidNotificationConfig?.messageVibrate ??
                false,
        soundSource: getSoundSource(
          callInvitationConfig.androidNotificationConfig?.messageSound,
        ),
      ),
    );

    await ZegoCallPluginPlatform.instance.dismissAllNotifications();
  }

  Future<void> cancelAll() async {
    ZegoLoggerService.logInfo(
      'cancelAll',
      tag: 'call',
      subTag: 'notification manager',
    );

    /// clear notifications
    await ZegoCallPluginPlatform.instance.dismissAllNotifications();
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

    ZegoCallPluginPlatform.instance.dismissAllNotifications();

    ZegoNotificationManager.hasInvitation = true;

    ZegoCallPluginPlatform.instance.addLocalCallNotification(
      ZegoSignalingPluginLocalCallNotificationConfig(
          id: Random().nextInt(2147483647),
          channelID: callChannelKey,
          iconSource: getIconSource(
              callInvitationConfig.androidNotificationConfig?.icon),
          soundSource: getSoundSource(
              callInvitationConfig.androidNotificationConfig?.sound),
          vibrate:
              callInvitationConfig.androidNotificationConfig?.vibrate ?? true,
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
          acceptButtonText:
              callInvitationConfig.innerText?.incomingCallPageAcceptButton ??
                  'Accept',
          rejectButtonText:
              callInvitationConfig.innerText?.incomingCallPageDeclineButton ??
                  'Decline',
          acceptCallback: () async {
            ZegoLoggerService.logInfo(
              'LocalNotification, acceptCallback',
              tag: 'call',
              subTag: 'notification manager',
            );

            ZegoNotificationManager.hasInvitation = false;

            await ZegoCallPluginPlatform.instance.dismissAllNotifications();
            await ZegoCallPluginPlatform.instance.activeAppToForeground();
            await ZegoCallPluginPlatform.instance.requestDismissKeyguard();

            ZegoCallKitBackgroundService().acceptInvitationInBackground();
          },
          rejectCallback: () async {
            ZegoLoggerService.logInfo(
              'LocalNotification, rejectCallback',
              tag: 'call',
              subTag: 'notification manager',
            );

            ZegoNotificationManager.hasInvitation = false;

            await ZegoCallPluginPlatform.instance.dismissAllNotifications();

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

            await ZegoCallPluginPlatform.instance.dismissAllNotifications();
            await ZegoCallPluginPlatform.instance.activeAppToForeground();
            await ZegoCallPluginPlatform.instance.requestDismissKeyguard();
          }),
    );
  }

  static String? getIconSource(String? iconFileName) {
    String? iconSource;

    if (Platform.isAndroid && (iconFileName?.isNotEmpty ?? false)) {
      var targetIconFileName = iconFileName ?? '';
      final postfixIndex = targetIconFileName.indexOf('.');
      if (-1 != postfixIndex) {
        targetIconFileName = targetIconFileName.substring(0, postfixIndex);
      }

      iconSource = 'resource://drawable/$targetIconFileName';

      ZegoLoggerService.logInfo(
        "icon file, config name:${iconFileName ?? ""}, "
        'file name:$targetIconFileName, source:$iconSource',
        tag: 'call',
        subTag: 'notification manager',
      );
    }

    return iconSource;
  }

  static String? getSoundSource(String? soundFileName) {
    String? soundSource;

    if (Platform.isAndroid && (soundFileName?.isNotEmpty ?? false)) {
      var targetSoundFileName = soundFileName ?? '';
      final postfixIndex = targetSoundFileName.indexOf('.');
      if (-1 != postfixIndex) {
        targetSoundFileName = targetSoundFileName.substring(0, postfixIndex);
      }

      soundSource = 'resource://raw/$targetSoundFileName';

      ZegoLoggerService.logInfo(
        "sound file, config name:${soundFileName ?? ""}, "
        'file name:$targetSoundFileName, source:$soundSource',
        tag: 'call',
        subTag: 'notification manager',
      );
    }

    return soundSource;
  }
}
