// Flutter imports:
import 'package:flutter/material.dart';

/// @nodoc
class ZegoCallDurationTimeBoard extends StatefulWidget {
  final ValueNotifier<Duration> durationNotifier;
  final double fontSize;

  const ZegoCallDurationTimeBoard({
    Key? key,
    required this.durationNotifier,
    this.fontSize = 15,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ZegoCallDurationTimeBoardState();
}

class _ZegoCallDurationTimeBoardState extends State<ZegoCallDurationTimeBoard> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: widget.durationNotifier,
      builder: (context, elapsedTime, _) {
        final durationString = durationFormatString(elapsedTime);
        final textStyle = TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontSize: widget.fontSize,
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
}
