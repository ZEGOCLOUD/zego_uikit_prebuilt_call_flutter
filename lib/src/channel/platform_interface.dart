// Package imports:
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'method_channel.dart';

/// @nodoc
abstract class ZegoCallPluginPlatform extends PlatformInterface {
  /// Constructs a ZegoCallPluginPlatform.
  ZegoCallPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZegoCallPluginPlatform _instance = MethodChannelZegoCallPlugin();

  /// The default instance of [ZegoCallPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUntitled].
  static ZegoCallPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ZegoCallPluginPlatform] when
  /// they register themselves.
  static set instance(ZegoCallPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// activeAudioByCallKit
  Future<void> activeAudioByCallKit() {
    throw UnimplementedError('activeAudioByCallKit has not been implemented.');
  }

  /// checkAppRunning
  Future<bool> checkAppRunning() {
    throw UnimplementedError('checkAppRunning has not been implemented.');
  }

  /// addLocalCallNotification
  Future<void> addLocalCallNotification(
    ZegoSignalingPluginLocalCallNotificationConfig config,
  ) {
    throw UnimplementedError(
        'addLocalCallNotification has not been implemented.');
  }

  /// addLocalIMNotification
  Future<void> addLocalIMNotification(
    ZegoSignalingPluginLocalIMNotificationConfig config,
  ) {
    throw UnimplementedError(
        'addLocalIMNotification has not been implemented.');
  }

  /// createNotificationChannel
  Future<void> createNotificationChannel(
    ZegoSignalingPluginLocalNotificationChannelConfig config,
  ) {
    throw UnimplementedError(
        'createNotificationChannel has not been implemented.');
  }

  /// dismissAllNotifications
  Future<void> dismissAllNotifications() {
    throw UnimplementedError(
        'dismissAllNotifications has not been implemented.');
  }

  /// activeAppToForeground
  Future<void> activeAppToForeground() {
    throw UnimplementedError('activeAppToForeground has not been implemented.');
  }

  Future<void> requestDismissKeyguard() {
    throw UnimplementedError(
        'requestDismissKeyguard has not been implemented.');
  }
}
