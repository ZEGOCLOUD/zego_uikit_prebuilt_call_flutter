// Dart imports:
import 'dart:async';

// Package imports:
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// Flutter imports:

/// @nodoc
class ZegoRingtone {
  bool isRingTimerRunning = false;
  bool isRingtoneRunning = false;
  var audioPlayer = AudioPlayer();

  bool isVibrate = true;
  String packageName = '';
  String sourcePath = '';

  ZegoRingtone();

  void init({
    required String packageName,
    required String sourcePath,
    required bool isVibrate,
    required bool skipSilent,
  }) {
    ZegoLoggerService.logInfo(
      'init: packageName:$packageName, source path:$sourcePath',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    this.packageName = packageName;
    this.sourcePath = sourcePath;
    this.isVibrate = isVibrate;

    audioPlayer
        .setAudioSource(
      AudioSource.asset(
        sourcePath,
        package: packageName,
      ),
    )
        .then(
      (_) async {
        await audioPlayer.setSkipSilenceEnabled(skipSilent);
        await audioPlayer.setLoopMode(LoopMode.one);
      },
    );
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
      'start ring, '
      'packageName:$packageName, '
      'source path:$sourcePath, '
      'isPlayByRingtone:$isPlayByRingtone, ',
      tag: 'call-invitation',
      subTag: 'ringtone',
    );

    if (isPlayByRingtone) {
      isRingtoneRunning = true;
      FlutterRingtonePlayer().play(
        volume: 0.3,
        fromAsset: 'packages/$packageName/$sourcePath',
      );
    } else {
      try {
        await audioPlayer.play().then((value) {
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

    isRingTimerRunning = false;

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
    }
  }
}
