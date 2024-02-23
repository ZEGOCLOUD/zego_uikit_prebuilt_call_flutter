// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCallBeautyEffectButton extends StatefulWidget {
  const ZegoCallBeautyEffectButton({
    Key? key,
    this.iconSize,
    this.buttonSize,
    this.icon,
    required this.rootNavigator,
  }) : super(key: key);

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;

  final bool rootNavigator;

  @override
  State<StatefulWidget> createState() => _ZegoCallBeautyEffectButtonState();
}

class _ZegoCallBeautyEffectButtonState
    extends State<ZegoCallBeautyEffectButton> {
  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);
    return GestureDetector(
      onTap: () {
        if (ZegoUIKit().getPlugin(ZegoUIKitPluginType.beauty) != null) {
          ZegoUIKit.instance.getBeautyPlugin().showBeautyUI(context);
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              const Color(0xff2C2F3E).withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              ZegoCallImage.asset(
                ZegoCallIconUrls.toolbarBeautyEffect,
              ),
        ),
      ),
    );
  }
}
