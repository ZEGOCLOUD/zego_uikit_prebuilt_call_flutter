// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
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
      tag: 'call',
      subTag: 'ringtone',
    );

    this.prefix = prefix;
    this.sourcePath = sourcePath;
    this.isVibrate = isVibrate;

    const audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: [
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
          AVAudioSessionOptions.mixWithOthers,
        ],
      ),
      android: AudioContextAndroid(
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
        tag: 'call',
        subTag: 'ringtone',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'start ring, source path:$sourcePath',
      tag: 'call',
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
          tag: 'call',
          subTag: 'ringtone',
        );
      });
    } catch (e) {
      ZegoLoggerService.logInfo(
        'audioPlayer play error:$e',
        tag: 'call',
        subTag: 'ringtone',
      );
    }
    if (isVibrate) {
      Vibrate.vibrate();
    }

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!isRingTimerRunning) {
        ZegoLoggerService.logInfo(
          'ring timer ended',
          tag: 'call',
          subTag: 'ringtone',
        );

        try {
          audioPlayer.stop().then((value) {
            ZegoLoggerService.logInfo(
              'audioPlayer stop done',
              tag: 'call',
              subTag: 'ringtone',
            );
          });
        } catch (e) {
          ZegoLoggerService.logInfo(
            'audioPlayer stop error:$e',
            tag: 'call',
            subTag: 'ringtone',
          );
        }

        timer.cancel();
      } else {
        if (isVibrate) {
          Vibrate.vibrate();
        }
      }
    });
  }

  Future<void> stopRing() async {
    ZegoLoggerService.logInfo(
      'stop ring',
      tag: 'call',
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
          tag: 'call',
          subTag: 'ringtone',
        );
      });
    } catch (e) {
      ZegoLoggerService.logInfo(
        'audioPlayer stop error:$e',
        tag: 'call',
        subTag: 'ringtone',
      );
    }
  }
}
