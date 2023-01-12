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
import 'assets.dart';
import 'member/member_list_button.dart';

class ZegoTopMenuBar extends StatefulWidget {
  final ZegoUIKitPrebuiltCallConfig config;
  final Size buttonSize;
  final ValueNotifier<bool> visibilityNotifier;
  final int autoHideSeconds;
  final ValueNotifier<int> restartHideTimerNotifier;

  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;

  const ZegoTopMenuBar({
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
  State<ZegoTopMenuBar> createState() => _ZegoTopMenuBarState();
}

class _ZegoTopMenuBarState extends State<ZegoTopMenuBar> {
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
      endOffset: const Offset(0.0, -2.0),
      child: Container(
        height: widget.height ?? (widget.buttonSize.height + 2 * 3),
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
          width: 27.r,
        ),
        Text(
          widget.config.topMenuBarConfig.title,
          style: TextStyle(
              color: Colors.white, fontSize: 36.r, fontWeight: FontWeight.w500),
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
          width: 27.r,
        )
      ],
    );
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    var buttons = [
      ...getDefaultButtons(context),
      ...widget.config.topMenuBarConfig.extendButtons
          .map((extendButton) => buttonWrapper(child: extendButton))
    ];

    /// limited item count display on menu bar,
    /// if this count is exceeded, Trim down the extra buttons
    const int maxCount = 3;
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
    if (!widget.config.topMenuBarConfig.hideAutomatically) {
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

  List<Widget> getDefaultButtons(BuildContext context) {
    if (widget.config.topMenuBarConfig.buttons.isEmpty) {
      return [];
    }

    return widget.config.topMenuBarConfig.buttons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(context, type),
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
      BuildContext context, ZegoMenuBarButtonName type) {
    final buttonSize = Size(70.r, 70.r);
    final iconSize = Size(64.r, 64.r);

    switch (type) {
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
        return ZegoToggleMicrophoneButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultOn: widget.config.turnOnMicrophoneWhenJoining,
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
          defaultOn: widget.config.turnOnCameraWhenJoining,
        );
      case ZegoMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon:
                PrebuiltCallImage.asset(PrebuiltCallIconUrls.topCameraOverturn),
            backgroundColor: Colors.transparent,
          ),
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoMenuBarButtonName.hangUpButton:
        return ZegoLeaveButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(backgroundColor: Colors.transparent),
          onLeaveConfirmation: (context) async {
            return await widget.config.onHangUpConfirmation!(context);
          },
          onPress: () {
            if (widget.config.onHangUp != null) {
              widget.config.onHangUp!.call();
            } else {
              /// default behaviour if hand up is null, back to previous page
              Navigator.of(context).pop();
            }
          },
        );
      case ZegoMenuBarButtonName.showMemberListButton:
        return ZegoMemberListButton(
          config: widget.config.memberListConfig,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: PrebuiltCallImage.asset(PrebuiltCallIconUrls.topMemberNormal),
            backgroundColor: Colors.transparent,
          ),
        );
    }
  }
}
