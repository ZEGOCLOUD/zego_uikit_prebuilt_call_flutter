// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_defines.dart';
import 'member/member_list_button.dart';

class ZegoBottomMenuBar extends StatefulWidget {
  final ZegoUIKitPrebuiltCallConfig config;
  final Size buttonSize;
  final ValueNotifier<bool> visibilityNotifier;
  final int autoHideSeconds;
  final ValueNotifier<int> restartHideTimerNotifier;

  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;

  const ZegoBottomMenuBar({
    Key? key,
    required this.config,
    required this.visibilityNotifier,
    required this.restartHideTimerNotifier,
    this.autoHideSeconds = 3,
    this.buttonSize = const Size(60, 60),
    this.height,
    this.borderRadius,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<ZegoBottomMenuBar> createState() => _ZegoBottomMenuBarState();
}

class _ZegoBottomMenuBarState extends State<ZegoBottomMenuBar> {
  Timer? hideTimerOfMenuBar;

  @override
  void initState() {
    super.initState();

    countdownToHideBar();
    widget.restartHideTimerNotifier.addListener(onHideTimerRestartNotify);

    widget.visibilityNotifier.addListener(onVisibilityNotifierChanged);
  }

  @override
  void dispose() {
    stopCountdownHideBar();
    widget.restartHideTimerNotifier.removeListener(onHideTimerRestartNotify);

    widget.visibilityNotifier.removeListener(onVisibilityNotifierChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueNotifierSliderVisibility(
      visibilityNotifier: widget.visibilityNotifier,
      child: Container(
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
    List<Widget> buttonList = [
      ...getDefaultButtons(context),
      ...widget.config.bottomMenuBarConfig.extendButtons
          .map((extendButton) => buttonWrapper(child: extendButton))
    ];

    List<Widget> displayButtonList = [];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList =
          buttonList.sublist(0, widget.config.bottomMenuBarConfig.maxCount - 1);

      displayButtonList.add(
        buttonWrapper(
          child: ZegoMoreButton(menuButtonListFunc: () {
            List<Widget> buttonList = [
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
            ];

            buttonList.removeRange(
                0, widget.config.bottomMenuBarConfig.maxCount - 1);

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
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(
                context,
                type,
                cameraDefaultValueFunc: cameraDefaultValueFunc,
                microphoneDefaultValueFunc: microphoneDefaultValueFunc,
              ),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoMenuBarButtonName type, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    final buttonSize = Size(96.r, 96.r);
    final iconSize = Size(56.r, 56.r);

    switch (type) {
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
          onLeaveConfirmation: (context) async {
            return await widget.config.onHangUpConfirmation!(context);
          },
          onPress: () {
            if (widget.config.onHangUp != null) {
              widget.config.onHangUp!.call();
            } else {
              Navigator.of(context).pop();
            }
          },
        );
      case ZegoMenuBarButtonName.showMemberListButton:
        return ZegoMemberListButton(
          config: widget.config.memberListConfig,
          buttonSize: buttonSize,
          iconSize: iconSize,
        );
    }
  }
}
