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

  /// add local call notification
  /// only support android
  @override
  Future<void> addLocalCallNotification(
    ZegoSignalingPluginLocalCallNotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'addLocalCallNotification',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'call-channel',
      subTag: 'addLocalCallNotification',
    );

    try {
      await methodChannel.invokeMethod('addLocalCallNotification', {
        'id': config.id.toString(),
        'sound_source': config.soundSource ?? '',
        'icon_source': config.iconSource ?? '',
        'channel_id': config.channelID,
        'title': config.title,
        'content': config.content,
        'accept_text': config.acceptButtonText,
        'reject_text': config.rejectButtonText,
        'vibrate': config.vibrate,
      });

      /// set buttons callback
      methodChannel.setMethodCallHandler((call) async {
        ZegoLoggerService.logInfo(
          'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.',
          tag: 'call-channel',
          subTag: 'addLocalCallNotification',
        );

        switch (call.method) {
          case 'onNotificationAccepted':
            config.acceptCallback?.call();
            break;
          case 'onNotificationRejected':
            config.rejectCallback?.call();
            break;
          case 'onNotificationCancelled':
            config.cancelCallback?.call();
            break;
          case 'onNotificationClicked':
            config.clickCallback?.call();
        }
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to add local notification: $e.',
        tag: 'call-channel',
        subTag: 'addLocalCallNotification',
      );
    }
  }

  /// add local IM notification
  /// only support android
  @override
  Future<void> addLocalIMNotification(
    ZegoSignalingPluginLocalIMNotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'addLocalIMNotification',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'config:$config',
      tag: 'call-channel',
      subTag: 'addLocalIMNotification',
    );

    try {
      await methodChannel.invokeMethod('addLocalIMNotification', {
        'id': config.id.toString(),
        'sound_source': config.soundSource ?? '',
        'icon_source': config.iconSource ?? '',
        'channel_id': config.channelID,
        'title': config.title,
        'content': config.content,
        'vibrate': config.vibrate,
      });

      /// set buttons callback
      methodChannel.setMethodCallHandler((call) async {
        ZegoLoggerService.logInfo(
          'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.',
          tag: 'call-channel',
          subTag: 'addLocalIMNotification',
        );

        switch (call.method) {
          case 'onIMNotificationClicked':
            final notificationID = call.arguments['notification_id'] ?? -1;
            config.clickCallback?.call(notificationID);
        }
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to add local IM notification: $e.',
        tag: 'call-channel',
        subTag: 'addLocalIMNotification',
      );
    }
  }

  /// create notification channel
  /// only support android
  @override
  Future<void> createNotificationChannel(
    ZegoSignalingPluginLocalNotificationChannelConfig config,
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
