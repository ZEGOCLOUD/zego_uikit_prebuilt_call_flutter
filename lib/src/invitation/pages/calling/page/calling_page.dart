// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/page/invitee_page.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/page/inviter_page.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallingPage extends StatefulWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;

  final VoidCallback onInitState;
  final VoidCallback onDispose;

  const ZegoCallingPage({
    Key? key,
    required this.pageManager,
    required this.callInvitationData,
    required this.inviter,
    required this.invitees,
    required this.onInitState,
    required this.onDispose,
  }) : super(key: key);

  @override
  State<ZegoCallingPage> createState() => _ZegoCallingPageState();
}

class _ZegoCallingPageState extends State<ZegoCallingPage> {
  CallingState currentState = CallingState.kIdle;

  ZegoCallingMachine? get machine => widget.pageManager.callingMachine;

  @override
  void initState() {
    super.initState();

    widget.onInitState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      machine?.onStateChanged = (CallingState state) {
        setState(() {
          currentState = state;

          ZegoLoggerService.logInfo(
            'onStateChanged, '
            'currentState:$currentState, ',
            tag: 'call-invitation',
            subTag: 'calling page',
          );
        });
      };

      if (null != machine?.machine.current) {
        machine!.onStateChanged!(machine!.machine.current!.identifier);
      }
    });
  }

  @override
  void dispose() {
    widget.onDispose();

    machine?.onStateChanged = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localUserInfo = ZegoUIKit().getLocalUser();
    final localUserIsInviter = localUserInfo.id == widget.inviter.id;

    late Widget view;
    switch (currentState) {
      case CallingState.kIdle:
        view = const SizedBox();
        break;
      case CallingState.kCallingWithVoice:
      case CallingState.kCallingWithVideo:
        final prebuiltCallConfig = widget.callInvitationData.requireConfig(
          widget.pageManager.invitationData,
        );
        final invitationView = localUserIsInviter
            ? (widget.callInvitationData.uiConfig.inviter.pageBuilder?.call(
                  context,
                  ZegoCallingBuilderInfo(
                    inviter: widget.inviter,
                    invitees: widget.invitees,
                    callType: widget.pageManager.invitationData.type,
                    customData: widget.pageManager.invitationData.customData,
                  ),
                ) ??
                ZegoCallingInviterView(
                  pageManager: widget.pageManager,
                  callInvitationData: widget.callInvitationData,
                  inviter: widget.inviter,
                  invitees: widget.invitees,
                  invitationType: widget.pageManager.invitationData.type,
                  customData: widget.pageManager.invitationData.customData,
                  avatarBuilder: prebuiltCallConfig.avatarBuilder,
                  foregroundBuilder: widget
                      .callInvitationData.uiConfig.inviter.foregroundBuilder,
                  backgroundBuilder: widget
                      .callInvitationData.uiConfig.inviter.backgroundBuilder,
                ))
            : (widget.callInvitationData.uiConfig.invitee.pageBuilder?.call(
                  context,
                  ZegoCallingBuilderInfo(
                    inviter: widget.inviter,
                    invitees: widget.invitees,
                    callType: widget.pageManager.invitationData.type,
                    customData: widget.pageManager.invitationData.customData,
                  ),
                ) ??
                ZegoCallingInviteeView(
                  pageManager: widget.pageManager,
                  callInvitationData: widget.callInvitationData,
                  inviter: widget.inviter,
                  invitees: widget.invitees,
                  invitationType: widget.pageManager.invitationData.type,
                  customData: widget.pageManager.invitationData.customData,
                  avatarBuilder: prebuiltCallConfig.avatarBuilder,
                  uiConfig: widget.callInvitationData.uiConfig.invitee,
                ));
        view = widget.callInvitationData.uiConfig.withSafeArea
            ? SafeArea(
                child: invitationView,
              )
            : invitationView;
        break;
      case CallingState.kOnlineAudioVideo:
        view = prebuiltCallPage(
          localUserIsInviter: localUserIsInviter,
        );
        break;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
      },
      child: view,
    );
  }

  Widget prebuiltCallPage({
    required bool localUserIsInviter,
  }) {
    ZegoLoggerService.logInfo(
      'create prebuilt call page, '
      'is group call:${widget.pageManager.isGroupCall}, '
      'invitationData:${widget.pageManager.invitationData}',
      tag: 'call-invitation',
      subTag: 'calling page',
    );

    /// assign if not set
    widget.callInvitationData.events?.onError ??=
        widget.callInvitationData.invitationEvents?.onError;

    var callConfig = widget.callInvitationData.requireConfig(
      widget.pageManager.invitationData,
    );

    /// Update the configuration of widget modifications during calling
    widget.pageManager.callingConfig.sync(
      callConfig,
      widget.callInvitationData.uiConfig.inviter,
      widget.callInvitationData.uiConfig.invitee,
      localUserIsInviter: localUserIsInviter,
    );

    if (Platform.isIOS) {
      if (callConfig.pip.iOS.support !=
          widget.callInvitationData.config.pip.iOS.support) {
        ZegoLoggerService.logError(
          'ios pip support value is different!!!! '
          'the video frame will not be rendered!!!, '
          'please modify [ZegoCallInvitationPIPConfig.pip.iOS.support] and '
          '[ZegoUIKitPrebuiltCallConfig.pip.iOS.support]'
          ' to be consistent in [ZegoUIKitPrebuiltCallInvitationService().init], '
          'invitation config:${widget.callInvitationData.config.pip.iOS.support}, '
          'prebuilt call config:${callConfig.pip.iOS.support} ',
          tag: 'call-invitation',
          subTag: 'calling page',
        );
        ZegoLoggerService.logError(
          'In order to correct the issue of video rendering, the PIP is reset to '
          '${widget.callInvitationData.config.pip.iOS.support ? 'enable' : 'disable'} '
          'this time',
          tag: 'call-invitation',
          subTag: 'calling page',
        );

        callConfig.pip.iOS.support =
            widget.callInvitationData.config.pip.iOS.support;
      }
    }

    ZegoLoggerService.logInfo(
      'create prebuilt call page',
      tag: 'call-invitation',
      subTag: 'calling page',
    );
    if (!widget.pageManager.isGroupCall) {
      /// 1v1 call
      final inviter =
          widget.pageManager.invitationData.inviter ?? ZegoUIKitUser.empty();
      if (!inviter.isEmpty() && inviter.id != ZegoUIKit().getLocalUser().id) {
        /// not local request
        if (callConfig.user.requiredUsers.users.isEmpty) {
          callConfig.user.requiredUsers.users = [
            widget.pageManager.invitationData.inviter!,
          ];
          ZegoLoggerService.logInfo(
            'requiredUsers.users set as (${callConfig.user.requiredUsers.users})',
            tag: 'call-invitation',
            subTag: 'calling page',
          );
        } else {
          ZegoLoggerService.logInfo(
            'config.user.requiredUsers.users had value(${callConfig.user.requiredUsers.users}) before, would not replace it',
            tag: 'call-invitation',
            subTag: 'calling page',
          );
        }
      }
    }

    final prebuiltCall = ZegoUIKitPrebuiltCall(
      appID: widget.callInvitationData.appID,
      appSign: widget.callInvitationData.appSign,
      token: widget.callInvitationData.token,
      callID: widget.pageManager.invitationData.callID,
      userID: widget.callInvitationData.userID,
      userName: widget.callInvitationData.userName,
      config: callConfig,
      events: widget.callInvitationData.events,
      onDispose: () {
        widget.pageManager.onPrebuiltCallPageDispose();
      },
      plugins: widget.callInvitationData.plugins,
    );

    return widget.callInvitationData.uiConfig.withSafeArea
        ? SafeArea(
            child: prebuiltCall,
          )
        : prebuiltCall;
  }
}
