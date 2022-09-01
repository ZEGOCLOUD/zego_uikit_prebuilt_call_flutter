// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/icon_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/page_service.dart';

class ZegoInviterCallingBottomToolBar extends StatelessWidget {
  final ZegoUIKitUser callee;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.callee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: ZegoCancelInvitationButton(
          invitee: [callee.id],
          icon: ButtonIcon(
            icon: Image(
              image:
              PrebuiltCallImage.asset(InvitationStyleIconUrls.toolbarBottomCancel)
                      .image,
              fit: BoxFit.fill,
            ),
          ),
          buttonSize: Size(120.r, 120.r),
          iconSize: Size(120.r, 120.r),
          onPressed: () {
            ZegoInvitationPageService.instance.onLocalCancelInvitation();
          },
        ),
      ),
    );
  }
}

class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final ZegoUIKitUser invitee;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.inviter,
    required this.invitee,
    required this.invitationType,
  }) : super(key: key);

  @override
  State<ZegoInviteeCallingBottomToolBar> createState() {
    return ZegoInviteeCallingBottomToolBarState();
  }
}

class ZegoInviteeCallingBottomToolBarState
    extends State<ZegoInviteeCallingBottomToolBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZegoRefuseInvitationButton(
              inviterID: widget.inviter.id,
              text: "Decline",
              icon: ButtonIcon(
                icon: Image(
                  image: PrebuiltCallImage.asset(
                          InvitationStyleIconUrls.toolbarBottomDecline)
                      .image,
                  fit: BoxFit.fill,
                ),
              ),
              buttonSize: Size(120.r, 120.r + 50.r),
              iconSize: Size(120.r, 120.r),
              onPressed: () {
                ZegoInvitationPageService.instance.onLocalRefuseInvitation();
              },
            ),
            SizedBox(width: 230.r),
            ZegoAcceptInvitationButton(
              inviterID: widget.inviter.id,
              icon: ButtonIcon(
                icon: Image(
                  image: PrebuiltCallImage.asset(
                          imageURLByInvitationType(widget.invitationType))
                      .image,
                  fit: BoxFit.fill,
                ),
              ),
              text: "Accept",
              buttonSize: Size(120.r, 120.r + 50.r),
              iconSize: Size(120.r, 120.r),
              onPressed: () {
                ZegoInvitationPageService.instance.onLocalAcceptInvitation();
              },
            ),
          ],
        ),
      ),
    );
  }

  String imageURLByInvitationType(ZegoInvitationType invitationType) {
    switch (invitationType) {
      case ZegoInvitationType.voiceCall:
        return InvitationStyleIconUrls.toolbarBottomVoice;
      case ZegoInvitationType.videoCall:
        return InvitationStyleIconUrls.toolbarBottomVideo;
    }
  }
}
