// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/icon_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/page_service.dart';

typedef AvatarBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// top sheet, popup when invitee receive a invitation
class ZegoCallInvitationDialog extends StatefulWidget {
  const ZegoCallInvitationDialog({
    Key? key,
    required this.invitationData,
    this.avatarBuilder,
  }) : super(key: key);

  final ZegoCallInvitationData invitationData;
  final AvatarBuilder? avatarBuilder;

  @override
  ZegoCallInvitationDialogState createState() =>
      ZegoCallInvitationDialogState();
}

class ZegoCallInvitationDialogState extends State<ZegoCallInvitationDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      width: 718.w,
      height: 160.h,
      decoration: BoxDecoration(
        color: const Color(0xff333333).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.avatarBuilder?.call(context, Size(84.r, 84.r),
                  widget.invitationData.inviter, {}) ??
              circleName(widget.invitationData.inviter?.name ?? ""),
          SizedBox(width: 26.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.invitationData.inviter?.name ?? "",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.0.r,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                invitationTypeString(widget.invitationData.type),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0.r,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              )
            ],
          ),
          const Expanded(child: SizedBox()),
          Listener(
            onPointerDown: (e) {
              ZegoInvitationPageService.instance.hideInvitationTopSheet();
            },
            child: AbsorbPointer(
              absorbing: false,
              child: ZegoRefuseInvitationButton(
                inviterID: widget.invitationData.inviter?.id ?? "",
                icon: ButtonIcon(
                  icon: Image(
                    image:
                    PrebuiltCallImage.asset(InvitationStyleIconUrls.inviteReject)
                            .image,
                    fit: BoxFit.fill,
                  ),
                ),
                iconSize: Size(74.r, 74.r),
                buttonSize: Size(74.r, 74.r),
                onPressed: () {
                  ZegoInvitationPageService.instance.onLocalRefuseInvitation();
                },
              ),
            ),
          ),
          SizedBox(width: 40.w),
          Listener(
            onPointerDown: (e) {
              ZegoInvitationPageService.instance.hideInvitationTopSheet();
            },
            child: AbsorbPointer(
              absorbing: false,
              child: ZegoAcceptInvitationButton(
                inviterID: widget.invitationData.inviter?.id ?? "",
                icon: ButtonIcon(
                  icon: Image(
                    image: PrebuiltCallImage.asset(imageURLByInvitationType(
                            widget.invitationData.type))
                        .image,
                    fit: BoxFit.fill,
                  ),
                ),
                iconSize: Size(74.r, 74.r),
                buttonSize: Size(74.r, 74.r),
                onPressed: () {
                  ZegoInvitationPageService.instance.onLocalAcceptInvitation();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget circleName(String name) {
    return Container(
      width: 84.r,
      height: 84.r,
      decoration:
          const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.characters.first : "",
          style: TextStyle(
            fontSize: 60.0.r,
            color: const Color(0xff222222),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  String imageURLByInvitationType(ZegoInvitationType invitationType) {
    switch (invitationType) {
      case ZegoInvitationType.voiceCall:
        return InvitationStyleIconUrls.inviteVoice;
      case ZegoInvitationType.videoCall:
        return InvitationStyleIconUrls.inviteVideo;
    }
  }

  String invitationTypeString(ZegoInvitationType invitationType) {
    switch (invitationType) {
      case ZegoInvitationType.voiceCall:
        return "Zego Voice Call";
      case ZegoInvitationType.videoCall:
        return "Zego Video Call";
    }
  }
}
