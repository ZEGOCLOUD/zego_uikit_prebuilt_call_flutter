// Dart imports:
import 'dart:async';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Flutter imports:

class ZegoRingtone {
  bool isRingTimerRunning = false;
  var audioPlayer = AudioPlayer();

  bool isVibrate = true;
  String sourcePath = "";

  ZegoRingtone();

  void init({
    required String prefix,
    required String sourcePath,
    required bool isVibrate,
  }) {
    ZegoLoggerService.logInfo(
      'init: prefix:$prefix, source path:$sourcePath',
      tag: "call",
      subTag: "ringtone",
    );

    AudioCache.instance.prefix = prefix;

    this.sourcePath = sourcePath;
    this.isVibrate = isVibrate;

    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        defaultToSpeaker: true,
        category: AVAudioSessionCategory.ambient,
        options: [
          AVAudioSessionOptions.defaultToSpeaker,
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
    AudioPlayer.global.setGlobalAudioContext(audioContext);
  }

  void startRing() async {
    if (isRingTimerRunning) {
      ZegoLoggerService.logInfo(
        'ring is running',
        tag: "call",
        subTag: "ringtone",
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'start ring, source path:$sourcePath',
      tag: "call",
      subTag: "ringtone",
    );

    isRingTimerRunning = true;

    audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource(sourcePath));
    if (isVibrate) {
      Vibrate.vibrate();
    }

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      if (!isRingTimerRunning) {
        ZegoLoggerService.logInfo(
          'ring timer ended',
          tag: "call",
          subTag: "ringtone",
        );

        audioPlayer.stop();

        timer.cancel();
      } else {
        if (isVibrate) {
          Vibrate.vibrate();
        }
      }
    });
  }

  void stopRing() async {
    ZegoLoggerService.logInfo(
      'stop ring',
      tag: "call",
      subTag: "ringtone",
    );

    isRingTimerRunning = false;

    audioPlayer.stop();
  }
}
