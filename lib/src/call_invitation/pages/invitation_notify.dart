// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

// Project imports:

typedef AvatarBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

/// top sheet, popup when invitee receive a invitation
class ZegoCallInvitationDialog extends StatefulWidget {
  const ZegoCallInvitationDialog({
    Key? key,
    required this.invitationData,
    this.showDeclineButton = true,
    this.avatarBuilder,
  }) : super(key: key);

  final bool showDeclineButton;
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
              userName(),
              SizedBox(height: 7.h),
              subtitle(),
            ],
          ),
          const Expanded(child: SizedBox()),
          ...(widget.showDeclineButton
              ? [
                  declineButton(),
                  SizedBox(width: 40.w),
                ]
              : []),
          acceptButton(),
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

  Widget userName() {
    return SizedBox(
      width: 350.w,
      child: Text(
        (ZegoCallType.videoCall == widget.invitationData.type
                ? ((widget.invitationData.invitees.length > 1
                        ? ZegoInvitationPageManager.instance.innerText
                            ?.incomingGroupVideoCallDialogTitle
                        : ZegoInvitationPageManager.instance.innerText
                            ?.incomingVideoCallDialogTitle) ??
                    param_1)
                : ((widget.invitationData.invitees.length > 1
                        ? ZegoInvitationPageManager.instance.innerText
                            ?.incomingGroupVoiceCallDialogTitle
                        : ZegoInvitationPageManager.instance.innerText
                            ?.incomingVoiceCallDialogTitle) ??
                    param_1))
            .replaceFirst(param_1, widget.invitationData.inviter?.name ?? ""),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.white,
          fontSize: 36.0.r,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget subtitle() {
    return SizedBox(
      width: 360.w,
      child: Text(
        invitationTypeString(
          widget.invitationData.type,
          widget.invitationData.invitees,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0.r,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget declineButton() {
    return Listener(
      onPointerDown: (e) {
        ZegoInvitationPageManager.instance.hideInvitationTopSheet();
      },
      child: AbsorbPointer(
        absorbing: false,
        child: ZegoRefuseInvitationButton(
          inviterID: widget.invitationData.inviter?.id ?? "",
          // customization is not supported
          data: '{"reason":"decline"}',
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
          onPressed: (String code, String message) {
            ZegoInvitationPageManager.instance
                .onLocalRefuseInvitation(code, message);
          },
        ),
      ),
    );
  }

  Widget acceptButton() {
    return Listener(
      onPointerDown: (e) {
        ZegoInvitationPageManager.instance.hideInvitationTopSheet();
      },
      child: AbsorbPointer(
        absorbing: false,
        child: ZegoAcceptInvitationButton(
          inviterID: widget.invitationData.inviter?.id ?? "",
          icon: ButtonIcon(
            icon: Image(
              image: PrebuiltCallImage.asset(
                      imageURLByInvitationType(widget.invitationData.type))
                  .image,
              fit: BoxFit.fill,
            ),
          ),
          iconSize: Size(74.r, 74.r),
          buttonSize: Size(74.r, 74.r),
          onPressed: (String code, String message) {
            ZegoInvitationPageManager.instance
                .onLocalAcceptInvitation(code, message);
          },
        ),
      ),
    );
  }

  String imageURLByInvitationType(ZegoCallType invitationType) {
    switch (invitationType) {
      case ZegoCallType.voiceCall:
        return InvitationStyleIconUrls.inviteVoice;
      case ZegoCallType.videoCall:
        return InvitationStyleIconUrls.inviteVideo;
    }
  }

  String invitationTypeString(
      ZegoCallType invitationType, List<ZegoUIKitUser> invitees) {
    switch (invitationType) {
      case ZegoCallType.voiceCall:
        return invitees.length > 1
            ? (ZegoInvitationPageManager
                    .instance.innerText?.incomingGroupVoiceCallDialogMessage ??
                "Incoming group voice call...")
            : (ZegoInvitationPageManager
                    .instance.innerText?.incomingVoiceCallDialogMessage ??
                "Incoming voice call...");
      case ZegoCallType.videoCall:
        return invitees.length > 1
            ? (ZegoInvitationPageManager
                    .instance.innerText?.incomingGroupVideoCallDialogMessage ??
                "Incoming group video call...")
            : (ZegoInvitationPageManager
                    .instance.innerText?.incomingVideoCallDialogMessage ??
                "Incoming video call...");
    }
  }
}
