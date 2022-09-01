// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/icon_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/page_service.dart';

class ZegoStartCallCallInvitation extends StatefulWidget {
  final List<ZegoUIKitUser> invitees;
  final bool isVideoCall;

  final Size? buttonSize;
  final ButtonIcon? icon;
  final Size? iconSize;
  final String? text;
  final TextStyle? textStyle;
  final double? iconTextSpacing;
  final bool verticalLayout;

  final int timeoutSeconds;

  ///  You can do what you want after clicked.
  final void Function(bool)? onPressed;
  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  const ZegoStartCallCallInvitation({
    Key? key,
    required this.invitees,
    required this.isVideoCall,
    this.buttonSize,
    this.icon,
    this.iconSize,
    this.text,
    this.textStyle,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.timeoutSeconds = 60,
    this.onPressed,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<ZegoStartCallCallInvitation> createState() =>
      _ZegoStartCallCallInvitationState();
}

class _ZegoStartCallCallInvitationState
    extends State<ZegoStartCallCallInvitation> {
  String? callID;

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
    callID = 'call_${ZegoUIKit().getLocalUser().id}';
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ZegoStartInvitationButton(
          invitationType: ZegoInvitationTypeExtension(widget.isVideoCall
                  ? ZegoInvitationType.videoCall
                  : ZegoInvitationType.voiceCall)
              .value,
          invitees: widget.invitees.map((user) {
            return user.id;
          }).toList(),
          data: InvitationInternalData(callID!, widget.invitees).toJson(),
          icon: widget.icon ??
              ButtonIcon(
                icon: widget.isVideoCall
                    ? PrebuiltCallImage.asset(
                        InvitationStyleIconUrls.inviteVideo)
                    : PrebuiltCallImage.asset(
                        InvitationStyleIconUrls.inviteVoice),
              ),
          iconSize: widget.iconSize,
          text: widget.text,
          textStyle: widget.textStyle,
          iconTextSpacing: widget.iconTextSpacing,
          verticalLayout: widget.verticalLayout,
          buttonSize: widget.buttonSize,
          timeoutSeconds: widget.timeoutSeconds,
          onPressed: onPressed,
          clickableTextColor: widget.clickableTextColor,
          unclickableTextColor: widget.unclickableTextColor,
          clickableBackgroundColor: widget.clickableBackgroundColor,
          unclickableBackgroundColor: widget.unclickableBackgroundColor,
        );
      },
    );
  }

  void onPressed(bool result) {
    ZegoInvitationPageService.instance.onLocalSendInvitation(
      result,
      callID!,
      widget.invitees,
      widget.isVideoCall
          ? ZegoInvitationType.videoCall
          : ZegoInvitationType.voiceCall,
    );

    if (widget.onPressed != null) {
      widget.onPressed!(result);
    }
  }
}
