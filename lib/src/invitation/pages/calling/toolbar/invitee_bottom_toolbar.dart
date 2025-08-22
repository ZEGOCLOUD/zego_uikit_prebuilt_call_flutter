// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';

/// @nodoc
class ZegoInviteeCallingBottomToolBar extends StatefulWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoCallInvitationType invitationType;
  final ZegoUIKitUser inviter;

  final ZegoCallInvitationInviteeUIConfig uiConfig;

  final ZegoNetworkLoadingConfig? networkLoadingConfig;

  const ZegoInviteeCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitationType,
    required this.uiConfig,
    this.networkLoadingConfig,
  }) : super(key: key);

  @override
  State<ZegoInviteeCallingBottomToolBar> createState() {
    return ZegoInviteeCallingBottomToolBarState();
  }
}

/// @nodoc
class ZegoInviteeCallingBottomToolBarState
    extends State<ZegoInviteeCallingBottomToolBar> {
  double get buttonSize => 120.zR;

  bool get canDisplayFirstRowButtons =>
      widget.invitationType == ZegoCallInvitationType.videoCall;

  TextStyle get buttonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 25.0.zR,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  TextStyle get subButtonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 20.0.zR,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(buttonSize / 2.0),
      child: Column(
        children: [
          ...(canDisplayFirstRowButtons
              ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: ZegoUIKit().getLocalUser().camera,
                        builder: (context, isMicrophoneOn, _) {
                          return buttonWrapper(
                            child: microphoneButton(),
                            textStyle: subButtonTextStyle,
                            label: widget.uiConfig.showSubButtonsText
                                ? isMicrophoneOn
                                    ? widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarMicrophoneOnButtonText
                                    : widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarMicrophoneOffButtonText
                                : null,
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: ZegoUIKit().getLocalUser().camera,
                        builder: (context, isCameraOn, _) {
                          return buttonWrapper(
                            child: cameraButton(),
                            textStyle: subButtonTextStyle,
                            label: widget.uiConfig.showSubButtonsText
                                ? isCameraOn
                                    ? widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarCameraOnButtonText
                                    : widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarCameraOffButtonText
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: buttonSize / 2.0,
                  )
                ]
              : []),
          SizedBox(
            height: 170.zR,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...widget.uiConfig.declineButton.visible
                      ? [
                          ZegoNetworkLoading(
                            config: widget.networkLoadingConfig ??
                                ZegoNetworkLoadingConfig(
                                  enabled: true,
                                  progressColor: Colors.white,
                                ),
                            child: declineButton(),
                          ),
                          SizedBox(width: 230.zR),
                        ]
                      : [],
                  ...widget.uiConfig.acceptButton.visible
                      ? [
                          ZegoNetworkLoading(
                            config: widget.networkLoadingConfig ??
                                ZegoNetworkLoadingConfig(
                                  enabled: true,
                                  progressColor: Colors.white,
                                ),
                            child: acceptButton(),
                          ),
                        ]
                      : [],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget declineButton() {
    final invitationID = widget.pageManager.invitationData.invitationID;
    return ZegoRefuseInvitationButton(
      isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .isAdvanceInvitationMode,
      inviterID: widget.inviter.id,
      targetInvitationID: invitationID,
      // data customization is not supported
      data: const JsonEncoder().convert({
        ZegoCallInvitationProtocolKey.reason:
            ZegoCallInvitationProtocolKey.refuseByDecline,
      }),
      text: widget.uiConfig.showMainButtonsText
          ? widget.callInvitationData.innerText.incomingCallPageDeclineButton
          : null,
      textStyle: widget.uiConfig.declineButton.textStyle ?? buttonTextStyle,
      icon: ButtonIcon(
        icon: widget.uiConfig.declineButton.icon ??
            Image(
              image: ZegoCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomDecline)
                  .image,
              fit: BoxFit.fill,
            ),
      ),
      buttonSize: widget.uiConfig.declineButton.size ??
          Size(buttonSize, buttonSize + 50.zR),
      iconSize: widget.uiConfig.declineButton.iconSize ?? Size(108.zR, 108.zR),
      onPressed: (ZegoRefuseInvitationButtonResult result) {
        widget.pageManager.onLocalRefuseInvitation(
          invitationID,
          result.code,
          result.message,
        );
      },
    );
  }

  Widget acceptButton() {
    final invitationID = widget.pageManager.invitationData.invitationID;
    return ZegoAcceptInvitationButton(
      isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .isAdvanceInvitationMode,
      inviterID: widget.inviter.id,
      targetInvitationID: invitationID,
      customData: ZegoCallInvitationAcceptRequestProtocol().toJson(),
      icon: ButtonIcon(
        icon: widget.uiConfig.acceptButton.icon ??
            Image(
              image: ZegoCallImage.asset(
                      imageURLByInvitationType(widget.invitationType))
                  .image,
              fit: BoxFit.fill,
            ),
      ),
      text: widget.uiConfig.showMainButtonsText
          ? widget.callInvitationData.innerText.incomingCallPageAcceptButton
          : null,
      textStyle: widget.uiConfig.acceptButton.textStyle ?? buttonTextStyle,
      buttonSize: widget.uiConfig.acceptButton.size ??
          Size(buttonSize, buttonSize + 50.zR),
      iconSize: widget.uiConfig.acceptButton.iconSize ?? Size(108.zR, 108.zR),
      onPressed: (ZegoAcceptInvitationButtonResult result) {
        widget.pageManager.onLocalAcceptInvitation(
          invitationID,
          result.code,
          result.message,
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

  Widget buttonWrapper({
    required Widget child,
    String? label,
    TextStyle? textStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: child,
        ),
        if (label != null) ...[
          SizedBox(height: 8.zR),
          Text(
            label,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget microphoneButton() {
    return (widget.uiConfig.microphoneButton?.visible ?? false)
        ? ZegoToggleMicrophoneButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultOn: widget.uiConfig.defaultMicrophoneOn,
            onPressed: (bool isON) {
              widget.pageManager.callingConfig.turnOnMicrophoneWhenJoining =
                  isON;
            },
          )
        : Container();
  }

  Widget cameraButton() {
    if (widget.invitationType == ZegoCallInvitationType.voiceCall) {
      return Container();
    }

    return (widget.uiConfig.cameraButton?.visible ?? false)
        ? ZegoToggleCameraButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultOn: widget.uiConfig.showVideoOnCalling
                ? widget.uiConfig.defaultCameraOn
                : false,
            onPressed: (bool isON) {
              widget.pageManager.callingConfig.turnOnCameraWhenJoining = isON;
            },
          )
        : Container();
  }
}
