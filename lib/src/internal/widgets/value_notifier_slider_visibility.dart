// Flutter imports:
import 'package:flutter/cupertino.dart';

class ValueNotifierSliderVisibility extends StatefulWidget {
  const ValueNotifierSliderVisibility({
    Key? key,
    required this.child,
    required this.visibilityNotifier,
    this.animationDuration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0.0, 0.0),
    this.endOffset = const Offset(0.0, 2.0),
  }) : super(key: key);

  final ValueNotifier<bool> visibilityNotifier;
  final Widget child;
  final Duration animationDuration;
  final Offset beginOffset;
  final Offset endOffset;

  @override
  State<ValueNotifierSliderVisibility> createState() =>
      _ValueNotifierSliderVisibilityState();
}

class _ValueNotifierSliderVisibilityState
    extends State<ValueNotifierSliderVisibility>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    widget.visibilityNotifier.addListener(onVisibilityNotify);

    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _animation = Tween(begin: widget.beginOffset, end: widget.endOffset)
        .animate(_controller);
  }

  @override
  void dispose() {
    widget.visibilityNotifier.removeListener(onVisibilityNotify);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }

  void onVisibilityNotify() {
    var visibility = widget.visibilityNotifier.value;
    visibility ? _controller.reverse() : _controller.forward();
  }
}
