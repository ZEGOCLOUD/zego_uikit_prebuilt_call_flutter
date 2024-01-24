// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/member/member_list_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/message/in_room_message_button.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_button.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// @nodoc
class ZegoBottomMenuBar extends StatefulWidget {
  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final void Function(ZegoUIKitCallEndEvent event) defaultEndAction;
  final Future<bool> Function(ZegoUIKitCallHangUpConfirmationEvent event)
      defaultHangUpConfirmationAction;

  final Size buttonSize;
  final ValueNotifier<bool> visibilityNotifier;
  final int autoHideSeconds;
  final ValueNotifier<int> restartHideTimerNotifier;
  final ValueNotifier<bool>? isHangUpRequestingNotifier;

  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;

  final ZegoUIKitPrebuiltCallMinimizeData minimizeData;

  final ValueNotifier<bool> chatViewVisibleNotifier;
  final ZegoPopUpManager popUpManager;

  const ZegoBottomMenuBar({
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
  State<ZegoBottomMenuBar> createState() => _ZegoBottomMenuBarState();
}

/// @nodoc
class _ZegoBottomMenuBarState extends State<ZegoBottomMenuBar> {
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
        margin: widget.config.bottomMenuBarConfig.margin,
        padding: widget.config.bottomMenuBarConfig.padding,
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
      ...widget.config.bottomMenuBarConfig.extendButtons
          .map((extendButton) => buttonWrapper(child: extendButton))
    ];

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
          0, widget.config.bottomMenuBarConfig.maxCount - 1)
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
                ...widget.config.bottomMenuBarConfig.extendButtons
                    .map((extendButton) => buttonWrapper(child: extendButton))
              ]..removeRange(
                  0,
                  widget.config.bottomMenuBarConfig.maxCount - 1,
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
    if (!widget.config.bottomMenuBarConfig.hideAutomatically) {
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
    if (widget.config.bottomMenuBarConfig.buttons.isEmpty) {
      return [];
    }

    return widget.config.bottomMenuBarConfig.buttons
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
    ZegoMenuBarButtonName buttonName, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    final buttonSize = Size(96.zR, 96.zR);
    final iconSize = Size(56.zR, 56.zR);

    switch (buttonName) {
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: microphoneDefaultValueFunc?.call() ??
              widget.config.turnOnMicrophoneWhenJoining,
        );
      case ZegoMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
        );
      case ZegoMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: cameraDefaultValueFunc?.call() ??
              widget.config.turnOnCameraWhenJoining,
        );
      case ZegoMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoMenuBarButtonName.hangUpButton:
        return ZegoLeaveButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          clickableNotifier: hangupButtonClickableNotifier,
          onLeaveConfirmation: (context) async {
            /// prevent controller's hangUp function call after leave button click
            widget.isHangUpRequestingNotifier?.value = true;

            final hangUpConfirmationEvent =
                ZegoUIKitCallHangUpConfirmationEvent(
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
          onPress: () {
            ZegoLoggerService.logInfo(
              'restore mini state by hang up',
              tag: 'call',
              subTag: 'bottom bar',
            );
            ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
              PrebuiltCallMiniOverlayPageState.idle,
            );

            final callEndEvent = ZegoUIKitCallEndEvent(
              reason: ZegoUIKitCallEndReason.localHangUp,
              isFromMinimizing: PrebuiltCallMiniOverlayPageState.minimizing ==
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
      case ZegoMenuBarButtonName.showMemberListButton:
        return ZegoMemberListButton(
          config: widget.config.memberListConfig,
          avatarBuilder: widget.config.avatarBuilder,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
      case ZegoMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
        );
      case ZegoMenuBarButtonName.minimizingButton:
        return ZegoMinimizingButton(
          rootNavigator: widget.config.rootNavigator,
        );
      case ZegoMenuBarButtonName.beautyEffectButton:
        return ZegoBeautyEffectButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          rootNavigator: widget.config.rootNavigator,
        );
      case ZegoMenuBarButtonName.chatButton:
        return ZegoInRoomMessageButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          avatarBuilder: widget.config.avatarBuilder,
          itemBuilder: widget.config.chatViewConfig.itemBuilder,
          viewVisibleNotifier: widget.chatViewVisibleNotifier,
          popUpManager: widget.popUpManager,
        );
    }
  }

  void oHangUpRequestingChanged() {
    hangupButtonClickableNotifier.value =
        !(widget.isHangUpRequestingNotifier?.value ?? false);
  }
}
