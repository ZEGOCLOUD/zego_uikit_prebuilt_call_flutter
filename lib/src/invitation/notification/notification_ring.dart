// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:vibration/vibration.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Flutter imports:

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
      'set _isRingtoneRunning to $_isRingTimerRunning',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );
  }

  ZegoRingtone();

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

    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        /// not silenced
        category: AVAudioSessionCategory.playback,
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.unknown,
        usageType: AndroidUsageType.notificationRingtone,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
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
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      audioPlayer.setVolume(audioPlayerVolume);

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

    // 如果没有启动铃声或铃声播放器，直接返回
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
}
