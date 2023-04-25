// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
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
  }

  void uninit() {
    events = null;
  }
}
