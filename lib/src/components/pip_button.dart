// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
class ZegoCallPIPButton extends StatefulWidget {
  const ZegoCallPIPButton({
    Key? key,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.aspectWidth = 9,
    this.aspectHeight = 16,
  }) : super(key: key);

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final int aspectWidth;
  final int aspectHeight;

  @override
  State<ZegoCallPIPButton> createState() => _ZegoCallPIPButtonState();
}

/// @nodoc
class _ZegoCallPIPButtonState extends State<ZegoCallPIPButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: () async {
        final pipStatus = await ZegoUIKitPrebuiltCallController().pip.enable(
              aspectWidth: widget.aspectWidth,
              aspectHeight: widget.aspectHeight,
            );
        if (ZegoPiPStatus.enabled != pipStatus) {
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
          child: widget.icon?.icon ?? ZegoCallImage.asset(ZegoCallIconUrls.pip),
        ),
      ),
    );
  }
}
