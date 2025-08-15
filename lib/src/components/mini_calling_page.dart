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
class ZegoMinimizingCallingPage extends StatelessWidget {
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
    this.avatarBuilder,
    this.backgroundBuilder,
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
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoCallingBackgroundBuilder? backgroundBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Stack(
        children: [
          // Background video view for video calls
          if (invitationType == ZegoCallInvitationType.videoCall)
            _buildBackgroundVideo(),

          // Main content overlay - only buttons
          Padding(
            padding: EdgeInsets.all(20.zR),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildActionButtons(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build background video view for video calls
  Widget _buildBackgroundVideo() {
    if (invitationType != ZegoCallInvitationType.videoCall) {
      return Container();
    }

    final user = isInviter ? inviter : ZegoUIKit().getLocalUser();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ZegoAudioVideoView(
        user: user,
        avatarConfig: const ZegoAvatarConfig(
          showInAudioMode: false,
        ),
        backgroundBuilder: (
          BuildContext context,
          Size size,
          ZegoUIKitUser? user,
          Map<String, dynamic> extraInfo,
        ) {
          return defaultBackground();
        },
      ),
    );
  }

  /// Default background for the minimized interface
  Widget defaultBackground() {
    return LayoutBuilder(builder: (context, constraints) {
      return backgroundBuilder?.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            ZegoCallingBuilderInfo(
              inviter: inviter,
              invitees: invitees,
              callType: invitationType,
              customData: customData ?? '',
            ),
          ) ??
          backgroundImage();
    });
  }

  Widget _buildActionButtons() {
    if (isInviter) {
      // Caller side: show cancel button
      return _buildCancelButton();
    } else {
      // Callee side: show accept/reject buttons
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDeclineButton(),
          SizedBox(width: size.width * 0.05),
          _buildAcceptButton(),
        ],
      );
    }
  }

  /// Build cancel button for inviter (caller side)
  Widget _buildCancelButton() {
    if (pageManager == null) {
      return Container();
    }

    final invitationID = pageManager!.invitationData.invitationID;
    final inviterConfig = inviterUIConfig;

    return ZegoCancelInvitationButton(
      isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .isAdvanceInvitationMode,
      invitees: invitees.map((e) => e.id).toList(),
      targetInvitationID: invitationID,
      data: ZegoCallInvitationCancelRequestProtocol(
        callID: pageManager!.currentCallID,
      ).toJson(),
      text: inviterConfig?.showMainButtonsText == true
          ? pageManager!
              .callInvitationData.innerText.outgoingCallPageACancelButton
          : null,
      textStyle: inviterConfig?.cancelButton.textStyle,
      icon: ButtonIcon(
        icon: inviterConfig?.cancelButton.icon ??
            Image(
              image: ZegoCallImage.asset(
                InvitationStyleIconUrls.toolbarBottomCancel,
              ).image,
              fit: BoxFit.fill,
            ),
      ),
      buttonSize: inviterConfig?.cancelButton.size ??
          Size(size.width * 0.25, size.width * 0.25),
      iconSize: inviterConfig?.cancelButton.iconSize ??
          Size(size.width * 0.25, size.width * 0.25),
      onPressed: (ZegoCancelInvitationButtonResult result) {
        pageManager!.onLocalCancelInvitation(
          invitationID,
          result.code,
          result.message,
          result.errorInvitees,
        );
      },
    );
  }

  /// Build decline button for invitee (callee side)
  Widget _buildDeclineButton() {
    if (pageManager == null) {
      return Container();
    }

    final invitationID = pageManager!.invitationData.invitationID;
    final inviteeConfig = inviteeUIConfig;

    return ZegoRefuseInvitationButton(
      isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .isAdvanceInvitationMode,
      inviterID: inviter.id,
      targetInvitationID: invitationID,
      data: const JsonEncoder().convert({
        ZegoCallInvitationProtocolKey.reason:
            ZegoCallInvitationProtocolKey.refuseByDecline,
      }),
      text: inviteeConfig?.showMainButtonsText == true
          ? pageManager!
              .callInvitationData.innerText.incomingCallPageDeclineButton
          : null,
      textStyle: inviteeConfig?.declineButton.textStyle,
      icon: ButtonIcon(
        icon: inviteeConfig?.declineButton.icon ??
            Image(
              image: ZegoCallImage.asset(
                      InvitationStyleIconUrls.toolbarBottomDecline)
                  .image,
              fit: BoxFit.fill,
            ),
      ),
      buttonSize: inviteeConfig?.declineButton.size ??
          Size(size.width * 0.25, size.width * 0.25),
      iconSize: inviteeConfig?.declineButton.iconSize ??
          Size(size.width * 0.25, size.width * 0.25),
      onPressed: (ZegoRefuseInvitationButtonResult result) {
        pageManager!.onLocalRefuseInvitation(
          invitationID,
          result.code,
          result.message,
        );
      },
    );
  }

  /// Build accept button for invitee (callee side)
  Widget _buildAcceptButton() {
    if (pageManager == null) {
      return Container();
    }

    final invitationID = pageManager!.invitationData.invitationID;
    final inviteeConfig = inviteeUIConfig;

    return ZegoAcceptInvitationButton(
      isAdvancedMode: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .isAdvanceInvitationMode,
      inviterID: inviter.id,
      targetInvitationID: invitationID,
      customData: ZegoCallInvitationAcceptRequestProtocol().toJson(),
      text: inviteeConfig?.showMainButtonsText == true
          ? pageManager!
              .callInvitationData.innerText.incomingCallPageAcceptButton
          : null,
      textStyle: inviteeConfig?.acceptButton.textStyle,
      icon: ButtonIcon(
        icon: inviteeConfig?.acceptButton.icon ??
            Image(
              image:
                  ZegoCallImage.asset(imageURLByInvitationType(invitationType))
                      .image,
              fit: BoxFit.fill,
            ),
      ),
      buttonSize: inviteeConfig?.acceptButton.size ??
          Size(size.width * 0.25, size.width * 0.25),
      iconSize: inviteeConfig?.acceptButton.iconSize ??
          Size(size.width * 0.25, size.width * 0.25),
      onPressed: (ZegoAcceptInvitationButtonResult result) {
        pageManager!.onLocalAcceptInvitation(
          invitationID,
          result.code,
          result.message,
        );
      },
    );
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
}
