// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/toolbar/calling_bottom_toolbar.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/toolbar/calling_top_toolbar.dart';

/// @nodoc
class ZegoCallingInviterView extends StatelessWidget {
  const ZegoCallingInviterView({
    Key? key,
    required this.pageManager,
    required this.callInvitationConfig,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.avatarBuilder,
  }) : super(key: key);

  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallType invitationType;
  final ZegoAvatarBuilder? avatarBuilder;

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
          ],
        );
      },
    );
  }

  Widget backgroundView(BuildContext context) {
    if (ZegoCallType.videoCall == invitationType) {
      return ZegoAudioVideoView(user: inviter);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return callInvitationConfig.uiConfig?.callingBackgroundBuilder?.call(
            context,
            Size(constraints.maxWidth, constraints.maxHeight),
            ZegoCallingBackgroundBuilderInfo(
              inviter: inviter,
              invitees: invitees,
              callType: invitationType,
            ),
          ) ??
          backgroundImage();
    });
  }

  Widget surface(BuildContext context) {
    final isVideo = ZegoCallType.videoCall == invitationType;

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
          child: ValueListenableBuilder(
            valueListenable: ZegoUIKitUserPropertiesNotifier(firstInvitee),
            builder: (context, _, __) {
              return avatarBuilder?.call(
                    context,
                    Size(200.zR, 200.zR),
                    firstInvitee,
                    {},
                  ) ??
                  circleAvatar(firstInvitee.name);
            },
          ),
        ),
        SizedBox(height: 10.zR),
        centralName((isVideo
                ? ((invitees.length > 1
                        ? callInvitationConfig
                            .innerText?.outgoingGroupVideoCallPageTitle
                        : callInvitationConfig
                            .innerText?.outgoingVideoCallPageTitle) ??
                    param_1)
                : ((invitees.length > 1
                        ? callInvitationConfig
                            .innerText?.outgoingGroupVoiceCallPageTitle
                        : callInvitationConfig
                            .innerText?.outgoingVoiceCallPageTitle) ??
                    param_1))
            .replaceFirst(param_1, firstInvitee.name)),
        SizedBox(height: 47.zR),
        callingText(isVideo
            ? ((invitees.length > 1
                    ? callInvitationConfig
                        .innerText?.outgoingGroupVideoCallPageMessage
                    : callInvitationConfig
                        .innerText?.outgoingVideoCallPageMessage) ??
                'Calling...')
            : ((invitees.length > 1
                    ? callInvitationConfig
                        .innerText?.outgoingGroupVoiceCallPageMessage
                    : callInvitationConfig
                        .innerText?.outgoingVoiceCallPageMessage) ??
                'Calling...')),
        const Expanded(child: SizedBox()),
        ZegoInviterCallingBottomToolBar(
          pageManager: pageManager,
          callInvitationConfig: callInvitationConfig,
          invitees: invitees,
        ),
        SizedBox(height: 105.zR),
      ],
    );
  }
}

class ZegoCallingInviteeView extends StatelessWidget {
  const ZegoCallingInviteeView({
    required this.pageManager,
    required this.callInvitationConfig,
    required this.inviter,
    required this.invitees,
    required this.invitationType,
    this.avatarBuilder,
    this.showDeclineButton = true,
    Key? key,
  }) : super(key: key);

  final ZegoInvitationPageManager pageManager;
  final ZegoCallInvitationConfig callInvitationConfig;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallType invitationType;
  final ZegoAvatarBuilder? avatarBuilder;
  final bool showDeclineButton;

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
              return callInvitationConfig.uiConfig?.callingBackgroundBuilder
                      ?.call(
                    context,
                    Size(constraints.maxWidth, constraints.maxHeight),
                    ZegoCallingBackgroundBuilderInfo(
                      inviter: inviter,
                      invitees: invitees,
                      callType: invitationType,
                    ),
                  ) ??
                  backgroundImage();
            }),
            surface(context),
          ],
        );
      },
    );
  }

  Widget surface(BuildContext context) {
    final isVideo = ZegoCallType.videoCall == invitationType;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 280.zR),
        SizedBox(
          width: 200.zR,
          height: 200.zR,
          child: ValueListenableBuilder(
            valueListenable: ZegoUIKitUserPropertiesNotifier(inviter),
            builder: (context, _, __) {
              return avatarBuilder
                      ?.call(context, Size(200.zR, 200.zR), inviter, {}) ??
                  circleAvatar(inviter.name);
            },
          ),
        ),
        SizedBox(height: 10.zR),
        centralName((isVideo
                ? ((invitees.length > 1
                        ? callInvitationConfig
                            .innerText?.incomingGroupVideoCallPageTitle
                        : callInvitationConfig
                            .innerText?.incomingVideoCallPageTitle) ??
                    param_1)
                : ((invitees.length > 1
                        ? callInvitationConfig
                            .innerText?.incomingGroupVoiceCallPageTitle
                        : callInvitationConfig
                            .innerText?.incomingVoiceCallPageTitle) ??
                    param_1))
            .replaceFirst(param_1, inviter.name)),
        SizedBox(height: 47.zR),
        callingText(isVideo
            ? (invitees.length > 1
                ? (callInvitationConfig
                        .innerText?.incomingGroupVideoCallPageMessage ??
                    'Incoming group video call...')
                : (callInvitationConfig
                        .innerText?.incomingVideoCallPageMessage ??
                    'Incoming video call...'))
            : (invitees.length > 1
                ? (callInvitationConfig
                        .innerText?.incomingGroupVoiceCallPageMessage ??
                    'Incoming group voice call...')
                : (callInvitationConfig
                        .innerText?.incomingVoiceCallPageMessage ??
                    'Incoming voice call...'))),
        const Expanded(child: SizedBox()),
        ZegoInviteeCallingBottomToolBar(
          pageManager: pageManager,
          callInvitationConfig: callInvitationConfig,
          inviter: inviter,
          invitationType: invitationType,
          showDeclineButton: showDeclineButton,
        ),
        SizedBox(height: 105.zR),
      ],
    );
  }
}

Widget backgroundImage() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: PrebuiltCallImage.asset(InvitationStyleIconUrls.inviteBackground)
            .image,
        fit: BoxFit.fitHeight,
      ),
    ),
  );
}

Widget centralName(String name) {
  return SizedBox(
    height: 59.zH,
    child: Text(
      name,
      style: TextStyle(
        color: Colors.white,
        fontSize: 42.0.zR,
        decoration: TextDecoration.none,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget callingText(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: 32.0.zR,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
    ),
  );
}

Widget circleAvatar(String name) {
  return Container(
    decoration: const BoxDecoration(
      color: Color(0xffDBDDE3),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name.characters.first : '',
        style: TextStyle(
          fontSize: 96.0.zR,
          color: const Color(0xff222222),
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}
