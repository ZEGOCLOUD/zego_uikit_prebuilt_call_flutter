// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil_zego/flutter_screenutil_zego.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/prebuilt_data.dart';

class ZegoUIKitPrebuiltCallMinimizingButton extends StatefulWidget {
  const ZegoUIKitPrebuiltCallMinimizingButton({
    Key? key,
    required this.prebuiltCallData,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final ZegoUIKitPrebuiltCallData prebuiltCallData;

  @override
  State<ZegoUIKitPrebuiltCallMinimizingButton> createState() =>
      _ZegoUIKitPrebuiltCallMinimizingButtonState();
}

class _ZegoUIKitPrebuiltCallMinimizingButtonState
    extends State<ZegoUIKitPrebuiltCallMinimizingButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    final sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    return GestureDetector(
      onTap: () {
        if (PrebuiltCallMiniOverlayPageState.minimizing ==
            ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
          ZegoLoggerService.logInfo(
            'is minimizing, ignore',
            tag: 'call',
            subTag: 'overlay button',
          );

          return;
        }

        ZegoUIKitPrebuiltCallMiniOverlayMachine().changeState(
          PrebuiltCallMiniOverlayPageState.minimizing,
          prebuiltCallData: widget.prebuiltCallData,
        );

        Navigator.of(context).pop();

        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              PrebuiltCallImage.asset(PrebuiltCallIconUrls.minimizing),
        ),
      ),
    );
  }
}
