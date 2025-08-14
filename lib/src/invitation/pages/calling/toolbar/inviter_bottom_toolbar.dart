// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// @nodoc
class ZegoInviterCallingBottomToolBar extends StatefulWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoNetworkLoadingConfig? networkLoadingConfig;
  final ZegoCallInvitationInviterUIConfig uiConfig;

  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.uiConfig,
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

  bool get hasFirstRowButtons =>
      (widget.uiConfig.microphoneButton?.visible ?? false) ||
      (widget.uiConfig.microphoneButton?.visible ?? false) ||
      (widget.uiConfig.microphoneButton?.visible ?? false);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...(hasFirstRowButtons
            ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buttonWrapper(child: microphoneButton()),
                    buttonWrapper(child: speakerButton()),
                    buttonWrapper(child: cameraButton())
                  ],
                ),
              ]
            : []),
        Stack(
          children: [
            Center(
              child: buttonWrapper(child: cancelButton()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: buttonWrapper(child: cameraSwitchButton()),
            )
          ],
        ),
      ],
    );
  }

  Widget microphoneButton() {
    return (widget.uiConfig.microphoneButton?.visible ?? false)
        ? ZegoToggleMicrophoneButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultOn: true,
          )
        : Container();
  }

  Widget cameraButton() {
    return (widget.uiConfig.cameraButton?.visible ?? false)
        ? ZegoToggleCameraButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultOn: true,
          )
        : Container();
  }

  Widget cameraSwitchButton() {
    return (widget.uiConfig.cameraSwitchButton?.visible ?? false)
        ? ZegoSwitchCameraButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultUseFrontFacingCamera: ZegoUIKit()
                .getUseFrontFacingCameraStateNotifier(
                    ZegoUIKit().getLocalUser().id)
                .value,
          )
        : Container();
  }

  Widget speakerButton() {
    return (widget.uiConfig.speakerButton?.visible ?? false)
        ? ZegoSwitchAudioOutputButton(
            buttonSize: Size(buttonSize, buttonSize),
            iconSize: Size(buttonSize, buttonSize),
            defaultUseSpeaker: false,
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

  Widget buttonWrapper({required Widget child}) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: child,
    );
  }
}
