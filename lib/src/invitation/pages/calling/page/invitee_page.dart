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
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/toolbar/invitee_bottom_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

class ZegoCallingInviteeView extends StatelessWidget {
  const ZegoCallingInviteeView({
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    required this.declineButtonConfig,
    required this.acceptButtonConfig,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
    Key? key,
  }) : super(key: key);

  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallInvitationType invitationType;
  final ZegoAvatarBuilder? avatarBuilder;

  final ZegoCallingForegroundBuilder? foregroundBuilder;
  final ZegoCallingBackgroundBuilder? backgroundBuilder;
  final ZegoCallButtonUIConfig declineButtonConfig;
  final ZegoCallButtonUIConfig acceptButtonConfig;

  ZegoCallInvitationInviteeUIConfig get config =>
      callInvitationData.uiConfig.invitee;
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
            LayoutBuilder(builder: (context, constraints) {
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
            }),
            surface(context),
            foreground(context),
          ],
        );
      },
    );
  }

  Widget surface(BuildContext context) {
    final isVideo = ZegoCallInvitationType.videoCall == invitationType;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 280.zR),
        SizedBox(
          width: 200.zR,
          height: 200.zR,
          child: config.showAvatar
              ? ValueListenableBuilder(
                  valueListenable: ZegoUIKitUserPropertiesNotifier(inviter),
                  builder: (context, _, __) {
                    return avatarBuilder?.call(
                          context,
                          Size(200.zR, 200.zR),
                          inviter,
                          {},
                        ) ??
                        circleAvatar(inviter.name);
                  },
                )
              : Container(),
        ),
        SizedBox(height: config.spacingBetweenAvatarAndName ?? 10.zR),
        config.showCentralName
            ? centralName((isVideo
                    ? (invitees.length > 1
                        ? innerText.incomingGroupVideoCallPageTitle
                        : innerText.incomingVideoCallPageTitle)
                    : (invitees.length > 1
                        ? innerText.incomingGroupVoiceCallPageTitle
                        : innerText.incomingVoiceCallPageTitle))
                .replaceFirst(param_1, inviter.name))
            : SizedBox(
                height: 59.zH,
              ),
        SizedBox(height: config.spacingBetweenNameAndCallingText ?? 47.zR),
        config.showCallingText
            ? callingText(isVideo
                ? (invitees.length > 1
                    ? (innerText.incomingGroupVideoCallPageMessage)
                    : (innerText.incomingVideoCallPageMessage))
                : (invitees.length > 1
                    ? (innerText.incomingGroupVoiceCallPageMessage)
                    : (innerText.incomingVoiceCallPageMessage)))
            : SizedBox(
                height: 32.0.zR,
              ),
        const Expanded(child: SizedBox()),
        ZegoInviteeCallingBottomToolBar(
          pageManager: pageManager,
          callInvitationData: callInvitationData,
          inviter: inviter,
          invitationType: invitationType,
          declineButtonConfig: declineButtonConfig,
          acceptButtonConfig: acceptButtonConfig,
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
