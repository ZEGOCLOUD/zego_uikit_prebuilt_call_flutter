// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import '../../internal/internal.dart';

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
        width: 44.w,
        child: PrebuiltCallImage.asset(iconURL),
      ),
    );
  }
}

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
        padding: EdgeInsets.only(left: 36.r, right: 36.r),
        height: 88.h,
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
