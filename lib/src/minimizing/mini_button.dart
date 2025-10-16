// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallMinimizingButton extends StatefulWidget {
  const ZegoCallMinimizingButton({
    super.key,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.rootNavigator = false,
    // New parameters: related to inviting minimization
    this.invitationType,
    this.inviter,
    this.invitees,
    this.isInviter,
    this.pageManager,
    this.callInvitationData,
    this.customData,
  });

  final bool rootNavigator;

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  // New parameters: related to inviting minimization
  final ZegoCallInvitationType? invitationType;
  final ZegoUIKitUser? inviter;
  final List<ZegoUIKitUser>? invitees;
  final bool? isInviter;
  final ZegoCallInvitationPageManager? pageManager;
  final ZegoUIKitPrebuiltCallInvitationData? callInvitationData;
  final String? customData;

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
    return GestureDetector(
      onTap: () {
        bool success = false;
        if (widget.invitationType != null &&
            widget.inviter != null &&
            widget.invitees != null &&
            widget.isInviter != null &&
            widget.pageManager != null &&
            widget.callInvitationData != null) {
          success = ZegoUIKitPrebuiltCallController().minimize.minimizeInviting(
                context,
                rootNavigator: widget.rootNavigator,
                invitationType: widget.invitationType!,
                inviter: widget.inviter!,
                invitees: widget.invitees!,
                isInviter: widget.isInviter!,
                pageManager: widget.pageManager!,
                callInvitationData: widget.callInvitationData!,
                customData: widget.customData,
              );
        } else {
          success = ZegoUIKitPrebuiltCallController().minimize.minimize(
                context,
                rootNavigator: widget.rootNavigator,
              );
        }
        if (!success) {
          return;
        }
        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: widget.buttonSize?.width ?? 96,
        height: widget.buttonSize?.height ?? 96,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              ZegoUIKitDefaultTheme.buttonBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: widget.iconSize ?? Size(56, 56),
          child: widget.icon?.icon ??
              ZegoCallImage.asset(ZegoCallIconUrls.minimizing),
        ),
      ),
    );
  }
}
