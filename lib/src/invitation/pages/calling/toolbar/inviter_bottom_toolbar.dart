// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
class ZegoInviterCallingBottomToolBar extends StatefulWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoNetworkLoadingConfig? networkLoadingConfig;
  final ZegoCallInvitationInviterUIConfig uiConfig;
  final ZegoCallInvitationType invitationType;

  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.uiConfig,
    required this.invitationType,
    required this.invitees,
    this.networkLoadingConfig,
  }) : super(key: key);

  @override
  State<ZegoInviterCallingBottomToolBar> createState() =>
      _ZegoInviterCallingBottomToolBarState();
}

/// @nodoc
class _ZegoInviterCallingBottomToolBarState
    extends State<ZegoInviterCallingBottomToolBar> {
  double get buttonSize => 120.zR;

  TextStyle get subButtonTextStyle => TextStyle(
        color: Colors.white,
        fontSize: 20.0.zR,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.none,
      );

  bool get canDisplayFirstRowButtons =>
      (widget.uiConfig.cameraButton?.visible ?? false) ||
      (widget.uiConfig.cameraSwitchButton?.visible ?? false) ||
      (widget.uiConfig.speakerButton?.visible ?? false);

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
                        valueListenable: ZegoUIKit().getLocalUser().microphone,
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
                      ValueListenableBuilder<ZegoUIKitAudioRoute>(
                        /// listen local audio output route changes
                        valueListenable: ZegoUIKit()
                            .getAudioOutputDeviceNotifier(
                                ZegoUIKit().getLocalUser().id),
                        builder: (context, audioRoute, _) {
                          final isSpeakerOn =
                              audioRoute == ZegoUIKitAudioRoute.speaker;

                          return buttonWrapper(
                            child: speakerButton(),
                            textStyle: subButtonTextStyle,
                            label: widget.uiConfig.showSubButtonsText
                                ? isSpeakerOn
                                    ? widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarSpeakerOnButtonText
                                    : widget
                                        .pageManager
                                        .callInvitationData
                                        .innerText
                                        .callingToolbarSpeakerOffButtonText
                                : null,
                          );
                        },
                      ),
                      if (widget.invitationType ==
                          ZegoCallInvitationType.videoCall)
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
          Center(
            child: buttonWrapper(child: cancelButton()),
          ),
        ],
      ),
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
            defaultOn: widget.uiConfig.defaultCameraOn,
            onPressed: (bool isON) {
              widget.pageManager.callingConfig.turnOnCameraWhenJoining = isON;
            },
          )
        : Container();
  }

  Widget speakerButton() {
    return (widget.uiConfig.speakerButton?.visible ?? false)
        ? ZegoSwitchAudioOutputButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultUseSpeaker: widget.uiConfig.defaultSpeakerOn,
            onPressed: (bool isON) {
              widget.pageManager.callingConfig.useSpeakerWhenJoining = isON;
            },
          )
        : Container();
  }

  Widget cancelButton() {
    return (widget.uiConfig.cancelButton.visible)
        ? ZegoNetworkLoading(
            config: widget.networkLoadingConfig ??
                ZegoNetworkLoadingConfig(
                  enabled: true,
                  progressColor: Colors.white,
                ),
            child: ZegoCancelInvitationButton(
              isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
                  .private
                  .isAdvanceInvitationMode,
              invitees: widget.invitees.map((e) => e.id).toList(),
              targetInvitationID:
                  widget.pageManager.invitationData.invitationID,
              data: ZegoCallInvitationCancelRequestProtocol(
                callID: widget.pageManager.currentCallID,
              ).toJson(),
              text: widget.uiConfig.showMainButtonsText
                  ? widget.pageManager.callInvitationData.innerText
                      .outgoingCallPageACancelButton
                  : null,
              textStyle: widget.uiConfig.cancelButton.textStyle,
              icon: ButtonIcon(
                icon: widget.uiConfig.cancelButton.icon ??
                    Image(
                      image: ZegoCallImage.asset(
                        InvitationStyleIconUrls.toolbarBottomCancel,
                      ).image,
                      fit: BoxFit.fill,
                    ),
              ),
              buttonSize: widget.uiConfig.cancelButton.size ??
                  Size(buttonSize, buttonSize),
              iconSize: widget.uiConfig.cancelButton.iconSize ??
                  Size(buttonSize, buttonSize),
              onPressed: (ZegoCancelInvitationButtonResult result) {
                widget.pageManager.onLocalCancelInvitation(
                  widget.pageManager.invitationData.invitationID,
                  result.code,
                  result.message,
                  result.errorInvitees,
                );
              },
            ),
          )
        : Container();
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
}
