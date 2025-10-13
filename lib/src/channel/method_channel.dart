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

  /// audio route callback name (Android only)
  static const String kAudioRouteChanged = "onAudioRouteChanged";

  /// audio route changed callback
  Function(Map<dynamic, dynamic> info)? _audioRouteChangedCallback;

  /// call notification config (for callback)
  ZegoCallCallNotificationConfig? _callNotificationConfig;

  /// normal notification config (for callback)
  ZegoCallNormalNotificationConfig? _normalNotificationConfig;

  /// Constructor
  MethodChannelZegoCallPlugin() {
    _setupMethodCallHandler();
  }

  /// Setup unified method call handler to handle all callbacks
  void _setupMethodCallHandler() {
    methodChannel.setMethodCallHandler((call) async {
      ZegoLoggerService.logInfo(
        'MethodCallHandler, method:${call.method}, arguments:${call.arguments}.',
        tag: 'call-channel',
        subTag: 'handler',
      );

      switch (call.method) {
        case kCallNotificationAccepted:
          _callNotificationConfig?.acceptCallback?.call();
          _callNotificationConfig = null;
          break;
        case kCallNotificationRejected:
          _callNotificationConfig?.rejectCallback?.call();
          _callNotificationConfig = null;
          break;
        case kCallNotificationCancelled:
          _callNotificationConfig?.cancelCallback?.call();
          _callNotificationConfig = null;
          break;
        case kCallNotificationClicked:
          _callNotificationConfig?.clickCallback?.call();
          _callNotificationConfig = null;
          break;
        case kNormalNotificationClicked:
          final notificationID = call.arguments['notification_id'] ?? -1;
          _normalNotificationConfig?.clickCallback?.call(notificationID);
          _normalNotificationConfig = null;
          break;
        case kAudioRouteChanged:
          final info = call.arguments as Map<dynamic, dynamic>;
          _audioRouteChangedCallback?.call(info);
          break;
        default:
          ZegoLoggerService.logWarn(
            'Unknown method: ${call.method}',
            tag: 'call-channel',
            subTag: 'handler',
          );
      }
    });
  }

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
      // Store config for callback handling
      _callNotificationConfig = config;

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
      // Store config for callback handling
      _normalNotificationConfig = config;

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

  /// start monitoring audio route
  /// only support android
  @override
  Future<void> startMonitoringAudioRoute() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'startMonitoringAudioRoute',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'startMonitoringAudioRoute',
      tag: 'call-channel',
      subTag: 'startMonitoringAudioRoute',
    );

    try {
      await methodChannel.invokeMethod('startMonitoringAudioRoute');
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to start monitoring audio route: $e.',
        tag: 'call-channel',
        subTag: 'startMonitoringAudioRoute',
      );
    }
  }

  /// stop monitoring audio route
  /// only support android
  @override
  Future<void> stopMonitoringAudioRoute() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'stopMonitoringAudioRoute',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'stopMonitoringAudioRoute',
      tag: 'call-channel',
      subTag: 'stopMonitoringAudioRoute',
    );

    try {
      await methodChannel.invokeMethod('stopMonitoringAudioRoute');
      _audioRouteChangedCallback = null;
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to stop monitoring audio route: $e.',
        tag: 'call-channel',
        subTag: 'stopMonitoringAudioRoute',
      );
    }
  }

  /// get audio route info
  /// only support android
  @override
  Future<Map<dynamic, dynamic>> getAudioRouteInfo() async {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'getAudioRouteInfo',
      );

      return {};
    }

    ZegoLoggerService.logInfo(
      'getAudioRouteInfo',
      tag: 'call-channel',
      subTag: 'getAudioRouteInfo',
    );

    try {
      final result = await methodChannel.invokeMethod('getAudioRouteInfo');
      return result as Map<dynamic, dynamic>;
    } on PlatformException catch (e) {
      ZegoLoggerService.logError(
        'Failed to get audio route info: $e.',
        tag: 'call-channel',
        subTag: 'getAudioRouteInfo',
      );
      return {};
    }
  }

  /// set audio route changed callback
  /// only support android
  @override
  void setAudioRouteChangedCallback(
      Function(Map<dynamic, dynamic> info)? callback) {
    if (Platform.isIOS) {
      ZegoLoggerService.logInfo(
        'not support in iOS',
        tag: 'call-channel',
        subTag: 'setAudioRouteChangedCallback',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'setAudioRouteChangedCallback, callback: ${callback != null}',
      tag: 'call-channel',
      subTag: 'setAudioRouteChangedCallback',
    );

    _audioRouteChangedCallback = callback;
  }
}
