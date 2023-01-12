// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoInviterCallingBottomToolBar extends StatelessWidget {
  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.invitees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: Center(
        child: ZegoCancelInvitationButton(
          invitees: invitees.map((e) => e.id).toList(),
          icon: ButtonIcon(
            icon: Image(
              image: PrebuiltCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomCancel)
                  .image,
              fit: BoxFit.fill,
            ),
          ),
          buttonSize: Size(120.r, 120.r),
          iconSize: Size(120.r, 120.r),
          onPressed: (String code, String message, List<String> errorInvitees) {
            ZegoInvitationPageManager.instance
                .onLocalCancelInvitation(code, message, errorInvitees);
          },
        ),
      ),
    );
  }
}

class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoCallType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final bool showDeclineButton;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.showDeclineButton = true,
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
            ...(widget.showDeclineButton
                ? [
                    declineButton(),
                    SizedBox(width: 230.r),
                  ]
                : []),
            acceptButton(),
          ],
        ),
      ),
    );
  }

  Widget declineButton() {
    return ZegoRefuseInvitationButton(
      inviterID: widget.inviter.id,
      // data customization is not supported
      data: '{"reason":"decline"}',
      text: (ZegoInvitationPageManager
              .instance.innerText?.incomingCallPageDeclineButton ??
          "Decline"),
      textStyle: buttonTextStyle(),
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
      onPressed: (String code, String message) {
        ZegoInvitationPageManager.instance
            .onLocalRefuseInvitation(code, message);
      },
    );
  }

  Widget acceptButton() {
    return ZegoAcceptInvitationButton(
      inviterID: widget.inviter.id,
      icon: ButtonIcon(
        icon: Image(
          image: PrebuiltCallImage.asset(
                  imageURLByInvitationType(widget.invitationType))
              .image,
          fit: BoxFit.fill,
        ),
      ),
      text: (ZegoInvitationPageManager
              .instance.innerText?.incomingCallPageAcceptButton ??
          "Accept"),
      textStyle: buttonTextStyle(),
      buttonSize: Size(120.r, 120.r + 50.r),
      iconSize: Size(120.r, 120.r),
      onPressed: (String code, String message) {
        ZegoInvitationPageManager.instance
            .onLocalAcceptInvitation(code, message);
      },
    );
  }

  TextStyle buttonTextStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 25.0.r,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    );
  }

  String imageURLByInvitationType(ZegoCallType invitationType) {
    switch (invitationType) {
      case ZegoCallType.voiceCall:
        return InvitationStyleIconUrls.toolbarBottomVoice;
      case ZegoCallType.videoCall:
        return InvitationStyleIconUrls.toolbarBottomVideo;
    }
  }
}
