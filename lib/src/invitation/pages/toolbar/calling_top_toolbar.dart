// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';

/// @nodoc
class ZegoCallingTopToolBarButton extends StatelessWidget {
  final String iconURL;
  final VoidCallback onTap;

  const ZegoCallingTopToolBarButton(
      {required this.iconURL, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44.zW,
        child: ZegoCallImage.asset(iconURL),
      ),
    );
  }
}

/// @nodoc
class ZegoInviterCallingVideoTopToolBar extends StatelessWidget {
  const ZegoInviterCallingVideoTopToolBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        //test
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
        ),
        padding: EdgeInsets.only(left: 36.zR, right: 36.zR),
        height: 88.zH,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(child: SizedBox()),
            ValueListenableBuilder<bool>(
              valueListenable: ZegoUIKit().getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id),
              builder: (context, isFrontFacing, _) {
                return ZegoCallingTopToolBarButton(
                  iconURL: InvitationStyleIconUrls.toolbarTopSwitchCamera,
                  onTap: () {
                    ZegoUIKit().useFrontFacingCamera(!isFrontFacing);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
