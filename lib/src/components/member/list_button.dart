// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/components/member/list_sheet.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';

/// @nodoc
class ZegoCallMemberListButton extends StatefulWidget {
  const ZegoCallMemberListButton({
    Key? key,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.config,
    this.avatarBuilder,
    this.rootNavigator = false,
  }) : super(key: key);

  final ZegoAvatarBuilder? avatarBuilder;

  final bool rootNavigator;

  final ZegoCallMemberListConfig? config;

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoCallMemberListButton> createState() =>
      _ZegoCallMemberListButtonState();
}

/// @nodoc
class _ZegoCallMemberListButtonState extends State<ZegoCallMemberListButton> {
  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: () {
        showMemberListSheet(
          context,
          showCameraState: widget.config?.showCameraState ?? true,
          showMicrophoneState: widget.config?.showMicrophoneState ?? true,
          itemBuilder: widget.config?.itemBuilder,
          avatarBuilder: widget.avatarBuilder,
          rootNavigator: widget.rootNavigator,
        );

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
              ZegoCallImage.asset(ZegoCallIconUrls.topMemberNormal),
        ),
      ),
    );
  }
}
