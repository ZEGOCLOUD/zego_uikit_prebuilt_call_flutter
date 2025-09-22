// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
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
          category: AVAudioSessionCategory.playback,
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

  AudioContext get earpieceAudioContextConfig => AudioContextConfig(
        route: AudioContextConfigRoute.earpiece,
        respectSilence: false,
      ).build();

  AudioContext get speakerAudioContextConfig => AudioContextConfig(
        route: AudioContextConfigRoute.speaker,
        respectSilence: false,
      ).build();

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
        'AudioPlayer state changed to: $state',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      _handlePlayerStateChanged(state);
    });

    // Listen to player complete events
    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((_) {
      ZegoLoggerService.logInfo(
        'AudioPlayer playback completed',
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
  }

  void dispose() {
    _playerStateSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    audioPlayer.dispose();
  }

  /// Set audio player's audio context and record state
  Future<void> _setAudioPlayerContext(
      AudioContext context, AudioContextType type) async {
    ZegoLoggerService.logInfo(
      'Setting audio context to ${type.name} on player instance',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    try {
      await audioPlayer.setAudioContext(context);
      _currentAudioContextType = type;

      ZegoLoggerService.logInfo(
        'Audio context successfully set to ${type.name}',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
    } catch (error) {
      ZegoLoggerService.logError(
        'Failed to set audio context to ${type.name}: $error',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );
      rethrow;
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

      ZegoUIKit().getLocalUser().audioRoute.addListener(onAudioRouteChanged);

      try {
        await audioPlayer.play(AssetSource(sourcePath)).then((value) {
          ZegoLoggerService.logInfo(
            'audioPlayer play done',
            tag: 'call-invitation',
            subTag: 'ringtone',
          );
        });
      } catch (e) {
        ZegoLoggerService.logInfo(
          'audioPlayer play error:$e',
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
        await audioPlayer.play(AssetSource(sourcePath));
      } catch (error) {
        ZegoLoggerService.logError(
          'Failed to switch audio context during playback: $error',
          tag: 'call-invitation',
          subTag: 'ringtone',
        );
      }
    } else {
      await _setGlobalAudioContext(targetContext, targetType);
    }
  }
}
