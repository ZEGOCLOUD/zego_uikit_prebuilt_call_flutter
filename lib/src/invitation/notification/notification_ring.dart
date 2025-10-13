// Dart imports:
import 'dart:async';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Flutter imports:

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
          contentType: AndroidContentType.unknown,
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );

  AudioContext get earpieceAudioContextConfig {
    if (Platform.isIOS) {
      // For iOS, explicitly use playAndRecord category to support earpiece routing
      // This prevents audioplayers from using Ambient category which only supports speaker
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
          contentType: AndroidContentType.unknown,
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );
    }

    return AudioContextConfig(
      route: AudioContextConfigRoute.earpiece,
      respectSilence: true,
    ).build();
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
      final isSpeaker = currentAudioRoute == ZegoUIKitAudioRoute.speaker;
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
    ZegoLoggerService.logInfo(
      '(${identityHashCode(this)}) '
      'stop ring, '
      'prefix:$prefix, '
      'source path:$sourcePath, ',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

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

    await switchTo(isSpeaker: currentAudioRoute == ZegoUIKitAudioRoute.speaker);
  }

  Future<void> switchTo({bool isSpeaker = true}) async {
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
      final isSpeaker = currentAudioRoute == ZegoUIKitAudioRoute.speaker;
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
