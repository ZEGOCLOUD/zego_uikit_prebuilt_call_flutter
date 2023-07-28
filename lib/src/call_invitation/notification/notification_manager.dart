// Dart imports:
import 'dart:io' show Platform;
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';

// Package imports:
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';

/// @nodoc
class ZegoNotificationManager {
  final bool showDeclineButton;
  final ZegoCallInvitationConfig callInvitationConfig;

  ZegoNotificationManager({
    required this.showDeclineButton,
    required this.callInvitationConfig,
  }) {
    if (callInvitationConfig.notifyWhenAppRunningInBackgroundOrQuit) {
      init();
    }
  }

  static bool hasInvitation = false;

  static String keyAccept = 'key_accept';
  static String keyDecline = 'key_decline';

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (ZegoNotificationManager.keyAccept == receivedAction.buttonKeyPressed) {
      ZegoNotificationManager.hasInvitation = false;

      ZegoCallKitBackgroundService().acceptInvitationInBackground();
    } else if (ZegoNotificationManager.keyDecline ==
        receivedAction.buttonKeyPressed) {
      ZegoNotificationManager.hasInvitation = false;

      ZegoCallKitBackgroundService().refuseInvitationInBackground();
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
                soundSource: soundSource,
                importance: NotificationImportance.Max,
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

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: ZegoNotificationManager.onActionReceivedMethod,
      );

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

  Future<void> cancelAll() async {
    ZegoLoggerService.logInfo(
      'cancelAll',
      tag: 'notification',
      subTag: 'page manager',
    );

    /// clear notifications
    await AwesomeNotifications().cancelAll();
  }

  void uninit() {}

  void showInvitationNotification(ZegoCallInvitationData invitationData) {
    ZegoNotificationManager.hasInvitation = true;

    final declineButton = NotificationActionButton(
      key: ZegoNotificationManager.keyDecline,
      label: callInvitationConfig.innerText?.incomingCallPageDeclineButton ??
          'Decline',
      color: Colors.white,
      actionType: ActionType.KeepOnTop,
    );
    final acceptButton = NotificationActionButton(
      key: ZegoNotificationManager.keyAccept,
      label: callInvitationConfig.innerText?.incomingCallPageAcceptButton ??
          'Accept',
      color: Colors.white,
    );

    AwesomeNotifications()
        .createNotification(
      content: NotificationContent(
          id: Random().nextInt(2147483647),
          channelKey: channelKey,
          title: invitationData.inviter?.name ?? 'unknown',
          wakeUpScreen: true,
          fullScreenIntent: true,
          notificationLayout: NotificationLayout.Default,
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
          actionType: ActionType.Default),
      actionButtons: showDeclineButton
          ? [
              declineButton,
              acceptButton,
            ]
          : [
              acceptButton,
            ],
    )
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
