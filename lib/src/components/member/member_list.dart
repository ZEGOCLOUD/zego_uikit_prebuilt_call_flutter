// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/icon_defines.dart';

class ZegoCallMemberList extends StatefulWidget {
  const ZegoCallMemberList({
    Key? key,
    this.showMicrophoneState = true,
    this.showCameraState = true,
  }) : super(key: key);

  final bool showMicrophoneState;
  final bool showCameraState;

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
    return Column(
      children: [
        header(98.h),
        ZegoMemberList(itemBuilder: itemBuilder),
      ],
    );
  }

  Widget header(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 70.r,
              height: 70.r,
              child: PrebuiltCallImage.asset(PrebuiltCallIconUrls.back),
            ),
          ),
          SizedBox(width: 10.r),
          Text(
            "Member",
            style: TextStyle(
              fontSize: 36.0.r,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }

  Widget itemBuilder(
      BuildContext context, Size size, ZegoUIKitUser user, Map extraInfo) {
    var userName = ZegoUIKit().getLocalUser().id == user.id
        ? "${user.name} "
            "(You)"
        : user.name;

    return Container(
      margin: EdgeInsets.only(bottom: 36.r),
      child: Row(
        children: [
          SizedBox(width: 36.r),
          memberListNameIcon(user.name),
          SizedBox(width: 20.r),
          memberListItemUserName(userName),
          const Expanded(child: SizedBox()),
          widget.showCameraState
              ? ZegoCameraStateIcon(
                  targetUser: user,
                  iconCameraOn: PrebuiltCallImage.asset(
                      PrebuiltCallIconUrls.memberCameraNormal),
                  iconCameraOff: PrebuiltCallImage.asset(
                      PrebuiltCallIconUrls.memberCameraOff),
                )
              : Container(),
          widget.showMicrophoneState
              ? ZegoMicrophoneStateIcon(
                  targetUser: user,
                  iconMicrophoneOn: PrebuiltCallImage.asset(
                      PrebuiltCallIconUrls.memberMicNormal),
                  iconMicrophoneOff: PrebuiltCallImage.asset(
                      PrebuiltCallIconUrls.memberMicOff),
                  iconMicrophoneSpeaking: PrebuiltCallImage.asset(
                      PrebuiltCallIconUrls.memberMicSpeaking))
              : Container(),
          SizedBox(width: 34.r)
        ],
      ),
    );
  }
}

void showMemberListSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: const Color(0xff242736).withOpacity(0.95),
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.7,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            height: 1142.h,
            child: const ZegoCallMemberList(),
          ),
        ),
      );
    },
  );
}
