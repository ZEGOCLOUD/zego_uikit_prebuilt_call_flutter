// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_inviataion_config.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoNotificationManager {
  final ZegoCallInvitationConfig callInvitationConfig;
  ZegoUIKitPrebuiltCallInvitationEvents? events;

  ZegoNotificationManager({
    this.events,
    required this.callInvitationConfig,
  }) {
    if (callInvitationConfig.notifyWhenAppRunningInBackgroundOrQuit) {
      init();
    }
  }

  String get channelKey =>
      callInvitationConfig.androidNotificationConfig?.channelID ??
      'CallInvitation';

  String get channelName =>
      callInvitationConfig.androidNotificationConfig?.channelName ??
      'Call Invitation';

  void init() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'notification',
      subTag: 'notification manager',
    );

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
        "sound file, config name:${callInvitationConfig.androidNotificationConfig?.sound ?? ""}, file name:$soundFileName",
        tag: 'notification',
        subTag: 'page manager',
      );
    }

    AwesomeNotifications()
        .initialize(
            // set the icon to null if you want to use the default app icon
            '', //'''resource://drawable/res_app_icon',
            [
              NotificationChannel(
                channelGroupKey: 'zego_prebuilt_call_channel_group',
                channelKey: channelKey,
                channelName: channelName,
                channelDescription: 'Notification channel for call',
                defaultColor: const Color(0xFF9D50DD),
                soundSource: soundSource,
                ledColor: Colors.white,
              )
            ],
            // Channel groups are only visual and are not required
            channelGroups: [
              NotificationChannelGroup(
                channelGroupKey: 'zego_prebuilt_call_channel_group',
                channelGroupName: 'Call Notifications Channel Group',
              )
            ],
            debug: true)
        .then((value) {
      ZegoLoggerService.logInfo(
        'init finished',
        tag: 'notification',
        subTag: 'page manager',
      );

      /// clear notifications
      AwesomeNotifications().cancelAll();

      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        ZegoLoggerService.logInfo(
          'is allowed: $isAllowed',
          tag: 'notification',
          subTag: 'page manager',
        );

        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    });
  }

  void uninit() {
    events = null;
  }

  void createNotification(ZegoCallInvitationData invitationData) {
    AwesomeNotifications()
        .createNotification(
            content: NotificationContent(
                id: Random().nextInt(2147483647),
                channelKey: channelKey,
                title: invitationData.inviter?.name ?? 'inviter',
                wakeUpScreen: true,
                body: ZegoCallType.videoCall == invitationData.type
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
                actionType: ActionType.Default))
        .onError((error, stackTrace) {
      ZegoLoggerService.logError(
        error.toString(),
        tag: 'create notification',
        subTag: 'page manager',
      );
      return true;
    });
  }
}
