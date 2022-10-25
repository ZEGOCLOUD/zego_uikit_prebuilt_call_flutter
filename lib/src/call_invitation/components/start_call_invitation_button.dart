// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoStartCallInvitationButton extends StatefulWidget {
  final List<ZegoUIKitUser> invitees;
  final bool isVideoCall;
  final String customData;

  final Size? buttonSize;
  final ButtonIcon? icon;
  final Size? iconSize;
  final String? text;
  final TextStyle? textStyle;
  final double? iconTextSpacing;
  final bool verticalLayout;

  final int timeoutSeconds;

  ///  You can do what you want after pressed.
  final void Function(String code, String message, List<String>)? onPressed;
  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  const ZegoStartCallInvitationButton({
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
    this.customData = '',
  }) : super(key: key);

  @override
  State<ZegoStartCallInvitationButton> createState() =>
      _ZegoStartCallInvitationButtonState();
}

class _ZegoStartCallInvitationButtonState
    extends State<ZegoStartCallInvitationButton> {
  bool requesting = false;
  var callIDNotifier = ValueNotifier<String>("");

  @override
  void initState() {
    super.initState();

    updateCallID();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<String>(
          valueListenable: callIDNotifier,
          builder: (context, callID, _) {
            return button();
          },
        );
      },
    );
  }

  void updateCallID() {
    callIDNotifier.value =
        'call_${ZegoUIKit().getLocalUser().id}_${DateTime.now().millisecondsSinceEpoch}';
    debugPrint("update call id, ${callIDNotifier.value}");
  }

  Widget button() {
    return ZegoStartInvitationButton(
      invitationType: ZegoInvitationTypeExtension(widget.isVideoCall
              ? ZegoInvitationType.videoCall
              : ZegoInvitationType.voiceCall)
          .value,
      invitees: widget.invitees.map((user) {
        return user.id;
      }).toList(),
      data: InvitationInternalData(callIDNotifier.value,
              List.from(widget.invitees), widget.customData)
          .toJson(),
      icon: widget.icon ??
          ButtonIcon(
            icon: widget.isVideoCall
                ? PrebuiltCallImage.asset(InvitationStyleIconUrls.inviteVideo)
                : PrebuiltCallImage.asset(InvitationStyleIconUrls.inviteVoice),
          ),
      iconSize: widget.iconSize,
      text: widget.text,
      textStyle: widget.textStyle,
      iconTextSpacing: widget.iconTextSpacing,
      verticalLayout: widget.verticalLayout,
      buttonSize: widget.buttonSize,
      timeoutSeconds: widget.timeoutSeconds,
      onWillPressed: () {
        if (requesting) {
          debugPrint("still in request");
          return false;
        }

        var currentState = ZegoInvitationPageManager
                .instance.callingMachine.machine.current?.identifier ??
            CallingState.kIdle;
        if (CallingState.kIdle != currentState) {
          debugPrint("still in calling, $currentState");
          return false;
        }

        requesting = true;
        debugPrint("start request");

        return true;
      },
      onPressed: onPressed,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  void onPressed(String code, String message, List<String> errorInvitees) {
    ZegoInvitationPageManager.instance.onLocalSendInvitation(
      callIDNotifier.value,
      List.from(widget.invitees),
      widget.isVideoCall
          ? ZegoInvitationType.videoCall
          : ZegoInvitationType.voiceCall,
      code,
      message,
      errorInvitees,
    );

    if (widget.onPressed != null) {
      widget.onPressed!(code, message, errorInvitees);
    }

    updateCallID();

    requesting = false;
    debugPrint("finish request");
  }
}
