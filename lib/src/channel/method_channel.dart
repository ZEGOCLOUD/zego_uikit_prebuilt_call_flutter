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
        'activeAudioByCallKit, not support in Android',
        tag: 'signaling',
        subTag: 'channel',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'activeAudioByCallKit',
      tag: 'signaling',
      subTag: 'channel',
    );

    try {
      await methodChannel.invokeMethod<String>('activeAudioByCallKit');
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to active audio by callkit: $e.',
        tag: 'signaling',
        subTag: 'channel',
      );
    }
  }

  /// check app running
  /// only support android
  @override
  Future<bool> checkAppRunning() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'checkAppRunning, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'checkAppRunning',
      tag: 'signaling',
      subTag: 'channel',
    );

    var isAppRunning = false;
    try {
      isAppRunning =
          await methodChannel.invokeMethod<bool?>('checkAppRunning') ?? false;
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to check app running: $e.',
        tag: 'signaling',
        subTag: 'channel',
      );
    }

    return isAppRunning;
  }

  /// add local call notification
  /// only support android
  @override
  Future<void> addLocalCallNotification(
    ZegoSignalingPluginLocalCallNotificationConfig config,
  ) async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'addLocalCallNotification, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'addLocalCallNotification:$config',
      tag: 'signaling',
      subTag: 'channel',
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
          tag: 'signaling',
          subTag: 'channel',
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
        tag: 'signaling',
        subTag: 'channel',
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
        'addLocalIMNotification, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'addLocalIMNotification:$config',
      tag: 'signaling',
      subTag: 'channel',
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
          tag: 'signaling',
          subTag: 'channel',
        );

        switch (call.method) {
          case 'onIMNotificationClicked':
            config.clickCallback?.call();
        }
      });
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to add local IM notification: $e.',
        tag: 'signaling',
        subTag: 'channel',
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
        'createNotificationChannel, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'createNotificationChannel:$config',
      tag: 'signaling',
      subTag: 'channel',
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
        tag: 'signaling',
        subTag: 'channel',
      );
    }
  }

  /// dismiss all notifications
  /// only support android
  @override
  Future<void> dismissAllNotifications() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'dismissAllNotifications, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'dismissAllNotifications',
      tag: 'signaling',
      subTag: 'channel',
    );

    try {
      await methodChannel.invokeMethod('dismissAllNotifications', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to dismiss all notifications: $e.',
        tag: 'signaling',
        subTag: 'channel',
      );
    }
  }

  /// active app to foreground
  /// only support android
  @override
  Future<void> activeAppToForeground() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'activeAppToForeground, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'activeAppToForeground',
      tag: 'signaling',
      subTag: 'channel',
    );

    try {
      await methodChannel.invokeMethod('activeAppToForeground', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to active app to foreground: $e.',
        tag: 'signaling',
        subTag: 'channel',
      );
    }
  }

  /// request dismiss keyguard
  /// only support android
  @override
  Future<void> requestDismissKeyguard() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'requestDismissKeyguard, not support in iOS',
        tag: 'signaling',
        subTag: 'channel',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'requestDismissKeyguard',
      tag: 'signaling',
      subTag: 'channel',
    );

    try {
      await methodChannel.invokeMethod('requestDismissKeyguard', {});
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to request dismiss keyguard: $e.',
        tag: 'signaling',
        subTag: 'channel',
      );
    }
  }
}
