// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallingTopToolBarButton extends StatelessWidget {
  final String iconURL;
  final VoidCallback? onTap;
  final Widget? icon;
  final double? size;

  const ZegoCallingTopToolBarButton({
    required this.iconURL,
    this.onTap,
    this.icon,
    this.size,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size ?? 44.zW,
        child: icon ?? ZegoCallImage.asset(iconURL),
      ),
    );
  }
}

/// @nodoc
class ZegoInviterCallingTopToolBar extends StatefulWidget {
  const ZegoInviterCallingTopToolBar({
    Key? key,
    required this.pageManager,
    required this.switchButtonConfig,
    required this.invitationType,
  }) : super(key: key);

  final ZegoCallInvitationPageManager pageManager;
  final ZegoCallButtonUIConfig? switchButtonConfig;
  final ZegoCallInvitationType invitationType;

  @override
  State<ZegoInviterCallingTopToolBar> createState() =>
      _ZegoInviterCallingTopToolBarState();
}

/// @nodoc
class _ZegoInviterCallingTopToolBarState
    extends State<ZegoInviterCallingTopToolBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        //test
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
        ),
        padding: EdgeInsets.only(left: 36.zR, right: 36.zR),
        height: 88.zH,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(child: SizedBox()),
            cameraSwitchButton(),
          ],
        ),
      ),
    );
  }

  Widget cameraSwitchButton() {
    if (ZegoCallInvitationType.voiceCall == widget.invitationType) {
      return Container();
    }

    return (widget.switchButtonConfig?.visible ?? false)
        ? ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit()
                .getCameraStateNotifier(ZegoUIKit().getLocalUser().id),
            builder: (context, isCameraOn, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit()
                    .getUseFrontFacingCameraStateNotifier(
                        ZegoUIKit().getLocalUser().id),
                builder: (context, isFrontFacing, _) {
                  return ZegoCallingTopToolBarButton(
                    icon: widget.switchButtonConfig?.icon,
                    size: widget.switchButtonConfig?.size?.width,
                    iconURL: InvitationStyleIconUrls.toolbarTopSwitchCamera,
                    onTap: isCameraOn
                        ? () async {
                            final targetState = !isFrontFacing;
                            await ZegoUIKit()
                                .useFrontFacingCamera(targetState)
                                .then((_) {
                              widget.pageManager.callingConfig
                                  .useFrontCameraWhenJoining = targetState;
                            });
                          }
                        : null,
                  );
                },
              );
            },
          )
        : Container();
  }
}
