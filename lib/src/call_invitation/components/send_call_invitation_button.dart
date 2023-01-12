// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoSendCallInvitationButton extends StatefulWidget {
  ///
  final List<ZegoUIKitUser> invitees;

  /// video or audio
  final bool isVideoCall;

  ///
  final String customData;

  ///  You can do what you want after pressed.
  final void Function(String code, String message, List<String>)? onPressed;

  /// notification parameter, specify the sound when play on received notification
  /// which is [Push Resource ID] in 'Zego Console/Projects Management/Customized push resource/Push Resource ID'
  final String? resourceID;

  /// timeout of the call invitation, the unit is seconds
  final int timeoutSeconds;

  /// style
  final Size? buttonSize;
  final ButtonIcon? icon;
  final Size? iconSize;
  final String? text;
  final TextStyle? textStyle;
  final double? iconTextSpacing;
  final bool verticalLayout;
  final Color? clickableTextColor;
  final Color? unclickableTextColor;
  final Color? clickableBackgroundColor;
  final Color? unclickableBackgroundColor;

  const ZegoSendCallInvitationButton({
    Key? key,
    required this.invitees,
    required this.isVideoCall,
    this.customData = '',
    this.onPressed,
    this.resourceID,
    this.buttonSize,
    this.icon,
    this.iconSize,
    this.text,
    this.textStyle,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.timeoutSeconds = 60,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<ZegoSendCallInvitationButton> createState() =>
      _ZegoSendCallInvitationButtonState();
}

class _ZegoSendCallInvitationButtonState
    extends State<ZegoSendCallInvitationButton> {
  bool requesting = false;
  var callIDNotifier = ValueNotifier<String>("");

  ZegoCallInvitationInnerText? get innerText =>
      ZegoInvitationPageManager.instance.innerText;

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
    ZegoLoggerService.logInfo(
      "update call id, ${callIDNotifier.value}",
      tag: "call",
      subTag: "plugin",
    );
  }

  Widget button() {
    return ZegoStartInvitationButton(
      invitationType: ZegoCallTypeExtension(widget.isVideoCall
              ? ZegoCallType.videoCall
              : ZegoCallType.voiceCall)
          .value,
      invitees: widget.invitees.map((user) {
        return user.id;
      }).toList(),
      data: InvitationInternalData(callIDNotifier.value,
              List.from(widget.invitees), widget.customData)
          .toJson(),
      notificationConfig: ZegoSignalingPluginNotificationConfig(
        resourceID: widget.resourceID ?? "",
        title: (widget.isVideoCall
                ? ((widget.invitees.length > 1
                        ? innerText?.incomingGroupVideoCallDialogTitle
                        : innerText?.incomingVideoCallDialogTitle) ??
                    param_1)
                : ((widget.invitees.length > 1
                        ? innerText?.incomingGroupVoiceCallDialogTitle
                        : innerText?.incomingVoiceCallDialogTitle) ??
                    param_1))
            .replaceFirst(param_1, ZegoUIKit().getLocalUser().name),
        message: widget.isVideoCall
            ? ((widget.invitees.length > 1
                    ? innerText?.incomingGroupVideoCallDialogMessage
                    : innerText?.incomingVideoCallDialogMessage) ??
                "Incoming video call...")
            : ((widget.invitees.length > 1
                    ? innerText?.incomingGroupVoiceCallDialogMessage
                    : innerText?.incomingVoiceCallDialogMessage) ??
                "Incoming voice call..."),
      ),
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
          ZegoLoggerService.logInfo(
            "still in request",
            tag: "call",
            subTag: "plugin",
          );
          return false;
        }

        var currentState = ZegoInvitationPageManager
                .instance.callingMachine.machine.current?.identifier ??
            CallingState.kIdle;
        if (CallingState.kIdle != currentState) {
          ZegoLoggerService.logInfo(
            "still in calling, $currentState",
            tag: "call",
            subTag: "plugin",
          );
          return false;
        }

        requesting = true;
        ZegoLoggerService.logInfo(
          "start request",
          tag: "call",
          subTag: "plugin",
        );

        return true;
      },
      onPressed: onPressed,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  void onPressed(
    String code,
    String message,
    String invitationID,
    List<String> errorInvitees,
  ) {
    ZegoInvitationPageManager.instance.onLocalSendInvitation(
      callIDNotifier.value,
      List.from(widget.invitees),
      widget.isVideoCall ? ZegoCallType.videoCall : ZegoCallType.voiceCall,
      code,
      message,
      invitationID,
      errorInvitees,
    );

    if (widget.onPressed != null) {
      widget.onPressed!(code, message, errorInvitees);
    }

    updateCallID();

    requesting = false;
    ZegoLoggerService.logInfo(
      "finish request",
      tag: "call",
      subTag: "plugin",
    );
  }
}
