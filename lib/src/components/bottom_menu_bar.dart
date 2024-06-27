// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/effects/sound_effect_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/member/list_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/message/in_room_message_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_button.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// @nodoc
class ZegoCallBottomMenuBar extends StatefulWidget {
  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final void Function(ZegoCallEndEvent event) defaultEndAction;
  final Future<bool> Function(ZegoCallHangUpConfirmationEvent event)
      defaultHangUpConfirmationAction;

  final Size buttonSize;
  final ValueNotifier<bool> visibilityNotifier;
  final int autoHideSeconds;
  final ValueNotifier<int> restartHideTimerNotifier;
  final ValueNotifier<bool>? isHangUpRequestingNotifier;

  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;

  final ZegoCallMinimizeData minimizeData;

  final ValueNotifier<bool> chatViewVisibleNotifier;
  final ZegoCallPopUpManager popUpManager;

  const ZegoCallBottomMenuBar({
    Key? key,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultHangUpConfirmationAction,
    required this.visibilityNotifier,
    required this.restartHideTimerNotifier,
    required this.minimizeData,
    required this.isHangUpRequestingNotifier,
    required this.chatViewVisibleNotifier,
    required this.popUpManager,
    this.autoHideSeconds = 3,
    this.buttonSize = const Size(60, 60),
    this.height,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ZegoCallBottomMenuBar> createState() => _ZegoCallBottomMenuBarState();
}

/// @nodoc
class _ZegoCallBottomMenuBarState extends State<ZegoCallBottomMenuBar> {
  Timer? hideTimerOfMenuBar;

  final hangupButtonClickableNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    countdownToHideBar();
    widget.restartHideTimerNotifier.addListener(onHideTimerRestartNotify);

    widget.visibilityNotifier.addListener(onVisibilityNotifierChanged);

    widget.isHangUpRequestingNotifier?.addListener(oHangUpRequestingChanged);
  }

  @override
  void dispose() {
    stopCountdownHideBar();
    widget.restartHideTimerNotifier.removeListener(onHideTimerRestartNotify);

    widget.visibilityNotifier.removeListener(onVisibilityNotifierChanged);

    widget.isHangUpRequestingNotifier?.removeListener(oHangUpRequestingChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueNotifierSliderVisibility(
      visibilityNotifier: widget.visibilityNotifier,
      child: Container(
        margin: widget.config.bottomMenuBar.margin,
        padding: widget.config.bottomMenuBar.padding,
        height: widget.height ?? (widget.buttonSize.height + 2 * 3),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius ?? 0),
            topRight: Radius.circular(widget.borderRadius ?? 0),
          ),
        ),
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: getDisplayButtons(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    final buttonList = <Widget>[
      ...getDefaultButtons(
        context,
        cameraDefaultValueFunc: widget.minimizeData.isPrebuiltFromMinimizing
            ? () {
                /// if is minimizing, take the local device state
                return ZegoUIKit()
                    .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
                    .value;
              }
            : null,
        microphoneDefaultValueFunc: widget.minimizeData.isPrebuiltFromMinimizing
            ? () {
                /// if is minimizing, take the local device state
                return ZegoUIKit()
                    .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
                    .value;
              }
            : null,
      ),
      ...widget.config.bottomMenuBar.extendButtons
          .map((extendButton) => buttonWrapper(child: extendButton))
    ];

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBar.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
          0, widget.config.bottomMenuBar.maxCount - 1)
        ..add(
          buttonWrapper(
            child: ZegoMoreButton(menuButtonListFunc: () {
              final buttonList = <Widget>[
                ...getDefaultButtons(context, cameraDefaultValueFunc: () {
                  return ZegoUIKit()
                      .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
                      .value;
                }, microphoneDefaultValueFunc: () {
                  return ZegoUIKit()
                      .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
                      .value;
                }),
                ...widget.config.bottomMenuBar.extendButtons
                    .map((extendButton) => buttonWrapper(child: extendButton))
              ]..removeRange(
                  0,
                  widget.config.bottomMenuBar.maxCount - 1,
                );

              return buttonList;
            }),
          ),
        );
    } else {
      displayButtonList = buttonList;
    }

    return displayButtonList;
  }

  void onHideTimerRestartNotify() {
    stopCountdownHideBar();
    countdownToHideBar();
  }

  void onVisibilityNotifierChanged() {
    if (widget.visibilityNotifier.value) {
      countdownToHideBar();
    } else {
      stopCountdownHideBar();
    }
  }

  void countdownToHideBar() {
    if (!widget.config.bottomMenuBar.hideAutomatically) {
      return;
    }

    hideTimerOfMenuBar?.cancel();
    hideTimerOfMenuBar = Timer(Duration(seconds: widget.autoHideSeconds), () {
      widget.visibilityNotifier.value = false;
    });
  }

