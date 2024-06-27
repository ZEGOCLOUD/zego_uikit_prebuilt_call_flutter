// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/components/send_calling_invitation_list.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// This button is used to invite again when already in calling
///
/// pass the user you need to invite to [waitingSelectUsers].
/// If you want to display users who are already in a call (unable to kick
/// out) to [selectedUsers].
/// If you need to sort the user list, you can set it through [userSort].
class ZegoSendCallingInvitationButton extends StatefulWidget {
  const ZegoSendCallingInvitationButton({
    Key? key,
    required this.waitingSelectUsers,
    required this.selectedUsers,
    this.userSort,
    this.buttonIcon,
    this.popUpTitle,
    this.popUpTitleStyle,
    this.buttonIconSize,
    this.buttonSize,
    this.avatarBuilder,
    this.userNameColor,
    this.popUpBackIcon,
    this.inviteButtonIcon,
    this.defaultChecked = true,
  }) : super(key: key);

  /// icon
  final ButtonIcon? buttonIcon;

  /// icon size
  final Size? buttonIconSize;

  /// button size
  final Size? buttonSize;

  /// avatar builder
  final ZegoAvatarBuilder? avatarBuilder;

  /// color of user name
  final Color? userNameColor;

  /// title of pop-up, default is 'Invitees'
  final String? popUpTitle;

  /// text style of pop-up\'s title
  final TextStyle? popUpTitleStyle;

  /// back icon of pop-up
  final Widget? popUpBackIcon;

  /// icon of invite button
  final Widget? inviteButtonIcon;

  /// Waiting for selected users, that is, users who have not yet participated in the call
  final List<ZegoCallUser> waitingSelectUsers;

  /// selected users (cannot be unselected again), that is, users who are already in the call
  final List<ZegoCallUser> selectedUsers;

  /// The sorting method of the user list, the default is to sort by user id
  final List<ZegoCallUser> Function(List<ZegoCallUser>)? userSort;

  /// Whether [waitingSelectUsers] is checked by default
  final bool defaultChecked;

  @override
  State<ZegoSendCallingInvitationButton> createState() =>
      _ZegoSendCallingInvitationButtonState();
}

class _ZegoSendCallingInvitationButtonState
    extends State<ZegoSendCallingInvitationButton> {
  ZegoCallInvitationPageManager? get pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoUIKitPrebuiltCallInvitationData? get callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationData;

  ZegoCallInvitationInnerText? get innerText => callInvitationConfig?.innerText;

  @override
  Widget build(BuildContext context) {
    return ZegoScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
        final sizeBoxSize = widget.buttonIconSize ?? Size(56.zR, 56.zR);

        return GestureDetector(
          onTap: onPressed,
          child: Container(
            width: containerSize.width,
            height: containerSize.height,
            decoration: BoxDecoration(
              color: widget.buttonIcon?.backgroundColor ??
                  ZegoUIKitDefaultTheme.buttonBackgroundColor,
              borderRadius: BorderRadius.all(
                Radius.circular(
                    math.min(containerSize.width, containerSize.height) / 2),
              ),
            ),
            child: SizedBox.fromSize(
              size: sizeBoxSize,
              child: widget.buttonIcon?.icon ??
                  const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void onPressed() {
    final canInvitingInCalling = ZegoUIKitPrebuiltCallInvitationService()
            .private
            .callInvitationConfig
            ?.canInvitingInCalling ??
        true;
    if (!canInvitingInCalling) {
      ZegoLoggerService.logWarn(
        'ZegoCallInvitationConfig.canInvitingInCalling is false, '
        'not allow inviting in calling',
        tag: 'call-invitation',
        subTag: 'components, send calling button',
      );

      return;
    }

    final currentState =
        pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kOnlineAudioVideo != currentState) {
      ZegoLoggerService.logError(
        'not in calling, $currentState',
        tag: 'call-invitation',
        subTag: 'components, send calling button',
      );
      return;
    }

    if (ZegoUIKitPrebuiltCallInvitationService()
            .private
            .callInvitationConfig
            ?.onlyInitiatorCanInvite ??
        true) {
      final callInitiatorUserID = ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInitiator(ZegoUIKitPrebuiltCallInvitationService()
              .private
              .currentCallInvitationData
              .invitationID)
          ?.userID;
      ZegoLoggerService.logInfo(
        'config is only initiator can invite, '
        'initiator is:$callInitiatorUserID, '
        'local user is:${ZegoUIKit().getLocalUser().id}',
        tag: 'call-invitation',
        subTag: 'components, send calling button',
      );

      if (ZegoUIKit().getLocalUser().id != callInitiatorUserID) {
        ZegoLoggerService.logWarn(
          'only initiator can invite',
          tag: 'call-invitation',
          subTag: 'components, send calling button',
        );

        return;
      }
    }

    showCallingInvitationListSheet(
      context,
      selectedUsers: widget.selectedUsers,
      waitingSelectUsers: widget.waitingSelectUsers,
      userSort: widget.userSort,
      onPressed: (List<ZegoCallUser> selectedUsers) {
        if (selectedUsers.isEmpty) {
          return;
        }

        final currentCallInvitationData =
            ZegoUIKitPrebuiltCallInvitationService()
                .private
                .currentCallInvitationData;
        final localInvitationParameter =
            ZegoUIKitPrebuiltCallInvitationService()
                .private
                .localInvitationParameter;
        ZegoUIKitPrebuiltCallInvitationService().send(
          invitees: selectedUsers,
          isVideoCall: ZegoCallInvitationType.videoCall ==
              currentCallInvitationData.type,
          customData: currentCallInvitationData.customData,
          callID: currentCallInvitationData.callID,
          resourceID: localInvitationParameter.resourceID,
          notificationTitle: localInvitationParameter.notificationTitle,
          notificationMessage: localInvitationParameter.notificationMessage,
          timeoutSeconds: localInvitationParameter.timeoutSeconds,
        );
      },
      backgroundColor:
          ZegoUIKitDefaultTheme.viewBackgroundColor.withOpacity(0.6),
      defaultChecked: widget.defaultChecked,
      buttonIcon: widget.buttonIcon,
      buttonIconSize: widget.buttonIconSize,
      buttonSize: widget.buttonSize,
      avatarBuilder: widget.avatarBuilder,
      userNameColor: widget.userNameColor,
      popUpTitle: widget.popUpTitle,
      popUpTitleStyle: widget.popUpTitleStyle,
      popUpBackIcon: widget.popUpBackIcon,
      inviteButtonIcon: widget.inviteButtonIcon,
    );
  }
}
