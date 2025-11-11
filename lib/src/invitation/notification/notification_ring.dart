// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';

/// Audio context type enumeration
enum AudioContextType {
  speaker,
  earpiece,
  unknown,
}

/// Custom exception for audio context switching errors
class AudioContextSwitchException implements Exception {
  final String message;
  final dynamic originalException;

  AudioContextSwitchException(this.message, this.originalException);

  @override
  String toString() =>
      'AudioContextSwitchException: $message (Original: $originalException)';
}

/// @nodoc
class ZegoRingtone {
  double audioPlayerVolume = 1.0;
  bool _isRingTimerRunning = false;
  bool _isRingtoneRunning = false;
  var audioPlayer = AudioPlayer();

  bool isVibrate = true;
  String prefix = '';
  String cachePrefix = '';
  String sourcePath = '';
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  /// Current audio context type used by the audio player
  AudioContextType _currentAudioContextType = AudioContextType.unknown;

  /// Flag to track if audio route monitoring is enabled
  bool _isAudioRouteMonitoringEnabled = false;

  /// Get the current audio context type used by the audio player
  AudioContextType get currentAudioContextType => _currentAudioContextType;

  /// Check if currently using speaker
  bool get isUsingSpeaker =>
      _currentAudioContextType == AudioContextType.speaker;

  /// Check if currently using earpiece
  bool get isUsingEarpiece =>
      _currentAudioContextType == AudioContextType.earpiece;

  /// Get description of current audio context status (for debugging)
  String get audioContextStatusInfo =>
      'Current audio context: ${_currentAudioContextType.name}, '
      'isSpeaker: $isUsingSpeaker, '
      'isEarpiece: $isUsingEarpiece';

  AudioContext get defaultAudioContext => AudioContext(
        iOS: AudioContextIOS(
          /// not silenced
          category: AVAudioSessionCategory.playAndRecord,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,

          /// Use speech content type and voiceCommunication usage to prevent
          /// Android AudioPolicyManager from automatically switching audio route
          /// from earpiece to speaker during ringtone playback loop.
          /// This ensures the audio stays on the selected output device (speaker/earpiece).
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.voiceCommunication,
          audioFocus: AndroidAudioFocus.gain,

          /// Use inCommunication mode to match voice call scenario,
          /// which properly supports both speaker and earpiece routing
          audioMode: AndroidAudioMode.inCommunication,
        ),
      );

