// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/page/common.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/toolbar/inviter_bottom_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/toolbar/inviter_top_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallingInviterView extends StatelessWidget {
  const ZegoCallingInviterView({
    Key? key,
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.avatarBuilder,
    this.foregroundBuilder,
    this.backgroundBuilder,
  }) : super(key: key);

  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallInvitationType invitationType;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoCallingForegroundBuilder? foregroundBuilder;
  final ZegoCallingBackgroundBuilder? backgroundBuilder;

  ZegoCallInvitationInviterUIConfig get config =>
      callInvitationData.uiConfig.inviter;
  ZegoCallInvitationInnerText get innerText => callInvitationData.innerText;

  @override
  Widget build(BuildContext context) {
    return ZegoScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Stack(
          children: [
            backgroundView(context),
            surface(context),
            foreground(context),
          ],
        );
      },
    );
  }

  Widget backgroundView(BuildContext context) {
    if (ZegoCallInvitationType.videoCall == invitationType) {
      return ZegoAudioVideoView(user: inviter);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return backgroundBuilder?.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            ZegoCallingBuilderInfo(
              inviter: inviter,
              invitees: invitees,
              callType: invitationType,
            ),
          ) ??
          backgroundImage();
    });
  }

  Widget surface(BuildContext context) {
    final isVideo = ZegoCallInvitationType.videoCall == invitationType;

    final firstInvitee =
        invitees.isNotEmpty ? invitees.first : ZegoUIKitUser.empty();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isVideo) const ZegoInviterCallingVideoTopToolBar() else Container(),
        if (isVideo) SizedBox(height: 140.zH) else SizedBox(height: 228.zH),
        SizedBox(
          width: 200.zR,
          height: 200.zR,
          child: config.showAvatar
              ? ValueListenableBuilder(
                  valueListenable:
                      ZegoUIKitUserPropertiesNotifier(firstInvitee),
                  builder: (context, _, __) {
                    return avatarBuilder?.call(
                          context,
                          Size(200.zR, 200.zR),
                          firstInvitee,
                          {},
                        ) ??
                        circleAvatar(firstInvitee.name);
                  },
                )
              : Container(),
        ),
        SizedBox(height: config.spacingBetweenAvatarAndName ?? 10.zR),
        config.showCentralName
            ? centralName((isVideo
                    ? (invitees.length > 1
                        ? innerText.outgoingGroupVideoCallPageTitle
                        : innerText.outgoingVideoCallPageTitle)
                    : (invitees.length > 1
                        ? innerText.outgoingGroupVoiceCallPageTitle
                        : innerText.outgoingVoiceCallPageTitle))
                .replaceFirst(param_1, firstInvitee.name))
            : SizedBox(height: 59.zH),
        SizedBox(height: config.spacingBetweenNameAndCallingText ?? 47.zR),
        config.showCallingText
            ? callingText(isVideo
                ? (invitees.length > 1
                    ? innerText.outgoingGroupVideoCallPageMessage
                    : innerText.outgoingVideoCallPageMessage)
                : (invitees.length > 1
                    ? innerText.outgoingGroupVoiceCallPageMessage
                    : innerText.outgoingVoiceCallPageMessage))
            : SizedBox(height: 32.0.zR),
        const Expanded(child: SizedBox()),
        ZegoInviterCallingBottomToolBar(
          pageManager: pageManager,
          cancelButtonConfig: config.cancelButton,
          invitees: invitees,
        ),
        SizedBox(height: 105.zR),
      ],
    );
  }

  Widget foreground(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return foregroundBuilder?.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            ZegoCallingBuilderInfo(
              inviter: inviter,
              invitees: invitees,
              callType: invitationType,
            ),
          ) ??
          Container();
    });
  }
}
