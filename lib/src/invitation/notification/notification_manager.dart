// Dart imports:
import 'dart:io' show Platform;
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/callkit_incoming.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// @nodoc
class ZegoCallInvitationNotificationManager {
  bool isInit = false;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final int _callInvitationNotificationID = Random().nextInt(2147483647);
  final Map<int, ZegoCallInvitationData> _missedCallNotificationIDDataMap = {};

  ZegoCallInvitationNotificationManager({
    required this.callInvitationData,
  });

  static bool hasInvitation = false;

  String get callChannelKey =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.callChannel.channelID ??
      defaultCallChannelKey;

  String get callChannelName =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.callChannel.channelName ??
      defaultCallChannelName;

  String get missedCallChannelKey =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.missedCallChannel.channelID ??
      defaultMissedCallChannelKey;

  String get missedCallChannelName =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.missedCallChannel.channelName ??
      defaultMissedCallChannelName;

  String get messageChannelID =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.messageChannel.channelID ??
      defaultMessageChannelID;

  String get messageChannelName =>
      callInvitationData.notificationConfig.androidNotificationConfig
          ?.messageChannel.channelName ??
      defaultMessageChannelName;

  Future<void> init(BuildContext? context) async {
    if (isInit) {
      ZegoLoggerService.logInfo(
        'init already',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );

      return;
    }

    isInit = true;

    ZegoLoggerService.logInfo(
      'init, '
      'context:$context, '
      'permissions:${callInvitationData.config.permissions}, ',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    await createChannels();

    await requestNotificationPermission();
    await requestSystemAlertWindowPermission();
    if (callInvitationData.config.permissions
        .contains(ZegoCallInvitationPermission.manuallyByUser)) {
      await ZegoUIKitPrebuiltCallInvitationService()
          .private
          .requestPermissionsNeedManuallyByUser();
    }

    await cancelInvitationNotification();
  }

  Future<void> requestNotificationPermission() async {
    ZegoLoggerService.logInfo(
      'start request notification permission',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    await requestPermission(Permission.notification).then((value) {
      ZegoLoggerService.logInfo(
        'request notification permission result:$value',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    }).then((_) {
      ZegoLoggerService.logInfo(
        'requestPermission of notification done',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    });
  }

  Future<bool> requestSystemAlertWindowPermission() async {
    ZegoLoggerService.logInfo(
      'start request system alert window permission',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    if (callInvitationData.config.permissions
        .contains(ZegoCallInvitationPermission.systemAlertWindow)) {
      return await ZegoUIKitPrebuiltCallInvitationService()
          .private
          .requestSystemAlertWindowPermission();
    }

    return true;
  }

  Future<bool> hasSystemAlertWindowPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    PermissionStatus status = await Permission.systemAlertWindow.status;
    return status == PermissionStatus.granted;
  }

  Future<void> createChannels() async {
    ZegoLoggerService.logInfo(
      'start create channels',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    await ZegoCallPluginPlatform.instance
        .createNotificationChannel(
      ZegoCallNotificationChannelConfig(
        channelID: callChannelKey,
        channelName: callChannelName,
        vibrate: callInvitationData.notificationConfig.androidNotificationConfig
                ?.callChannel.vibrate ??
            true,
        soundSource: getSoundSource(
          callInvitationData
              .notificationConfig.androidNotificationConfig?.callChannel.sound,
        ),
      ),
    )
        .then((_) {
      ZegoLoggerService.logInfo(
        'createNotificationChannel of call done',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    });

    await ZegoCallPluginPlatform.instance
        .createNotificationChannel(
      ZegoCallNotificationChannelConfig(
        channelID: missedCallChannelKey,
        channelName: missedCallChannelName,
        vibrate: callInvitationData.notificationConfig.androidNotificationConfig
                ?.missedCallChannel.vibrate ??
            true,
        soundSource: getSoundSource(
          callInvitationData.notificationConfig.androidNotificationConfig
              ?.missedCallChannel.sound,
        ),
      ),
    )
        .then((_) {
      ZegoLoggerService.logInfo(
        'createNotificationChannel of missed call done',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    });

    await ZegoCallPluginPlatform.instance
        .createNotificationChannel(
      ZegoCallNotificationChannelConfig(
        channelID: messageChannelID,
        channelName: messageChannelName,
        vibrate: callInvitationData.notificationConfig.androidNotificationConfig
                ?.messageChannel.vibrate ??
            false,
        soundSource: getSoundSource(
          callInvitationData.notificationConfig.androidNotificationConfig
              ?.messageChannel.sound,
        ),
      ),
    )
        .then((_) {
      ZegoLoggerService.logInfo(
        'createNotificationChannel of message done',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    });
  }

  Future<void> cancelInvitationNotification() async {
    ZegoLoggerService.logInfo(
      'cancelCallNotification',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    /// clear notifications
    await ZegoCallPluginPlatform.instance
        .dismissNotification(_callInvitationNotificationID);
  }

  Future<void> cancelMissedCallNotification() async {
    ZegoLoggerService.logInfo(
      'cancelMissedCallNotification',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    /// clear notifications

    _missedCallNotificationIDDataMap.forEach((notificationID, _) async {
      await ZegoCallPluginPlatform.instance.dismissNotification(notificationID);
    });
  }

  void uninit() {
    ZegoLoggerService.logInfo(
      'uninit',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );

    isInit = false;
    cancelMissedCallNotification();
    cancelInvitationNotification();
  }

  Future<void> addMissedCallNotification(
    ZegoCallInvitationData invitationData,
    Future<void> Function(
      ZegoCallInvitationData invitationData,
    ) clickedCallback,
  ) async {
    if (!isInit) {
      ZegoLoggerService.logError(
        'not init',
        tag: 'call-invitation',
        subTag: 'notification manager, missed call notification',
      );
    }

    ZegoLoggerService.logInfo(
      'add notification, check permission..',
      tag: 'call-invitation',
      subTag: 'notification manager, missed call notification',
    );

    await requestNotificationPermission().then((_) {
      ZegoLoggerService.logInfo(
        'add notification, check permission done',
        tag: 'call-invitation',
        subTag: 'notification manager, missed call notification',
      );

      final notificationID = Random().nextInt(2147483647);
      _missedCallNotificationIDDataMap[notificationID] = invitationData;

      ZegoLoggerService.logInfo(
        'add notification, '
        'id:$notificationID, '
        'data: $invitationData',
        tag: 'call-invitation',
        subTag: 'notification manager, missed call notification',
      );

      final groupMissedCallContent = ZegoCallInvitationType.videoCall ==
              invitationData.type
          ? callInvitationData.innerText.missedGroupVideoCallNotificationContent
          : callInvitationData
              .innerText.missedGroupAudioCallNotificationContent;
      final oneOnOneMissedCallContent =
          ZegoCallInvitationType.videoCall == invitationData.type
              ? callInvitationData.innerText.missedVideoCallNotificationContent
              : callInvitationData.innerText.missedAudioCallNotificationContent;

      ZegoCallPluginPlatform.instance.showNormalNotification(
        ZegoCallNormalNotificationConfig(
          id: notificationID,
          channelID: missedCallChannelKey,
          title: callInvitationData.innerText.missedCallNotificationTitle,
          content:
              '${invitationData.inviter?.name ?? ''} ${invitationData.invitees.length > 1 ? groupMissedCallContent : oneOnOneMissedCallContent}',
          iconSource: getIconSource(callInvitationData.notificationConfig
              .androidNotificationConfig?.missedCallChannel.icon),
          soundSource: getSoundSource(callInvitationData.notificationConfig
              .androidNotificationConfig?.missedCallChannel.sound),
          vibrate: callInvitationData.notificationConfig
                  .androidNotificationConfig?.missedCallChannel.vibrate ??
              false,
          clickCallback: (int notificationID) async {
            ZegoLoggerService.logInfo(
              'missed call notification clicked:$notificationID',
              tag: 'call-invitation',
              subTag: 'notification manager, missed call notification',
            );

            final missedCallInvitationData =
                _missedCallNotificationIDDataMap[notificationID] ??
                    ZegoCallInvitationData.empty();
            _missedCallNotificationIDDataMap
                .removeWhere((id, _) => id == notificationID);

            await ZegoCallPluginPlatform.instance
                .dismissNotification(notificationID);

            await ZegoUIKit().activeAppToForeground();
            await ZegoUIKit().requestDismissKeyguard();

            if (missedCallInvitationData.isEmpty) {
              ZegoLoggerService.logError(
                'missed data is not exist, notification id:$notificationID, '
                'missed call notification ids:${_missedCallNotificationIDDataMap.keys}',
                tag: 'call-invitation',
                subTag: 'notification manager, missed call notification',
              );

              return;
            }

            defaultAction() async {
              await clickedCallback(
                missedCallInvitationData,
              );
            }

            if (null !=
                callInvitationData
                    .invitationEvents?.onIncomingMissedCallClicked) {
              await callInvitationData
                  .invitationEvents?.onIncomingMissedCallClicked
                  ?.call(
                missedCallInvitationData.callID,
                ZegoCallUser.fromUIKit(
                  invitationData.inviter ?? ZegoUIKitUser.empty(),
                ),
                missedCallInvitationData.type,
                missedCallInvitationData.invitees
                    .map((invitee) => ZegoCallUser.fromUIKit(invitee))
                    .toList(),
                missedCallInvitationData.customData,
                defaultAction,
              );
            } else {
              await defaultAction.call();
            }
          },
        ),
      );
    });
  }

  Future<bool> showInvitationNotification(
    ZegoCallInvitationData invitationData,
  ) async {
    if (!isInit) {
      ZegoLoggerService.logWarn(
        'not init',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );

      return false;
    }

    await cancelInvitationNotification();

    ZegoLoggerService.logInfo(
      'show invitation notification, check permission...',
      tag: 'call-invitation',
      subTag: 'notification manager',
    );
    return await hasSystemAlertWindowPermission()
        .then((bool hasPermission) async {
      if (!hasPermission) {
        ZegoLoggerService.logWarn(
          'show invitation notification, '
          'check permission done, '
          'but has not system alert window permission, '
          'data: $invitationData',
          tag: 'call-invitation',
          subTag: 'notification manager',
        );

        return false;
      }

      ZegoLoggerService.logInfo(
        'show invitation notification, '
        'check permission done, '
        'has permission, '
        'show, data: $invitationData',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );

      ZegoCallInvitationNotificationManager.hasInvitation = true;

      await showCallkitIncoming(
        caller: invitationData.inviter,
        callType: invitationData.type,
        callID: invitationData.callID,
        timeoutSeconds: invitationData.timeoutSeconds,
        callChannelName: callChannelName,
        missedCallChannelName: missedCallChannelName,
        ringtonePath: callInvitationData.notificationConfig
                .androidNotificationConfig?.callChannel.sound ??
            '',
        iOSIconName: callInvitationData
            .notificationConfig.iOSNotificationConfig?.systemCallingIconName,
      );

      return true;
    });
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
        tag: 'call-invitation',
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
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    }

    return soundSource;
  }
}
