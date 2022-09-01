// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/icon_defines.dart';

class ZegoCallMemberList extends StatefulWidget {
  const ZegoCallMemberList({Key? key}) : super(key: key);

  @override
  State<ZegoCallMemberList> createState() => _ZegoCallMemberListState();
}

class _ZegoCallMemberListState extends State<ZegoCallMemberList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZegoMemberList(itemBuilder: itemBuilder);
  }

  Widget itemBuilder(
      BuildContext context, Size size, ZegoUIKitUser user, Map extraInfo) {
    return Container(
      margin: EdgeInsets.only(bottom: 36.r),
      child: Row(
        children: [
          SizedBox(width: 36.r),
          memberListNameIcon(user.name),
          SizedBox(width: 20.r),
          memberListItemUserName(user.name),
          const Expanded(child: SizedBox()),
          ZegoCameraStateIcon(
            targetUser: user,
            iconCameraOn: PrebuiltCallImage.asset(
                InvitationStyleIconUrls.memberCameraNormal),
            iconCameraOff: PrebuiltCallImage.asset(
                InvitationStyleIconUrls.memberCameraOff),
          ),
          ZegoMicrophoneStateIcon(
              targetUser: user,
              iconMicrophoneOn: PrebuiltCallImage.asset(
                  InvitationStyleIconUrls.memberMicNormal),
              iconMicrophoneOff:
                  PrebuiltCallImage.asset(InvitationStyleIconUrls.memberMicOff),
              iconMicrophoneSpeaking: PrebuiltCallImage.asset(
                  InvitationStyleIconUrls.memberMicSpeaking)),
          SizedBox(width: 34.r)
        ],
      ),
    );
  }
}

void showMemberList(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: const Color(0xff222222).withOpacity(0.8),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    builder: (BuildContext context) {
      return AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets,
        duration: const Duration(milliseconds: 50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          height: 1142.h,
          child: const ZegoCallMemberList(),
        ),
      );
    },
  );
}
