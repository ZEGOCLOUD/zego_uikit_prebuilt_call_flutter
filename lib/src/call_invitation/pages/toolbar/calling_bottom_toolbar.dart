// Flutter imports:
import 'dart:convert';

import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

/// @nodoc
class ZegoInviterCallingBottomToolBar extends StatelessWidget {
  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.callInvitationConfig,
    required this.invitees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.zH,
      child: Center(
        child: callInvitationConfig.showCancelInvitationButton
            ? ZegoCancelInvitationButton(
                invitees: invitees.map((e) => e.id).toList(),
                data: const JsonEncoder().convert({
                  'call_id': pageManager.currentCallID,
                  'operation_type': 'cancel_invitation',
                }),
                icon: ButtonIcon(
                  icon: Image(
                    image: PrebuiltCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomCancel,
                    ).image,
                    fit: BoxFit.fill,
                  ),
                ),
                buttonSize: Size(120.zR, 120.zR),
                iconSize: Size(120.zR, 120.zR),
                onPressed:
                    (String code, String message, List<String> errorInvitees) {
                  pageManager.onLocalCancelInvitation(
                      code, message, errorInvitees);
                },
              )
            : Container(),
      ),
    );
  }
}

/// @nodoc
class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  final ZegoCallType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final bool showDeclineButton;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.callInvitationConfig,
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

/// @nodoc
class ZegoInviteeCallingBottomToolBarState
    extends State<ZegoInviteeCallingBottomToolBar> {
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
            ...widget.showDeclineButton
                ? [
                    declineButton(),
                    SizedBox(width: 230.zR),
                  ]
                : [],
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
      text: widget
              .callInvitationConfig.innerText?.incomingCallPageDeclineButton ??
          'Decline',
      textStyle: buttonTextStyle(),
      icon: ButtonIcon(
        icon: Image(
          image: PrebuiltCallImage.asset(
                  InvitationStyleIconUrls.toolbarBottomDecline)
              .image,
          fit: BoxFit.fill,
        ),
      ),
      buttonSize: Size(120.zR, 120.zR + 50.zR),
      iconSize: Size(108.zR, 108.zR),
      onPressed: (String code, String message) {
        widget.pageManager.onLocalRefuseInvitation(code, message);
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
      text:
          widget.callInvitationConfig.innerText?.incomingCallPageAcceptButton ??
              'Accept',
      textStyle: buttonTextStyle(),
      buttonSize: Size(120.zR, 120.zR + 50.zR),
      iconSize: Size(108.zR, 108.zR),
      onPressed: (String code, String message) {
        widget.pageManager.onLocalAcceptInvitation(code, message);
      },
    );
  }

  TextStyle buttonTextStyle() {
    return TextStyle(
      color: Colors.white,
      fontSize: 25.0.zR,
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
