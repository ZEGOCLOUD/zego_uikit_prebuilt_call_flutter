// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';

/// @nodoc
/// An implementation of [ZegoCallPluginPlatform] that uses method channels.
class MethodChannelZegoCallPlugin extends ZegoCallPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('call_plugin');

  /// plugin notification callback name
  static const String kCallNotificationAccepted = "onCallNotificationAccepted";
  static const String kCallNotificationRejected = "onCallNotificationRejected";
  static const String kCallNotificationCancelled =
      "onCallNotificationCancelled";
  static const String kCallNotificationClicked = "onCallNotificationClicked";
  static const String kNormalNotificationClicked =
      "onNormalNotificationClicked";

  /// active audio by callkit
  /// only support ios
  @override
  Future<void> activeAudioByCallKit() async {
    if (Platform.isAndroid) {
      ZegoLoggerService.logInfo(
        'not support in Android',
        tag: 'call-channel',
        subTag: 'activeAudioByCallKit',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'activeAudioByCallKit',
      tag: 'call-channel',
      subTag: 'activeAudioByCallKit',
    );

    try {
      await methodChannel.invokeMethod<String>('activeAudioByCallKit');
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to active audio by callkit: $e.',
        tag: 'call-channel',
        subTag: 'activeAudioByCallKit',
      );
    }
  }

  /// show local call notification
  /// only support android
  @override
  Future<void> showCallNotification(
    ZegoCallCallNotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'showCallNotification',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'call-channel',
      subTag: 'showCallNotification',
    );

    try {
      await methodChannel.invokeMethod('showCallNotification', {
        'id': config.id.toString(),
        'sound_source': config.soundSource ?? '',
        'icon_source': config.iconSource ?? '',
        'channel_id': config.channelID,
        'title': config.title,
        'content': config.content,
        'accept_text': config.acceptButtonText,
        'reject_text': config.rejectButtonText,
        'vibrate': config.vibrate,
        'is_video': config.isVideo,
      });

      /// set buttons callback
      methodChannel.setMethodCallHandler((call) async {
        ZegoLoggerService.logInfo(
          'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.',
          tag: 'call-channel',
          subTag: 'showCallNotification',
        );

        switch (call.method) {
          case kCallNotificationAccepted:
            config.acceptCallback?.call();
            break;
          case kCallNotificationRejected:
            config.rejectCallback?.call();
            break;
          case kCallNotificationCancelled:
            config.cancelCallback?.call();
            break;
          case kCallNotificationClicked:
            config.clickCallback?.call();
        }
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to add local notification: $e.',
        tag: 'call-channel',
        subTag: 'showCallNotification',
      );
    }
  }

  /// add local normal notification
  @override
  Future<void> showNormalNotification(
    ZegoCallNormalNotificationConfig config,
  ) async {
    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'call-channel',
      subTag: 'showNormalNotification',
    );

    try {
      Map<String, dynamic> parameters = {
        'id': config.id.toString(),
        'title': config.title,
        'content': config.content,
      };
      if (Platform.isAndroid) {
        /// only for android
        parameters.addAll(<String, dynamic>{
          'vibrate': config.vibrate,
          'sound_source': config.soundSource ?? '',
          'icon_source': config.iconSource ?? '',
          'channel_id': config.channelID,
        });
      }

      await methodChannel.invokeMethod('showNormalNotification', parameters);

      /// set buttons callback
      methodChannel.setMethodCallHandler((call) async {
        ZegoLoggerService.logInfo(
          'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.',
          tag: 'call-channel',
          subTag: 'showNormalNotification',
        );

        switch (call.method) {
          case kNormalNotificationClicked:
            final notificationID = call.arguments['notification_id'] ?? -1;
            config.clickCallback?.call(notificationID);
            break;
        }
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to add local IM notification: $e.',
        tag: 'call-channel',
        subTag: 'showNormalNotification',
      );
    }
  }

  /// create notification channel
  /// only support android
  @override
  Future<void> createNotificationChannel(
    ZegoCallNotificationChannelConfig config,
  ) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'createNotificationChannel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'call-channel',
      subTag: 'createNotificationChannel',
    );

    try {
      await methodChannel.invokeMethod('createNotificationChannel', {
        'channel_id': config.channelID,
        'channel_name': config.channelName,
        'sound_source': config.soundSource ?? '',
        'vibrate': config.vibrate,
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to create notification channel: $e.',
        tag: 'call-channel',
        subTag: 'createNotificationChannel',
      );
    }
  }

  /// only support android
  @override
  Future<void> dismissNotification(int notificationID) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'dismissNotification',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'id:$notificationID',
      tag: 'call-channel',
      subTag: 'dismissNotification',
    );

    try {
      await methodChannel.invokeMethod('dismissNotification', {
        'notification_id': notificationID.toString(),
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to dismiss notification, id:$notificationID, exception:$e.',
        tag: 'call-channel',
        subTag: 'dismissNotification',
      );
    }
  }

  /// dismiss all notifications
  /// only support android
  @override
  Future<void> dismissAllNotifications() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'dismissAllNotifications',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'dismissAllNotifications',
      tag: 'call-channel',
      subTag: 'dismissAllNotifications',
    );

    try {
      await methodChannel.invokeMethod('dismissAllNotifications', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to dismiss all notifications: $e.',
        tag: 'call-channel',
        subTag: 'dismissAllNotifications',
      );
    }
  }
}
