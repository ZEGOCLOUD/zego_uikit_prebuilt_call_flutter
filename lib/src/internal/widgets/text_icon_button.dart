// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

/// text button
/// icon button
/// text+icon button
class ZegoTextIconButton extends StatefulWidget {
  final String? text;

  final ButtonIcon? icon;
  final Size? iconSize;
  final double? iconTextSpacing;

  final Size? buttonSize;
  final VoidCallback? onPressed;

  final bool verticalLayout;

  const ZegoTextIconButton({
    Key? key,
    this.text,
    this.icon,
    this.iconTextSpacing,
    this.iconSize,
    this.buttonSize,
    this.onPressed,
    this.verticalLayout = true,
  }) : super(key: key);

  @override
  State<ZegoTextIconButton> createState() => _ZegoTextIconButtonState();
}

class _ZegoTextIconButtonState extends State<ZegoTextIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: widget.verticalLayout
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children(context),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children(context),
            ),
    );
  }

  List<Widget> children(BuildContext context) {
    return [
      iconWidget(),
      ...text(),
    ];
  }

  Widget iconWidget() {
    if (widget.icon == null) {
      return Container();
    }

    return Container(
      width: widget.buttonSize?.width ?? 120.r,
      height: widget.buttonSize?.width ?? 120.r,
      decoration: BoxDecoration(
        color: widget.icon?.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.all(
            Radius.circular(widget.buttonSize?.width ?? 120.r / 2)),
      ),
      child: SizedBox(
        width: widget.iconSize?.width ?? 74.r,
        height: widget.iconSize?.height ?? 74.r,
        child: widget.icon?.icon,
      ),
    );
  }

  List<Widget> text() {
    if (widget.text == null || widget.text!.isEmpty) {
      return [];
    }

    return [
      SizedBox(height: widget.iconTextSpacing ?? 12.r),
      Text(
        widget.text!,
        style: TextStyle(
          color: Colors.white,
          fontSize: 26.r,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      ),
    ];
  }

  void onPressed() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }
}
