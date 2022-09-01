// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class ZegoNotificationRing {
  bool isRingTimerRunning = false;
  var audioPlayer = AudioPlayer();

  ZegoNotificationRing() {
    AudioCache.instance.prefix = 'packages/zego_uikit_prebuilt_call/assets/';
  }

  void startRing() async {
    if (isRingTimerRunning) {
      debugPrint('ring is running');
      return;
    }

    debugPrint('start ring');

    isRingTimerRunning = true;

    await audioPlayer.play(AssetSource('audio/CallRing.wav'));
    Vibrate.vibrate();

    Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      // debugPrint('ring timer periodic');
      if (!isRingTimerRunning) {
        debugPrint('ring timer ended');

        audioPlayer.stop();

        timer.cancel();
      } else {
        Vibrate.vibrate();
      }
    });
  }

  void stopRing() async {
    debugPrint('stop ring');

    isRingTimerRunning = false;

    audioPlayer.stop();
  }
}
