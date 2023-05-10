import 'package:flutter/material.dart';

import 'package:zego_uikit/zego_uikit.dart';

Widget durationTimeBoard(
  ValueNotifier<Duration> durationNotifier, {
  double fontSize = 15,
}) {
  return ValueListenableBuilder<Duration>(
    valueListenable: durationNotifier,
    builder: (context, elapsedTime, _) {
      final durationString = durationFormatString(elapsedTime);
      final textStyle = TextStyle(
        color: Colors.white,
        decoration: TextDecoration.none,
        fontSize: fontSize,
      );

      return Text(
        durationString,
        textAlign: TextAlign.center,
        style: textStyle,
      );
    },
  );
}

String durationFormatString(Duration elapsedTime) {
  final hours = elapsedTime.inHours;
  final minutes = elapsedTime.inMinutes.remainder(60);
  final seconds = elapsedTime.inSeconds.remainder(60);

  final minutesFormatString =
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return hours > 0
      ? '${hours.toString().padLeft(2, '0')}:$minutesFormatString'
      : minutesFormatString;
}
