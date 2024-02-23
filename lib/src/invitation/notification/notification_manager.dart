// Dart imports:
import 'dart:io' show Platform;
import 'dart:math';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';

/// @nodoc
class ZegoCallInvitationNotificationManager {
  bool isInit = false;
  final ZegoCallButtonUIConfig declineButtonConfig;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  ZegoCallInvitationNotificationManager({
    required this.declineButtonConfig,
    required this.callInvitationData,
  });

  static bool hasInvitation = false;

  String get callChannelKey =>
      callInvitationData
          .notificationConfig.androidNotificationConfig?.channelID ??
      defaultCallChannelKey;

  String get callChannelName =>
      callInvitationData
          .notificationConfig.androidNotificationConfig?.channelName ??
      defaultCallChannelName;

  String get messageChannelID =>
      callInvitationData
          .notificationConfig.androidNotificationConfig?.messageChannelID ??
      defaultMessageChannelID;

  String get messageChannelName =>
      callInvitationData
          .notificationConfig.androidNotificationConfig?.messageChannelName ??
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
        vibrate: callInvitationData
                .notificationConfig.androidNotificationConfig?.vibrate ??
            true,
        soundSource: getSoundSource(
          callInvitationData
              .notificationConfig.androidNotificationConfig?.sound,
        ),
      ),
    );

    await ZegoCallPluginPlatform.instance.createNotificationChannel(
      ZegoSignalingPluginLocalNotificationChannelConfig(
        channelID: messageChannelID,
        channelName: messageChannelName,
        vibrate: callInvitationData
                .notificationConfig.androidNotificationConfig?.messageVibrate ??
            false,
        soundSource: getSoundSource(
          callInvitationData
              .notificationConfig.androidNotificationConfig?.messageSound,
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

    ZegoCallInvitationNotificationManager.hasInvitation = true;

    ZegoCallPluginPlatform.instance.addLocalCallNotification(
      ZegoSignalingPluginLocalCallNotificationConfig(
          id: Random().nextInt(2147483647),
          channelID: callChannelKey,
          iconSource: getIconSource(callInvitationData
              .notificationConfig.androidNotificationConfig?.icon),
          soundSource: getSoundSource(callInvitationData
              .notificationConfig.androidNotificationConfig?.sound),
          vibrate: callInvitationData
                  .notificationConfig.androidNotificationConfig?.vibrate ??
              true,
          title: invitationData.inviter?.name ?? 'unknown',
          content: ZegoCallType.videoCall == invitationData.type
              ? ((invitationData.invitees.length > 1
                  ? callInvitationData
                      .innerText.incomingGroupVideoCallDialogMessage
                  : callInvitationData
                      .innerText.incomingVideoCallDialogMessage))
              : ((invitationData.invitees.length > 1
                  ? callInvitationData
                      .innerText.incomingGroupVoiceCallDialogMessage
                  : callInvitationData
                      .innerText.incomingVoiceCallDialogMessage)),
          acceptButtonText:
              callInvitationData.innerText.incomingCallPageAcceptButton,
          rejectButtonText:
              callInvitationData.innerText.incomingCallPageDeclineButton,
          acceptCallback: () async {
            ZegoLoggerService.logInfo(
              'LocalNotification, acceptCallback',
              tag: 'call',
              subTag: 'notification manager',
            );

            ZegoCallInvitationNotificationManager.hasInvitation = false;

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

            ZegoCallInvitationNotificationManager.hasInvitation = false;

            await ZegoCallPluginPlatform.instance.dismissAllNotifications();

            ZegoCallKitBackgroundService().refuseInvitationInBackground();
          },
          cancelCallback: () {
            ZegoLoggerService.logInfo(
              'LocalNotification, cancelCallback',
              tag: 'call',
              subTag: 'notification manager',
            );

            ZegoCallInvitationNotificationManager.hasInvitation = false;

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
