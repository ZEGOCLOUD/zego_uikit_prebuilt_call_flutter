// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'toolbar/calling_bottom_toolbar.dart';
import 'toolbar/calling_top_toolbar.dart';

typedef AvatarBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

class ZegoCallingInviterView extends StatelessWidget {
  const ZegoCallingInviterView({
    Key? key,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.avatarBuilder,
  }) : super(key: key);

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoInvitationType invitationType;
  final AvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        backgroundView(),
        surface(context),
      ],
    );
  }

  Widget backgroundView() {
    if (ZegoInvitationType.videoCall == invitationType) {
      return ZegoAudioVideoView(user: inviter);
    }

    return backgroundImage();
  }

  Widget surface(BuildContext context) {
    var isVideo = ZegoInvitationType.videoCall == invitationType;

    var firstInvitee =
        invitees.isNotEmpty ? invitees.first : ZegoUIKitUser.empty();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isVideo ? const ZegoInviterCallingVideoTopToolBar() : Container(),
        isVideo ? SizedBox(height: 140.h) : SizedBox(height: 228.h),
        SizedBox(
          width: 200.r,
          height: 200.r,
          child: avatarBuilder
                  ?.call(context, Size(200.r, 200.r), firstInvitee, {}) ??
              circleAvatar(firstInvitee.name),
        ),
        SizedBox(height: 10.r),
        centralName(firstInvitee.name),
        SizedBox(height: 47.r),
        callingText(),
        const Expanded(child: SizedBox()),
        ZegoInviterCallingBottomToolBar(invitees: invitees),
        SizedBox(height: 105.r),
      ],
    );
  }
}

class ZegoCallingInviteeView extends StatelessWidget {
  const ZegoCallingInviteeView({
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.avatarBuilder,
    Key? key,
  }) : super(key: key);

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoInvitationType invitationType;
  final AvatarBuilder? avatarBuilder;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        backgroundImage(),
        surface(context),
      ],
    );
  }

  Widget surface(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 280.r),
        SizedBox(
          width: 200.r,
          height: 200.r,
          child:
              avatarBuilder?.call(context, Size(200.r, 200.r), inviter, {}) ??
                  circleAvatar(inviter.name),
        ),
        SizedBox(height: 10.r),
        centralName(inviter.name),
        SizedBox(height: 47.r),
        callingText(),
        const Expanded(child: SizedBox()),
        ZegoInviteeCallingBottomToolBar(
          inviter: inviter,
          invitees: invitees,
          invitationType: invitationType,
        ),
        SizedBox(height: 105.r),
      ],
    );
  }
}

Widget backgroundImage() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: PrebuiltCallImage.asset(InvitationStyleIconUrls.inviteBackground)
            .image,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}

Widget centralName(String name) {
  return SizedBox(
    height: 59.h,
    child: Text(
      name,
      style: TextStyle(
        color: Colors.white,
        fontSize: 42.0.r,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget callingText() {
  return Text(
    "Calling…",
    style: TextStyle(
      color: Colors.white,
      fontSize: 32.0.r,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
  );
}

Widget circleAvatar(String name) {
  return Container(
    decoration: const BoxDecoration(
      color: Color(0xffDBDDE3),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name.characters.first : "",
        style: TextStyle(
          fontSize: 96.0.r,
          color: const Color(0xff222222),
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}
