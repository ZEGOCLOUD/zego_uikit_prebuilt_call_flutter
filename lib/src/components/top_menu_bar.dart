// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
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
class ZegoCallTopMenuBar extends StatefulWidget {
  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final void Function(ZegoCallEndEvent event) defaultEndAction;
  final Future<bool> Function(ZegoCallHangUpConfirmationEvent event)
      defaultHangUpConfirmationAction;

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

  const ZegoCallTopMenuBar({
    Key? key,
    required this.config,
    required this.events,
    required this.defaultEndAction,
    required this.defaultHangUpConfirmationAction,
    required this.visibilityNotifier,
    required this.restartHideTimerNotifier,
    required this.isHangUpRequestingNotifier,
    required this.chatViewVisibleNotifier,
    required this.popUpManager,
    required this.minimizeData,
    this.autoHideSeconds = 3,
    this.height,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ZegoCallTopMenuBar> createState() => _ZegoCallTopMenuBarState();
}

/// @nodoc
class _ZegoCallTopMenuBarState extends State<ZegoCallTopMenuBar> {
  Timer? hideTimerOfMenuBar;

  final hangupButtonClickableNotifier = ValueNotifier<bool>(true);

  double get defaultHeight => 96.zR;

  double get height => widget.height ?? defaultHeight;

  Size get buttonDisplaySize => Size(height, height);

  double get buttonHeightRatio => 0.8;

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
      endOffset: const Offset(0.0, -2.0),
      child: Container(
        margin: widget.config.topMenuBar.margin,
        padding: widget.config.topMenuBar.padding,
        height: height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius ?? 0),
            topRight: Radius.circular(widget.borderRadius ?? 0),
          ),
        ),
        child: Row(
          children: [
            title(),
            Expanded(child: Container()),
            rightBar(),
          ],
        ),
      ),
    );
  }

  Widget title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 27.zR,
        ),
        Text(
          widget.config.topMenuBar.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36.zR,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget rightBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...getDisplayButtons(context),
        SizedBox(
          width: 27.zR,
        )
      ],
    );
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    final buttons = [
      ...getDefaultButtons(context),
      ...widget.config.topMenuBar.extendButtons
          .map((extendButton) => buttonWrapper(
                child: extendButton,
                withRoomUpdateNotifier: true,
              ))
    ];

    /// limited item count display on menu bar,
    /// if this count is exceeded, Trim down the extra buttons
    const maxCount = 3;
    if (buttons.length > maxCount) {
      return buttons.sublist(0, maxCount);
    }

    return buttons;
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
    if (!widget.config.topMenuBar.hideAutomatically) {
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

  Widget buttonWrapper({
    required Widget child,
    bool withRoomUpdateNotifier = false,
  }) {
    final button = Container(
      padding: EdgeInsets.fromLTRB(0, 0, 10.zR, 0),
      width: buttonDisplaySize.width,
      height: buttonDisplaySize.height,
      child: child,
    );

    return withRoomUpdateNotifier
        ? ValueListenableBuilder<ZegoUIKitRoomState>(
            valueListenable: ZegoUIKit().getRoomStateStream(),
            builder: (context, roomState, _) {
              if (roomState.reason != ZegoRoomStateChangedReason.Logined) {
                return const SizedBox();
              }

              return button;
            })
        : button;
  }

  List<Widget> getDefaultButtons(BuildContext context) {
    if (widget.config.topMenuBar.buttons.isEmpty) {
      return [];
    }

    return widget.config.topMenuBar.buttons
        .map((buttonName) => buttonWrapper(
              child: generateDefaultButtonsByEnum(context, buttonName),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoCallMenuBarButtonName buttonName,
  ) {
    final buttonSize = buttonDisplaySize;
    final iconSize = buttonDisplaySize * buttonHeightRatio;

    switch (buttonName) {
      case ZegoCallMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: widget.config.turnOnMicrophoneWhenJoining,
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
          defaultOn: widget.config.turnOnCameraWhenJoining,
        );
      case ZegoCallMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: ZegoCallImage.asset(ZegoCallIconUrls.topCameraOverturn),
            backgroundColor: Colors.transparent,
          ),
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoCallMenuBarButtonName.hangUpButton:
        return ZegoLeaveButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(backgroundColor: Colors.transparent),
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
              subTag: 'top bar',
            );
            ZegoCallMiniOverlayMachine()
                .changeState(ZegoCallMiniOverlayPageState.idle);

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
          rootNavigator: widget.config.rootNavigator,
          avatarBuilder: widget.config.avatarBuilder,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: ZegoCallImage.asset(ZegoCallIconUrls.topMemberNormal),
          ),
        );
      case ZegoCallMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
        );
      case ZegoCallMenuBarButtonName.minimizingButton:
        return ZegoCallMinimizingButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
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
          icon: ButtonIcon(
            icon: ZegoCallImage.asset(ZegoCallIconUrls.topMemberIM),
            backgroundColor: Colors.transparent,
          ),
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
