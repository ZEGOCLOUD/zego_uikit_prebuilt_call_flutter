// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Flutter imports:

/// @nodoc
class ZegoRingtone {
  bool isRingTimerRunning = false;
  var audioPlayer = AudioPlayer();

  bool isVibrate = true;
  String prefix = '';
  String cachePrefix = '';
  String sourcePath = '';

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

    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: const {
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: const AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
  }

  Future<void> startRing() async {
    if (isRingTimerRunning) {
      ZegoLoggerService.logInfo(
        'ring is running',
        tag: 'call-invitation',
        subTag: 'ringtone',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'start ring, source path:$sourcePath',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    isRingTimerRunning = true;

    cachePrefix = AudioCache.instance.prefix;
    AudioCache.instance.prefix = prefix;

    audioPlayer.setReleaseMode(ReleaseMode.loop);
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
    if (isVibrate) {
      Vibration.hasVibrator().then((hasVibrator) {
        if (hasVibrator ?? false) {
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

        try {
          audioPlayer.stop().then((value) {
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

        timer.cancel();
      } else {
        if (isVibrate) {
          Vibration.hasVibrator().then((hasVibrator) {
            if (hasVibrator ?? false) {
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
      'stop ring',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    if (isRingTimerRunning) {
      AudioCache.instance.prefix = cachePrefix;
    }

    isRingTimerRunning = false;

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
    }
  }
}
