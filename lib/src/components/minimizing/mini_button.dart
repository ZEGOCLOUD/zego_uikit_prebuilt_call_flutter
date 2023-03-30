// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/components/minimizing/mini_overlay_machine.dart';

import 'package:zego_uikit_prebuilt_call/src/components/prebuilt_data.dart';

class ZegoMinimizingButton extends StatefulWidget {
  const ZegoMinimizingButton({
    Key? key,
    required this.prebuiltCallData,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.config,
  }) : super(key: key);

  final ZegoMemberListConfig? config;

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final ZegoUIKitPrebuiltCallData prebuiltCallData;

  @override
  State<ZegoMinimizingButton> createState() => _ZegoMinimizingButtonState();
}

class _ZegoMinimizingButtonState extends State<ZegoMinimizingButton> {
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
        if (MiniOverlayPageState.minimizing ==
            ZegoMiniOverlayMachine().state()) {
          ZegoLoggerService.logInfo(
            'is minimizing, ignore',
            tag: 'call',
            subTag: 'overlay button',
          );

          return;
        }

        ZegoMiniOverlayMachine().changeState(
          MiniOverlayPageState.minimizing,
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
