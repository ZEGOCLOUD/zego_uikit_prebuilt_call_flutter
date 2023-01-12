// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/components/member/member_list_sheet.dart';

/// switch cameras
class ZegoMemberListButton extends StatefulWidget {
  const ZegoMemberListButton({
    Key? key,
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

  @override
  State<ZegoMemberListButton> createState() => _ZegoMemberListButtonState();
}

class _ZegoMemberListButtonState extends State<ZegoMemberListButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    return GestureDetector(
      onTap: () {
        showMemberListSheet(
          context,
          showCameraState: widget.config?.showCameraState ?? true,
          showMicrophoneState: widget.config?.showMicrophoneState ?? true,
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
              const Color(0xff2C2F3E).withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              PrebuiltCallImage.asset(PrebuiltCallIconUrls.topMemberNormal),
        ),
      ),
    );
  }
}