  void stopCountdownHideBar() {
    hideTimerOfMenuBar?.cancel();
  }

  Widget buttonWrapper({required Widget child}) {
    return SizedBox(
      width: widget.buttonSize.width,
      height: widget.buttonSize.height,
      child: child,
    );
  }

  List<Widget> getDefaultButtons(
    BuildContext context, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    if (widget.config.bottomMenuBar.buttons.isEmpty) {
      return [];
    }

    return widget.config.bottomMenuBar.buttons
        .map((buttonName) => buttonWrapper(
              child: generateDefaultButtonsByEnum(
                context,
                buttonName,
                cameraDefaultValueFunc: cameraDefaultValueFunc,
                microphoneDefaultValueFunc: microphoneDefaultValueFunc,
              ),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoCallMenuBarButtonName buttonName, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    final buttonSize = Size(96.zR, 96.zR);
    final iconSize = Size(56.zR, 56.zR);

    switch (buttonName) {
      case ZegoCallMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: microphoneDefaultValueFunc?.call() ??
              widget.config.turnOnMicrophoneWhenJoining,
        );
      case ZegoCallMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
        );
      case ZegoCallMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: cameraDefaultValueFunc?.call() ??
              widget.config.turnOnCameraWhenJoining,
        );
      case ZegoCallMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoCallMenuBarButtonName.hangUpButton:
        return ZegoLeaveButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          clickableNotifier: hangupButtonClickableNotifier,
          onLeaveConfirmation: (context) async {
            /// prevent controller's hangUp function call after leave button click
            widget.isHangUpRequestingNotifier?.value = true;

            final hangUpConfirmationEvent = ZegoCallHangUpConfirmationEvent(
              context: context,
            );
            defaultAction() async {
              return widget
                  .defaultHangUpConfirmationAction(hangUpConfirmationEvent);
            }

            var canHangUp = true;
            if (widget.events.onHangUpConfirmation != null) {
              canHangUp = await widget.events.onHangUpConfirmation?.call(
                    hangUpConfirmationEvent,
                    defaultAction,
                  ) ??
                  true;
            } else {
              canHangUp = await defaultAction.call();
            }
            if (!canHangUp) {
              /// restore controller's leave status
              widget.isHangUpRequestingNotifier?.value = false;
            }
            return canHangUp;
          },
          onPress: () async {
            ZegoLoggerService.logInfo(
              'restore mini state by hang up',
              tag: 'call',
              subTag: 'bottom bar',
            );
            ZegoCallMiniOverlayMachine().changeState(
              ZegoCallMiniOverlayPageState.idle,
            );

            await ZegoUIKitPrebuiltCallInvitationService()
                .private
                .clearInvitation();

            final callEndEvent = ZegoCallEndEvent(
              callID: widget.minimizeData.callID,
              reason: ZegoCallEndReason.localHangUp,
              isFromMinimizing: ZegoCallMiniOverlayPageState.minimizing ==
                  ZegoUIKitPrebuiltCallController().minimize.state,
            );
            defaultAction() {
              widget.defaultEndAction(callEndEvent);
            }

            if (widget.events.onCallEnd != null) {
              widget.events.onCallEnd!.call(callEndEvent, defaultAction);
            } else {
              defaultAction.call();
            }

            /// restore controller's leave status
            widget.isHangUpRequestingNotifier?.value = false;
          },
        );
      case ZegoCallMenuBarButtonName.showMemberListButton:
        return ZegoCallMemberListButton(
          config: widget.config.memberList,
          avatarBuilder: widget.config.avatarBuilder,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoCallMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
        );
      case ZegoCallMenuBarButtonName.minimizingButton:
        return ZegoCallMinimizingButton(
          rootNavigator: widget.config.rootNavigator,
        );
      case ZegoCallMenuBarButtonName.beautyEffectButton:
        return ZegoCallBeautyEffectButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          rootNavigator: widget.config.rootNavigator,
        );
      case ZegoCallMenuBarButtonName.chatButton:
        return ZegoCallInRoomMessageButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          avatarBuilder: widget.config.avatarBuilder,
          itemBuilder: widget.config.chatView.itemBuilder,
          viewVisibleNotifier: widget.chatViewVisibleNotifier,
          popUpManager: widget.popUpManager,
        );
      case ZegoCallMenuBarButtonName.soundEffectButton:
        return ZegoCallSoundEffectButton(
          effectConfig: widget.config.audioEffect,
          translationText: widget.config.translationText,
          voiceChangeEffect: widget.config.audioEffect.voiceChangeEffect,
          reverbEffect: widget.config.audioEffect.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
          rootNavigator: widget.config.rootNavigator,
          popUpManager: widget.popUpManager,
        );
    }
  }

  void oHangUpRequestingChanged() {
    hangupButtonClickableNotifier.value =
        !(widget.isHangUpRequestingNotifier?.value ?? false);
  }
}