  AudioContext get earpieceAudioContextConfig {
    /// For iOS, explicitly use playAndRecord category to support earpiece routing
    /// This prevents audioplayers from using Ambient category which only supports speaker
    /// For Android, use speech + voiceCommunication to prevent AudioPolicyManager
    /// from auto-switching back to speaker during ringtone loop playback
    return AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,

        /// CRITICAL: Use speech + voiceCommunication to keep audio on earpiece
        /// Without this, Android AudioPolicyManager will automatically switch
        /// audio route from earpiece to speaker after ~10 seconds during loop playback
        contentType: AndroidContentType.speech,
        usageType: AndroidUsageType.voiceCommunication,
        audioFocus: AndroidAudioFocus.gain,

        /// Use inCommunication mode to match voice call scenario,
        /// which properly supports both speaker and earpiece routing
        audioMode: AndroidAudioMode.inCommunication,
      ),
    );
  }

  AudioContext get speakerAudioContextConfig {
    if (Platform.isAndroid) {
      return AudioContextConfig(
        route: AudioContextConfigRoute.speaker,
        respectSilence: true,
      ).build();
    }

    return AudioContextConfig(
      route: AudioContextConfigRoute.speaker,
      respectSilence: false,
    ).build();
  }

  bool get isRingTimerRunning => _isRingTimerRunning;
  set isRingTimerRunning(bool value) {
    _isRingTimerRunning = value;

    ZegoLoggerService.logInfo(
      'set _isRingTimerRunning to $_isRingTimerRunning',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );
  }

  bool get isRingtoneRunning => _isRingtoneRunning;
  set isRingtoneRunning(bool value) {
    _isRingtoneRunning = value;

    ZegoLoggerService.logInfo(
      'set _isRingtoneRunning to $_isRingtoneRunning',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );
  }

  ZegoRingtone() {
    _initAudioPlayerListeners();
    _initAudioRouteMonitoring();
  }

  void _initAudioPlayerListeners() {
    // Listen to player state changes
    _playerStateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      ZegoLoggerService.logInfo(
        'AudioPlayer state changed to: $state, '
        'isRingTimerRunning:$isRingTimerRunning, '
        'isRingtoneRunning:$isRingtoneRunning, ',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      _handlePlayerStateChanged(state);
    });

    // Listen to player complete events
    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((_) {
      ZegoLoggerService.logInfo(
        'AudioPlayer playback completed, '
        'isRingTimerRunning:$isRingTimerRunning, '
        'isRingtoneRunning:$isRingtoneRunning, ',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      _handlePlayerComplete();
    });
  }

  void _handlePlayerStateChanged(PlayerState state) {
    ZegoLoggerService.logInfo(
      'Player state changed to $state',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );
  }

  void _handlePlayerComplete() {
    ZegoLoggerService.logInfo(
      'player complete, '
      'isRingTimerRunning:$isRingTimerRunning, '
      'isRingtoneRunning:$isRingtoneRunning, ',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    if (isRingTimerRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ZegoLoggerService.logInfo(
          'isRingTimerRunning is running, '
          're-play cause complete by unknown reason',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );

        await _playWithRetry(maxRetries: 2);
      });
    }
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    audioPlayer.dispose();
    _disableAudioRouteMonitoring();
  }

  /// Initialize audio route monitoring (Android only)
  void _initAudioRouteMonitoring() {
    if (!Platform.isAndroid) {
      return;
    }

    ZegoCallPluginPlatform.instance.setAudioRouteChangedCallback((info) {
      _handleAudioRouteChanged(info);
    });
  }

  /// Handle audio route changed event from native Android
  void _handleAudioRouteChanged(Map<dynamic, dynamic> info) {
    final event = info['event'] ?? 'unknown';
    final isSpeakerphoneOn = info['isSpeakerphoneOn'] ?? false;
    final isBluetoothScoOn = info['isBluetoothScoOn'] ?? false;
    final isWiredHeadsetOn = info['isWiredHeadsetOn'] ?? false;
    final mode = info['mode'] ?? -1;

    ZegoLoggerService.logInfo(
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '🔊 Android Audio Route Changed\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      'Event: $event\n'
      'Speakerphone: ${isSpeakerphoneOn ? '✅ ON' : '❌ OFF'}\n'
      'Bluetooth: ${isBluetoothScoOn ? '✅ ON' : '❌ OFF'}\n'
      'Wired Headset: ${isWiredHeadsetOn ? '✅ Connected' : '❌ Disconnected'}\n'
      'Mode: ${_getAndroidAudioModeName(mode)}\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      tag: 'call-invitation',
      subTag: 'ringtone-android-route',
    );

    if (info.containsKey('devices')) {
      final devices = info['devices'] as List;
      final deviceInfo =
          StringBuffer('Available Devices (${devices.length}):\n');
      for (var device in devices) {
        deviceInfo.write('  📱 ${device['type']} (ID: ${device['id']})\n');
      }
      ZegoLoggerService.logInfo(
        deviceInfo.toString(),
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    }
  }

  /// Get Android audio mode name for debugging
  String _getAndroidAudioModeName(int mode) {
    switch (mode) {
      case 0:
        return 'NORMAL';
      case 1:
        return 'RINGTONE';
      case 2:
        return 'IN_CALL';
      case 3:
        return 'IN_COMMUNICATION';
      default:
        return 'UNKNOWN ($mode)';
    }
  }

  /// Enable audio route monitoring (Android only)
  Future<void> _enableAudioRouteMonitoring() async {
    if (!Platform.isAndroid || _isAudioRouteMonitoringEnabled) {
      return;
    }

    try {
      await ZegoCallPluginPlatform.instance.startMonitoringAudioRoute();
      _isAudioRouteMonitoringEnabled = true;
      ZegoLoggerService.logInfo(
        '✅ Android audio route monitoring started',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );

      // Get initial audio route info
      final info = await ZegoCallPluginPlatform.instance.getAudioRouteInfo();
      ZegoLoggerService.logInfo(
        '📊 Initial audio route state: $info',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    } catch (e) {
      ZegoLoggerService.logError(
        '❌ Failed to start Android audio route monitoring: $e',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    }
  }

  /// Disable audio route monitoring (Android only)
  Future<void> _disableAudioRouteMonitoring() async {
    if (!Platform.isAndroid || !_isAudioRouteMonitoringEnabled) {
      return;
    }

    try {
      await ZegoCallPluginPlatform.instance.stopMonitoringAudioRoute();
      _isAudioRouteMonitoringEnabled = false;
      ZegoLoggerService.logInfo(
        '⏹️ Android audio route monitoring stopped',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    } catch (e) {
      ZegoLoggerService.logError(
        '❌ Failed to stop Android audio route monitoring: $e',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    }
  }

  /// Get current audio route info (Android only, for debugging)
  Future<void> _logCurrentAudioRouteInfo(String context) async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final info = await ZegoCallPluginPlatform.instance.getAudioRouteInfo();
      ZegoLoggerService.logInfo(
        '📊 [$context] Current audio route: $info',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    } catch (e) {
      ZegoLoggerService.logError(
        '❌ Failed to get audio route info: $e',
        tag: 'call-invitation',
        subTag: 'ringtone-android-route',
      );
    }
  }

  /// Set audio player's audio context and record state with retry mechanism
  Future<void> _setAudioPlayerContext(
    AudioContext context,
    AudioContextType type,
  ) async {
    await _setAudioPlayerContextWithRetry(context, type, maxRetries: 3);
  }

  /// Internal method to set audio context with retry logic
  Future<void> _setAudioPlayerContextWithRetry(
    AudioContext context,
    AudioContextType type, {
    required int maxRetries,
  }) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      ZegoLoggerService.logInfo(
        'Setting audio context to ${type.name} on player instance (attempt ${attempt + 1}/${maxRetries + 1})',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      try {
        await audioPlayer.setAudioContext(context);
        _currentAudioContextType = type;

        ZegoLoggerService.logInfo(
          'Audio context successfully set to ${type.name} on attempt ${attempt + 1}',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
        return; // Success, exit retry loop
      } catch (error) {
        final isMediaError = error.toString().contains('MEDIA_ERROR_UNKNOWN');
        final isLastAttempt = attempt == maxRetries;

        if (isMediaError) {
          ZegoLoggerService.logWarn(
            'MediaPlayer MEDIA_ERROR_UNKNOWN during context switch to ${type.name} '
            '(attempt ${attempt + 1}/${maxRetries + 1}): $error',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );

          if (isLastAttempt) {
            // Update context type even on final failure
            _currentAudioContextType = type;

            ZegoLoggerService.logError(
              'All ${maxRetries + 1} attempts failed for context switch to ${type.name}',
              tag: 'call-invitation',
              subTag: 'ringtone',
            );

            throw AudioContextSwitchException(
                'MediaPlayer error during context switch after ${maxRetries + 1} attempts',
                error);
          } else {
            // Calculate exponential backoff delay: 50ms, 100ms, 200ms
            final delayMs = 50 * (1 << attempt);
            ZegoLoggerService.logInfo(
              'Retrying context switch in ${delayMs}ms...',
              tag: 'call-invitation',
              subTag: 'ringtone',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } else {
          // Non-MediaPlayer errors should not be retried
          ZegoLoggerService.logError(
            'Non-MediaPlayer error during context switch to ${type.name}: $error',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
          rethrow;
        }
      }
    }
  }

  /// Wait for AudioPlayer to be ready after setAudioContext
  Future<void> _waitForPlayerReady({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    ZegoLoggerService.logInfo(
      'Waiting for AudioPlayer to be ready after context change...',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    try {
      // Wait for the next duration change event which indicates the player is ready
      await audioPlayer.onDurationChanged.first.timeout(timeout);

      ZegoLoggerService.logInfo(
        'AudioPlayer is ready (duration event received)',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    } catch (timeoutError) {
      ZegoLoggerService.logWarn(
        'Timeout waiting for AudioPlayer ready, proceeding anyway: $timeoutError',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    }
  }

  /// Play audio with retry mechanism for MEDIA_ERROR_UNKNOWN during playback
  Future<void> _playWithRetry({
    required int maxRetries,
    bool waitForReady = false,
  }) async {
    // Wait for player to be ready if requested (after setAudioContext)
    if (waitForReady) {
      await _waitForPlayerReady();
    }
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      ZegoLoggerService.logInfo(
        'Attempting to play audio (attempt ${attempt + 1}/${maxRetries + 1})',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      try {
        await audioPlayer.play(AssetSource(sourcePath));

        ZegoLoggerService.logInfo(
          'Audio playback started successfully on attempt ${attempt + 1}',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
        return; // Success, exit retry loop
      } catch (error) {
        final isMediaError = error.toString().contains('MEDIA_ERROR_UNKNOWN');
        final isLastAttempt = attempt == maxRetries;

        if (isMediaError) {
          ZegoLoggerService.logWarn(
            'MediaPlayer MEDIA_ERROR_UNKNOWN during playback '
            '(attempt ${attempt + 1}/${maxRetries + 1}): $error',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );

          if (isLastAttempt) {
            ZegoLoggerService.logError(
              'All ${maxRetries + 1} play attempts failed, starting recovery',
              tag: 'call-invitation',
              subTag: 'ringtone',
            );

            // If all play attempts fail, try recovery
            await _recoverFromPlaybackError();
            return;
          } else {
            // Wait before retry - very short delays since we already have stabilization delays
            final delayMs = 20 * (1 << attempt); // 20ms, 40ms, 80ms
            ZegoLoggerService.logInfo(
              'Retrying play in ${delayMs}ms...',
              tag: 'call-invitation',
              subTag: 'ringtone',
            );
            await Future.delayed(Duration(milliseconds: delayMs));
          }
        } else {
          // Non-MediaPlayer errors should trigger immediate recovery
          ZegoLoggerService.logError(
            'Non-MediaPlayer error during playback: $error',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
          await _recoverFromPlaybackError();
          return;
        }
      }
    }
  }

  /// Set global audio context
  Future<void> _setGlobalAudioContext(
      AudioContext context, AudioContextType type) async {
    ZegoLoggerService.logInfo(
      'Setting global audio context to ${type.name}',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    try {
      await AudioPlayer.global.setAudioContext(context);
      // Note: global setting won't affect state recording of already created player instances
      ZegoLoggerService.logInfo(
        'Global audio context successfully set to ${type.name}',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    } catch (error) {
      ZegoLoggerService.logError(
        'Failed to set global audio context to ${type.name}: $error',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
      rethrow;
    }
  }

  void init({
    required String prefix,
    required String sourcePath,
    required bool isVibrate,
  }) {
    ZegoLoggerService.logInfo(
      'init: prefix:$prefix, source path:$sourcePath',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    this.prefix = prefix;
    this.sourcePath = sourcePath;
    this.isVibrate = isVibrate;

    audioPlayerVolume = audioPlayer.volume;

    // Initialize as speaker mode (default)
    _setGlobalAudioContext(defaultAudioContext, AudioContextType.speaker);
  }

  bool isZero(double val) {
    return val.abs() < 1e-6;
  }

  Future<void> startRing({
    required bool testPlayRingtone,
  }) async {
    if (isRingTimerRunning) {
      ZegoLoggerService.logInfo(
        'ring is running',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      return;
    }

    bool isPlayByRingtone = false;
    if (testPlayRingtone) {
      /// don't play on callee if silent mode
      final volume = await FlutterVolumeController.getVolume(
            stream: AudioStream.music,
          ) ??
          1.0;
      isPlayByRingtone = isZero(volume);
    }

    isRingTimerRunning = true;

    // Enable audio route monitoring for Android
    await _enableAudioRouteMonitoring();

    ZegoLoggerService.logInfo(
      '(${identityHashCode(this)}) '
      'start ring, '
      'prefix:$prefix, '
      'source path:$sourcePath, '
      'isPlayByRingtone:$isPlayByRingtone, '
      '',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    cachePrefix = AudioCache.instance.prefix;
    AudioCache.instance.prefix = prefix;

    if (isPlayByRingtone) {
      isRingtoneRunning = true;
      FlutterRingtonePlayer().play(
        volume: 0.3,
        fromAsset: '$prefix$sourcePath',
        looping: true,
      );
    } else {
      // Set corresponding audio context based on current audio route
      final currentAudioRoute = ZegoUIKit().getLocalUser().audioRoute.value;
      final isSpeaker = currentAudioRoute == ZegoUIKitAudioRoute.Speaker;
      final targetContext =
          isSpeaker ? speakerAudioContextConfig : earpieceAudioContextConfig;
      final targetType =
          isSpeaker ? AudioContextType.speaker : AudioContextType.earpiece;

      await _setAudioPlayerContext(targetContext, targetType);

      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.setVolume(audioPlayerVolume);

      onAudioRouteChanged();
      ZegoUIKit().getLocalUser().audioRoute.addListener(onAudioRouteChanged);

      try {
        await _playWithRetry(maxRetries: 3);
        ZegoLoggerService.logInfo(
          'audioPlayer initial play completed',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
      } catch (e) {
        ZegoLoggerService.logError(
          'audioPlayer initial play failed after retries: $e',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
      }
    }

    if (isVibrate) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator) {
          Vibration.vibrate();
        } else {
          ZegoLoggerService.logWarn(
            'has not vibrate capabilities',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
        }
      });
    }

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!isRingTimerRunning) {
        ZegoLoggerService.logInfo(
          'ring timer ended',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );

        timer.cancel();

        try {
          audioPlayerVolume = audioPlayer.volume;

          /// Turn off the sound first, otherwise it may still ring
          audioPlayer.setVolume(0);

          await audioPlayer.stop().then((value) {
            ZegoLoggerService.logInfo(
              'audioPlayer stop done',
              tag: 'call-invitation',
              subTag: 'ringtone',
            );
          });
        } catch (e) {
          ZegoLoggerService.logInfo(
            'audioPlayer stop error:$e',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
        }
      } else {
        if (isVibrate) {
          Vibration.hasVibrator().then((hasVibrator) {
            if (hasVibrator) {
              Vibration.vibrate();
            } else {
              ZegoLoggerService.logWarn(
                'has not vibrate capabilities',
                tag: 'call-invitation',
                subTag: 'ringtone',
              );
            }
          });
        }
      }
    });
  }

  Future<void> stopRing() async {
    // Log current audio route info before stopping (Android only)
    await _logCurrentAudioRouteInfo('stopRing');

    ZegoLoggerService.logInfo(
      '(${identityHashCode(this)}) '
      'stop ring, '
      'prefix:$prefix, '
      'source path:$sourcePath, ',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    // Disable audio route monitoring for Android
    await _disableAudioRouteMonitoring();

    // Return directly if no ringtone or ringtone player is started
    if (!isRingTimerRunning && !isRingtoneRunning) {
      ZegoLoggerService.logInfo(
        'no ring is running, skip stop',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
      return;
    }

    if (isRingtoneRunning) {
      isRingtoneRunning = false;

      FlutterRingtonePlayer().stop();
      // await ZegoCallPluginPlatform.instance.stopRingtone();
    }

    try {
      ZegoUIKit().getLocalUser().audioRoute.removeListener(onAudioRouteChanged);

      await audioPlayer.stop().then((value) {
        ZegoLoggerService.logInfo(
          'audioPlayer stop done',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
      });
    } catch (e) {
      ZegoLoggerService.logInfo(
        'audioPlayer stop error:$e',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    } finally {
      if (isRingTimerRunning) {
        AudioCache.instance.prefix = cachePrefix;
      }

      isRingTimerRunning = false;
    }
  }

  Future<void> onAudioRouteChanged() async {
    final currentAudioRoute = ZegoUIKit().getLocalUser().audioRoute.value;
    ZegoLoggerService.logInfo(
      'local user audio route changed to $currentAudioRoute',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    await switchTo(isSpeaker: currentAudioRoute == ZegoUIKitAudioRoute.Speaker);
  }

  Future<void> switchTo({bool isSpeaker = true}) async {
    // Log current audio route info before switching (Android only)
    await _logCurrentAudioRouteInfo('switchTo - BEFORE');

    ZegoLoggerService.logInfo(
      'switch to ${isSpeaker ? 'speaker' : 'earpiece'}, update context',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    final targetContext =
        isSpeaker ? speakerAudioContextConfig : earpieceAudioContextConfig;
    final targetType =
        isSpeaker ? AudioContextType.speaker : AudioContextType.earpiece;

    // Check if switching is needed (avoid repeatedly setting the same context)
    if (_currentAudioContextType == targetType) {
      ZegoLoggerService.logInfo(
        'Audio context is already set to ${targetType.name}, skipping switch',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
      return;
    }

    if (isRingTimerRunning && !isRingtoneRunning) {
      try {
        await _setAudioPlayerContext(targetContext, targetType);

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          ZegoLoggerService.logInfo(
            're-play after update context',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );

          ZegoLoggerService.logInfo(
            'Starting playback after context switch (waiting for player ready)',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );

          await _playWithRetry(maxRetries: 3, waitForReady: true);

          // Log audio route info after switching (Android only)
          await _logCurrentAudioRouteInfo('switchTo - AFTER');
        });
      } catch (error) {
        if (error is AudioContextSwitchException) {
          ZegoLoggerService.logWarn(
            'Audio context switch failed with MediaPlayer error after retries, attempting recovery',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );

          // Attempt recovery after a longer delay since retries already failed
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 250));
            await _recoverFromPlaybackError();
          });
        } else {
          ZegoLoggerService.logError(
            'Failed to switch audio context during playback: $error',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
        }
      }
    } else {
      await _setGlobalAudioContext(targetContext, targetType);
    }

    // Log audio route info after switching (Android only)
    await _logCurrentAudioRouteInfo('switchTo - AFTER (final)');
  }

  /// Recover from playback errors by restarting the ring
  Future<void> _recoverFromPlaybackError() async {
    if (!isRingTimerRunning || isRingtoneRunning) {
      ZegoLoggerService.logInfo(
        'Skipping recovery: isRingTimerRunning=$isRingTimerRunning, isRingtoneRunning=$isRingtoneRunning',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'Attempting to recover from playback error by restarting ring',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    try {
      // Stop current playback
      await audioPlayer.stop();

      // Reset player state
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.setVolume(audioPlayerVolume);

      // Set correct audio context based on current route with retry mechanism
      final currentAudioRoute = ZegoUIKit().getLocalUser().audioRoute.value;
      final isSpeaker = currentAudioRoute == ZegoUIKitAudioRoute.Speaker;
      final targetContext =
          isSpeaker ? speakerAudioContextConfig : earpieceAudioContextConfig;
      final targetType =
          isSpeaker ? AudioContextType.speaker : AudioContextType.earpiece;

      // Use retry mechanism for recovery as well, but with fewer retries
      await _setAudioPlayerContextWithRetry(
        targetContext,
        targetType,
        maxRetries: 2,
      );

      ZegoLoggerService.logInfo(
        'Restarting playback after recovery (waiting for player ready)',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      // Restart playback with retry mechanism and wait for ready
      await _playWithRetry(maxRetries: 2, waitForReady: true);

      ZegoLoggerService.logInfo(
        'Successfully recovered from playback error',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    } catch (recoveryError) {
      ZegoLoggerService.logError(
        'Failed to recover from playback error: $recoveryError',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      // If recovery fails, stop the ring to avoid indefinite error state
      ZegoLoggerService.logWarn(
        'Recovery failed, stopping ring to avoid error loop',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      isRingTimerRunning = false;
    }
  }
}
