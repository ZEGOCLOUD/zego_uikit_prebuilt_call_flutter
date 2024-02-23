// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
class ZegoCallMinimizingButton extends StatefulWidget {
  const ZegoCallMinimizingButton({
    Key? key,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.rootNavigator = false,
  }) : super(key: key);

  final bool rootNavigator;

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoCallMinimizingButton> createState() =>
      _ZegoCallMinimizingButtonState();
}

/// @nodoc
class _ZegoCallMinimizingButtonState extends State<ZegoCallMinimizingButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: () {
        if (!ZegoUIKitPrebuiltCallController().minimize.minimize(
              context,
              rootNavigator: widget.rootNavigator,
            )) {
          return;
        }

        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              ZegoUIKitDefaultTheme.buttonBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              ZegoCallImage.asset(ZegoCallIconUrls.minimizing),
        ),
      ),
    );
  }
}
