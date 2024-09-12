// Dart imports:
import 'dart:io' show Platform;
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../internal/permission.dart';

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
      'context:$context, ',
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

    if (Platform.isAndroid) {
      if (null == callInvitationData.config.systemAlertWindowConfirmDialog) {
        await requestSystemAlertWindowPermission();
      } else {
        PermissionStatus status = await Permission.systemAlertWindow.status;
        if (status != PermissionStatus.granted) {
          await PackageInfo.fromPlatform().then((info) async {
            await permissionConfirmationDialog(
              context,
              dialogConfig:
                  callInvitationData.config.systemAlertWindowConfirmDialog!,
              dialogInfo: ZegoCallPermissionConfirmDialogInfo(
                title:
                    '${callInvitationData.innerText.permissionConfirmDialogTitle.replaceFirst(param_1, info.packageName.isEmpty ? 'App' : info.appName)} ${callInvitationData.innerText.systemAlertWindowConfirmDialogSubTitle}',
                cancelButtonName: callInvitationData
                    .innerText.permissionConfirmDialogDenyButton,
                confirmButtonName: callInvitationData
                    .innerText.permissionConfirmDialogAllowButton,
              ),
            ).then((isAllow) async {
              if (!isAllow) {
                ZegoLoggerService.logInfo(
                  'requestPermission of systemAlertWindow, not allow',
                  tag: 'call-invitation',
                  subTag: 'notification manager',
                );

                return;
              }
              await requestSystemAlertWindowPermission();
            });
          });
        }
      }
    }

    await ZegoCallPluginPlatform.instance
        .createNotificationChannel(
      ZegoSignalingPluginLocalNotificationChannelConfig(
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
      ZegoSignalingPluginLocalNotificationChannelConfig(
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
      ZegoSignalingPluginLocalNotificationChannelConfig(
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

    await cancelInvitationNotification();
  }

  Future<void> requestSystemAlertWindowPermission() async {
    /// for bring app to foreground from background in Android 10
    await requestPermission(Permission.systemAlertWindow).then((value) {
      ZegoLoggerService.logInfo(
        'request system alert window permission result:$value',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    }).then((_) {
      ZegoLoggerService.logInfo(
        'requestPermission of systemAlertWindow done',
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

  void addMissedCallNotification(
    ZegoCallInvitationData invitationData,
    Future<void> Function(
      ZegoCallInvitationData invitationData,
    ) clickedCallback,
  ) {
    if (!isInit) {
      ZegoLoggerService.logError(
        'not init',
        tag: 'call-invitation',
        subTag: 'notification manager, missed call notification',
      );
    }

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
        : callInvitationData.innerText.missedGroupAudioCallNotificationContent;
    final oneOnOneMissedCallContent =
        ZegoCallInvitationType.videoCall == invitationData.type
            ? callInvitationData.innerText.missedVideoCallNotificationContent
            : callInvitationData.innerText.missedAudioCallNotificationContent;
    ZegoCallPluginPlatform.instance.addLocalIMNotification(
      ZegoSignalingPluginLocalIMNotificationConfig(
        id: notificationID,
        channelID: missedCallChannelKey,
        title: callInvitationData.innerText.missedCallNotificationTitle,
        content:
            '${invitationData.inviter?.name ?? ''} ${invitationData.invitees.length > 1 ? groupMissedCallContent : oneOnOneMissedCallContent}',
        iconSource: getIconSource(callInvitationData.notificationConfig
            .androidNotificationConfig?.missedCallChannel.icon),
        soundSource: getSoundSource(callInvitationData.notificationConfig
            .androidNotificationConfig?.missedCallChannel.sound),
        vibrate: callInvitationData.notificationConfig.androidNotificationConfig
                ?.missedCallChannel.vibrate ??
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

          await ZegoCallPluginPlatform.instance.activeAppToForeground();
          await ZegoCallPluginPlatform.instance.requestDismissKeyguard();

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
  }

  void showInvitationNotification(ZegoCallInvitationData invitationData) {
    if (!isInit) {
      ZegoLoggerService.logWarn(
        'not init',
        tag: 'call-invitation',
        subTag: 'notification manager',
      );
    }

    cancelInvitationNotification();

    ZegoCallInvitationNotificationManager.hasInvitation = true;

    ZegoCallPluginPlatform.instance.addLocalCallNotification(
      ZegoSignalingPluginLocalCallNotificationConfig(
          id: _callInvitationNotificationID,
          channelID: callChannelKey,
          iconSource: getIconSource(callInvitationData
              .notificationConfig.androidNotificationConfig?.callChannel.icon),
          soundSource: getSoundSource(callInvitationData
              .notificationConfig.androidNotificationConfig?.callChannel.sound),
          vibrate: callInvitationData.notificationConfig
                  .androidNotificationConfig?.callChannel.vibrate ??
              true,
          title: invitationData.inviter?.name ?? 'unknown',
          content: ZegoCallInvitationType.videoCall == invitationData.type
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
              tag: 'call-invitation',
              subTag: 'notification manager',
            );

            ZegoCallInvitationNotificationManager.hasInvitation = false;

            await cancelInvitationNotification();
            await ZegoCallPluginPlatform.instance.activeAppToForeground();
            await ZegoCallPluginPlatform.instance.requestDismissKeyguard();

            ZegoCallKitBackgroundService().acceptInvitationInBackground();
          },
          rejectCallback: () async {
            ZegoLoggerService.logInfo(
              'LocalNotification, rejectCallback',
              tag: 'call-invitation',
              subTag: 'notification manager',
            );

            ZegoCallInvitationNotificationManager.hasInvitation = false;

            await cancelInvitationNotification();

            ZegoCallKitBackgroundService().refuseInvitationInBackground();
          },
          cancelCallback: () {
            ZegoLoggerService.logInfo(
              'LocalNotification, cancelCallback',
              tag: 'call-invitation',
              subTag: 'notification manager',
            );

            ZegoCallInvitationNotificationManager.hasInvitation = false;

            ZegoCallKitBackgroundService().refuseInvitationInBackground();
          },
          clickCallback: () async {
            ZegoLoggerService.logInfo(
              'LocalNotification, clickCallback',
              tag: 'call-invitation',
              subTag: 'notification manager',
            );

            await cancelInvitationNotification();
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
