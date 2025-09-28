// Dart imports:
import 'dart:convert';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/page/common.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/toolbar/invitee_bottom_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/toolbar/inviter_bottom_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';

/// Widget for minimized invitation interface
class ZegoMinimizingCallingPage extends StatefulWidget {
  const ZegoMinimizingCallingPage({
    Key? key,
    required this.size,
    required this.invitationType,
    required this.inviter,
    required this.invitees,
    required this.isInviter,
    this.customData,
    this.pageManager,
    this.callInvitationData,
    this.inviterUIConfig,
    this.inviteeUIConfig,
    this.foreground,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
  }) : super(key: key);

  final Size size;
  final ZegoCallInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final bool isInviter;
  final String? customData;
  final ZegoCallInvitationPageManager? pageManager;
  final ZegoUIKitPrebuiltCallInvitationData? callInvitationData;
  final ZegoCallInvitationInviterUIConfig? inviterUIConfig;
  final ZegoCallInvitationInviteeUIConfig? inviteeUIConfig;

  final Widget? foreground;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewForegroundBuilder? backgroundBuilder;
  final ZegoAvatarBuilder? avatarBuilder;

  @override
  State<ZegoMinimizingCallingPage> createState() =>
      _ZegoMinimizingCallingPageState();
}

/// @nodoc
class _ZegoMinimizingCallingPageState extends State<ZegoMinimizingCallingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Stack(
        children: [
          audioVideoContainer(),

          // Main content overlay - buttons and tips
          Padding(
            padding: EdgeInsets.all(20.zR),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buttons(),
                  if (shouldShowTips()) ...[
                    SizedBox(height: 10.zR),
                    tipsText(),
                  ],
                ],
              ),
            ),
          ),
          widget.foreground ?? Container(),
        ],
      ),
    );
  }

  /// Build background video view for video calls
  Widget audioVideoContainer() {
    if (widget.invitationType != ZegoCallInvitationType.videoCall) {
      return Container();
    }

    final user = widget.isInviter ? widget.inviter : ZegoUIKit().getLocalUser();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ZegoAudioVideoView(
        user: user,
        avatarConfig: ZegoAvatarConfig(
          showInAudioMode: false,
          builder: widget.avatarBuilder,
        ),
        foregroundBuilder: widget.foregroundBuilder,
        backgroundBuilder: widget.backgroundBuilder,
      ),
    );
  }

  Widget buttons() {
    if (widget.isInviter) {
      // Caller side: show cancel button
      return _buildCancelButton();
    } else {
      // Callee side: show accept/reject buttons
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDeclineButton(),
          SizedBox(width: widget.size.width * 0.05),
          _buildAcceptButton(),
        ],
      );
    }
  }

  /// Build cancel button for inviter (caller side)
  Widget _buildCancelButton() {
    if (widget.pageManager == null) {
      return Container();
    }

    final invitationID = widget.pageManager!.invitationData.invitationID;

    return (widget.inviterUIConfig?.minimized?.cancelButton.visible ?? true)
        ? ZegoCancelInvitationButton(
            isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
                .private
                .isAdvanceInvitationMode,
            invitees: widget.invitees.map((e) => e.id).toList(),
            targetInvitationID: invitationID,
            data: ZegoCallInvitationCancelRequestProtocol(
              callID: widget.pageManager!.currentCallID,
            ).toJson(),
            text: widget.inviterUIConfig?.showMainButtonsText == true
                ? widget.pageManager!.callInvitationData.innerText
                    .outgoingCallPageACancelButton
                : null,
            textStyle:
                widget.inviterUIConfig?.minimized?.cancelButton.textStyle,
            icon: ButtonIcon(
              icon: widget.inviterUIConfig?.minimized?.cancelButton.icon ??
                  Image(
                    image: ZegoCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomCancel,
                    ).image,
                    fit: BoxFit.fill,
                  ),
            ),
            buttonSize: widget.inviterUIConfig?.minimized?.cancelButton.size ??
                Size(
                  widget.size.width * 0.25,
                  widget.size.width * 0.25,
                ),
            iconSize:
                widget.inviterUIConfig?.minimized?.cancelButton.iconSize ??
                    Size(
                      widget.size.width * 0.25,
                      widget.size.width * 0.25,
                    ),
            onPressed: (ZegoCancelInvitationButtonResult result) {
              widget.pageManager!.onLocalCancelInvitation(
                invitationID,
                result.code,
                result.message,
                result.errorInvitees,
              );
            },
          )
        : Container();
  }

  /// Build decline button for invitee (callee side)
  Widget _buildDeclineButton() {
    if (widget.pageManager == null) {
      return Container();
    }

    final invitationID = widget.pageManager!.invitationData.invitationID;

    return (widget.inviteeUIConfig?.minimized?.declineButton.visible ?? true)
        ? ZegoRefuseInvitationButton(
            isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
                .private
                .isAdvanceInvitationMode,
            inviterID: widget.inviter.id,
            targetInvitationID: invitationID,
            data: const JsonEncoder().convert({
              ZegoCallInvitationProtocolKey.reason:
                  ZegoCallInvitationProtocolKey.refuseByDecline,
            }),
            text: widget.inviteeUIConfig?.showMainButtonsText == true
                ? widget.pageManager!.callInvitationData.innerText
                    .incomingCallPageDeclineButton
                : null,
            textStyle:
                widget.inviteeUIConfig?.minimized?.declineButton.textStyle,
            icon: ButtonIcon(
              icon: widget.inviteeUIConfig?.minimized?.declineButton.icon ??
                  Image(
                    image: ZegoCallImage.asset(
                            InvitationStyleIconUrls.toolbarBottomDecline)
                        .image,
                    fit: BoxFit.fill,
                  ),
            ),
            buttonSize: widget.inviteeUIConfig?.minimized?.declineButton.size ??
                Size(
                  widget.size.width * 0.25,
                  widget.size.width * 0.25,
                ),
            iconSize:
                widget.inviteeUIConfig?.minimized?.declineButton.iconSize ??
                    Size(
                      widget.size.width * 0.25,
                      widget.size.width * 0.25,
                    ),
            onPressed: (ZegoRefuseInvitationButtonResult result) {
              widget.pageManager!.onLocalRefuseInvitation(
                invitationID,
                result.code,
                result.message,
              );
            },
          )
        : Container();
  }

  /// Build accept button for invitee (callee side)
  Widget _buildAcceptButton() {
    if (widget.pageManager == null) {
      return Container();
    }

    final invitationID = widget.pageManager!.invitationData.invitationID;

    return (widget.inviteeUIConfig?.minimized?.acceptButton.visible ?? true)
        ? ZegoAcceptInvitationButton(
            isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
                .private
                .isAdvanceInvitationMode,
            inviterID: widget.inviter.id,
            targetInvitationID: invitationID,
            customData: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            text: widget.inviteeUIConfig?.showMainButtonsText == true
                ? widget.pageManager!.callInvitationData.innerText
                    .incomingCallPageAcceptButton
                : null,
            textStyle:
                widget.inviteeUIConfig?.minimized?.acceptButton.textStyle,
            icon: ButtonIcon(
              icon: widget.inviteeUIConfig?.minimized?.acceptButton.icon ??
                  Image(
                    image: ZegoCallImage.asset(
                            imageURLByInvitationType(widget.invitationType))
                        .image,
                    fit: BoxFit.fill,
                  ),
            ),
            buttonSize: widget.inviteeUIConfig?.minimized?.acceptButton.size ??
                Size(
                  widget.size.width * 0.25,
                  widget.size.width * 0.25,
                ),
            iconSize:
                widget.inviteeUIConfig?.minimized?.acceptButton.iconSize ??
                    Size(
                      widget.size.width * 0.25,
                      widget.size.width * 0.25,
                    ),
            onPressed: (ZegoAcceptInvitationButtonResult result) {
              widget.pageManager!.onLocalAcceptInvitation(
                invitationID,
                result.code,
                result.message,
              );
            },
          )
        : Container();
  }

  /// Get image URL based on invitation type (for accept button)
  String imageURLByInvitationType(ZegoCallInvitationType invitationType) {
    switch (invitationType) {
      case ZegoCallInvitationType.voiceCall:
        return InvitationStyleIconUrls.toolbarBottomVoice;
      case ZegoCallInvitationType.videoCall:
        return InvitationStyleIconUrls.toolbarBottomVideo;
    }
  }

  /// Check if tips should be shown
  bool shouldShowTips() {
    if (widget.isInviter) {
      return widget.inviterUIConfig?.minimized?.showTips ?? true;
    } else {
      return widget.inviteeUIConfig?.minimized?.showTips ?? true;
    }
  }

  /// Build tips text widget
  Widget tipsText() {
    if (widget.pageManager == null) {
      return Container();
    }

    final text = widget.pageManager!.callInvitationData.innerText
        .minimizedCallingPageWaitingText;

    return Text(
      text,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 14.zR,
        decoration: TextDecoration.none,
      ),
      textAlign: TextAlign.center,
    );
  }
}
