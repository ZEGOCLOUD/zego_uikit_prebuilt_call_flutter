// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoCallInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final ZegoCallButtonUIConfig declineButtonConfig;
  final ZegoCallButtonUIConfig acceptButtonConfig;

  final ZegoCallInvitationNetworkConfig? networkConfig;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitationType,
    required this.declineButtonConfig,
    required this.acceptButtonConfig,
    this.networkConfig,
  }) : super(key: key);

  @override
  State<ZegoInviteeCallingBottomToolBar> createState() {
    return ZegoInviteeCallingBottomToolBarState();
  }
}

/// @nodoc
class ZegoInviteeCallingBottomToolBarState
    extends State<ZegoInviteeCallingBottomToolBar> {
  TextStyle get buttonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 25.0.zR,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.zR,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...widget.declineButtonConfig.visible
                ? [
                    ZegoNetworkLoading(
                      enabled: widget.networkConfig?.enabled ?? true,
                      icon: widget.networkConfig?.icon,
                      iconColor: widget.networkConfig?.iconColor,
                      progressColor:
                          widget.networkConfig?.progressColor ?? Colors.white,
                      child: declineButton(),
                    ),
                    SizedBox(width: 230.zR),
                  ]
                : [],
            ...widget.acceptButtonConfig.visible
                ? [
                    ZegoNetworkLoading(
                      enabled: widget.networkConfig?.enabled ?? true,
                      icon: widget.networkConfig?.icon,
                      iconColor: widget.networkConfig?.iconColor,
                      progressColor:
                          widget.networkConfig?.progressColor ?? Colors.white,
                      child: acceptButton(),
                    ),
                  ]
                : [],
          ],
        ),
      ),
    );
  }

  Widget declineButton() {
    final invitationID = widget.pageManager.invitationData.invitationID;
    return ZegoRefuseInvitationButton(
      isAdvancedMode: true,
      inviterID: widget.inviter.id,
      targetInvitationID: invitationID,
      // data customization is not supported
      data: const JsonEncoder().convert({
        ZegoCallInvitationProtocolKey.reason:
            ZegoCallInvitationProtocolKey.refuseByDecline,
      }),
      text: widget.callInvitationData.innerText.incomingCallPageDeclineButton,
      textStyle: widget.declineButtonConfig.textStyle ?? buttonTextStyle,
      icon: ButtonIcon(
        icon: widget.declineButtonConfig.icon ??
            Image(
              image: ZegoCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomDecline)
                  .image,
              fit: BoxFit.fill,
            ),
      ),
      buttonSize:
          widget.declineButtonConfig.size ?? Size(120.zR, 120.zR + 50.zR),
      iconSize: widget.declineButtonConfig.iconSize ?? Size(108.zR, 108.zR),
      onPressed: (String code, String message) {
        widget.pageManager.onLocalRefuseInvitation(
          invitationID,
          code,
          message,
        );
      },
    );
  }

  Widget acceptButton() {
    final invitationID = widget.pageManager.invitationData.invitationID;
    return ZegoAcceptInvitationButton(
      isAdvancedMode: true,
      inviterID: widget.inviter.id,
      targetInvitationID: invitationID,
      customData: ZegoCallInvitationAcceptRequestProtocol().toJson(),
      icon: ButtonIcon(
        icon: widget.acceptButtonConfig.icon ??
            Image(
              image: ZegoCallImage.asset(
                      imageURLByInvitationType(widget.invitationType))
                  .image,
              fit: BoxFit.fill,
            ),
      ),
      text: widget.callInvitationData.innerText.incomingCallPageAcceptButton,
      textStyle: widget.acceptButtonConfig.textStyle ?? buttonTextStyle,
      buttonSize:
          widget.acceptButtonConfig.size ?? Size(120.zR, 120.zR + 50.zR),
      iconSize: widget.acceptButtonConfig.iconSize ?? Size(108.zR, 108.zR),
      onPressed: (String code, String message) {
        widget.pageManager.onLocalAcceptInvitation(
          invitationID,
          code,
          message,
        );
      },
    );
  }

  String imageURLByInvitationType(ZegoCallInvitationType invitationType) {
    switch (invitationType) {
      case ZegoCallInvitationType.voiceCall:
        return InvitationStyleIconUrls.toolbarBottomVoice;
      case ZegoCallInvitationType.videoCall:
        return InvitationStyleIconUrls.toolbarBottomVideo;
    }
  }
}
