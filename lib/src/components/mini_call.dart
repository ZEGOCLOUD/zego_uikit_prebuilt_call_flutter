// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/assets.dart';

/// @nodoc
class ZegoMinimizingCallPage extends StatefulWidget {
  const ZegoMinimizingCallPage({
    Key? key,
    required this.size,
    required this.durationNotifier,
    this.borderRadius = 6.0,
    this.borderColor,
    this.padding = 0.0,
    this.durationVisible = true,
    this.withCircleBorder = true,
    this.showDevices = true,
    this.showUserName = true,
    this.showLeaveButton = true,
    this.showCameraButton = true,
    this.showMicrophoneButton = true,
    this.soundWaveColor = const Color(0xff2254f6),
    this.leaveButtonIcon,
    this.foreground,
    this.background,
    this.builder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
  }) : super(key: key);

  final Size size;
  final double padding;
  final double borderRadius;
  final Color? borderColor;
  final bool withCircleBorder;
  final bool durationVisible;
  final bool showDevices;
  final bool showUserName;
  final bool showLeaveButton;
  final bool showCameraButton;
  final bool showMicrophoneButton;
  final Widget? leaveButtonIcon;

  final Color soundWaveColor;
  final Widget? foreground;
  final Widget? background;
  final Widget Function(ZegoUIKitUser? activeUser)? builder;

  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarBuilder? avatarBuilder;

  final ValueNotifier<Duration> durationNotifier;

  @override
  State<ZegoMinimizingCallPage> createState() => _ZegoMinimizingCallPageState();
}

/// @nodoc
class _ZegoMinimizingCallPageState extends State<ZegoMinimizingCallPage> {
  final activeUserIDNotifier = ValueNotifier<String?>(null);

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final Map<String, List<double>> rangeSoundLevels = {};
  bool infoDelayRendered = false;

  Size get buttonArea => Size(widget.size.width * 0.3, widget.size.width * 0.3);

  Size get buttonSize => Size(widget.size.width * 0.2, widget.size.width * 0.2);

  @override
  void initState() {
    super.initState();

    listenAudioVideoList();
    activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateActiveUserByTimer();
    });
  }

  @override
  void dispose() {
    super.dispose();

    audioVideoListSubscription?.cancel();
    activeUserTimer?.cancel();
    activeUserTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: activeUserIDNotifier,
      builder: (context, activeUserID, _) {
        final activeUser = ZegoUIKit().getUser(activeUserID ?? '');
        return widget.withCircleBorder
            ? circleBorder(
                child: minimizingUserWidget(activeUser),
              )
            : minimizingUserWidget(activeUser);
      },
    );
  }

  Widget circleBorder({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      child: PhysicalModel(
        color: widget.borderColor ?? const Color(0xffA4A4A4),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: Colors.black,
        child: child,
      ),
    );
  }

  Widget pureAudioVideoWidget(ZegoUIKitUser? activeUser) {
    return ZegoAudioVideoView(
      user: activeUser,
      foregroundBuilder: widget.foregroundBuilder,
      backgroundBuilder: widget.backgroundBuilder,
      avatarConfig: ZegoAvatarConfig(
        builder: widget.avatarBuilder,
        soundWaveColor: widget.soundWaveColor,
      ),
    );
  }

  Widget userInfoAudioVideoWidget(ZegoUIKitUser? activeUser) {
    return Stack(
      children: [
        widget.background ?? Container(),
        ZegoAudioVideoView(
          user: activeUser,
          foregroundBuilder: widget.foregroundBuilder,
          backgroundBuilder: widget.backgroundBuilder,
          avatarConfig: ZegoAvatarConfig(
            builder: widget.avatarBuilder,
            soundWaveColor: widget.soundWaveColor,
          ),
        ),
        devices(activeUser),
        userName(activeUser),
        durationTimeBoard(),
        widget.foreground ?? Container(),
        widget.showLeaveButton
            ? Positioned(
                top: 10.zR,
                right: 10.zR,
                child: leaveButton(),
              )
            : Container(),
      ],
    );
  }

  Widget minimizingUserWidget(ZegoUIKitUser? activeUser) {
    return widget.builder?.call(activeUser) ??
        (!infoDelayRendered
            ? FutureBuilder<bool>(
                future: Future.delayed(
                  const Duration(milliseconds: 1000),
                  () => true,
                ),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return pureAudioVideoWidget(activeUser);
                  }

                  infoDelayRendered = true;
                  return userInfoAudioVideoWidget(activeUser);
                },
              )
            : userInfoAudioVideoWidget(activeUser));
  }

  Widget leaveButton() {
    return ZegoTextIconButton(
      buttonSize: buttonArea,
      iconSize: buttonSize,
      icon: ButtonIcon(
        icon: widget.leaveButtonIcon ??
            Image(
              image: ZegoCallImage.asset(
                InvitationStyleIconUrls.toolbarBottomCancel,
              ).image,
              fit: BoxFit.fill,
            ),
        backgroundColor: Colors.white,
      ),
      onPressed: () async {
        await ZegoUIKitPrebuiltCallController.instance.hangUp(
          context,
          showConfirmation: false,
        );
      },
    );
  }

  Widget userName(ZegoUIKitUser? activeUser) {
    return widget.showUserName
        ? Positioned(
            left: 2,
            top: 10.zH + widget.size.width * 0.07,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.black.withOpacity(0.2),
              ),
              width: widget.size.width / 3 * 2,
              child: Text(
                activeUser?.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.size.width * 0.08,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget durationTimeBoard() {
    if (!widget.durationVisible) {
      return Container();
    }

    return Positioned(
      left: 0,
      right: 0,
      top: 1,
      child: ZegoCallDurationTimeBoard(
        durationNotifier: widget.durationNotifier,
        fontSize: widget.size.width * 0.07,
      ),
    );
  }

  Widget devices(ZegoUIKitUser? activeUser) {
    if (null == activeUser) {
      return Container();
    }

    if (!widget.showDevices) {
      return Container();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (widget.showCameraButton) cameraControl(activeUser),
          if (widget.showMicrophoneButton) microphoneControl(activeUser),
        ],
      ),
    );
  }

  Widget cameraControl(ZegoUIKitUser activeUser) {
    const toolbarCameraNormal = 'assets/icons/s1_ctrl_bar_camera_normal.png';
    const toolbarCameraOff = 'assets/icons/s1_ctrl_bar_camera_off.png';

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getCameraStateNotifier(activeUser.id),
      builder: (context, isCameraEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit()
                      .turnCameraOn(!isCameraEnabled, userID: activeUser.id);
                }
              : null,
          child: Container(
            width: buttonArea.width,
            height: buttonArea.height,
            decoration: BoxDecoration(
              color: isCameraEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: buttonSize.width,
                height: buttonSize.height,
                child: uikitImage(
                  isCameraEnabled ? toolbarCameraNormal : toolbarCameraOff,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget microphoneControl(ZegoUIKitUser activeUser) {
    const toolbarMicNormal = 'assets/icons/s1_ctrl_bar_mic_normal.png';
    const toolbarMicOff = 'assets/icons/s1_ctrl_bar_mic_off.png';

    return ValueListenableBuilder<bool>(
      valueListenable: ZegoUIKit().getMicrophoneStateNotifier(activeUser.id),
      builder: (context, isMicrophoneEnabled, _) {
        return GestureDetector(
          onTap: activeUser.id == ZegoUIKit().getLocalUser().id
              ? () {
                  ZegoUIKit().turnMicrophoneOn(!isMicrophoneEnabled,
                      userID: activeUser.id);
                }
              : null,
          child: Container(
            width: buttonArea.width,
            height: buttonArea.height,
            decoration: BoxDecoration(
              color: isMicrophoneEnabled
                  ? controlBarButtonCheckedBackgroundColor
                  : controlBarButtonBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: buttonSize.width,
                height: buttonSize.height,
                child: uikitImage(
                  isMicrophoneEnabled ? toolbarMicNormal : toolbarMicOff,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void listenAudioVideoList() {
    audioVideoListSubscription =
        ZegoUIKit().getAudioVideoListStream().listen(onAudioVideoListUpdated);

    onAudioVideoListUpdated(ZegoUIKit().getAudioVideoList());
    activeUserIDNotifier.value = ZegoUIKit().getAudioVideoList().isEmpty
        ? ZegoUIKit().getLocalUser().id
        : ZegoUIKit().getAudioVideoList().first.id;
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    for (final subscription in soundLevelSubscriptions) {
      subscription?.cancel();
    }
    rangeSoundLevels.clear();

    for (final user in users) {
      soundLevelSubscriptions.add(user.soundLevel.listen((soundLevel) {
        if (rangeSoundLevels.containsKey(user.id)) {
          rangeSoundLevels[user.id]!.add(soundLevel);
        } else {
          rangeSoundLevels[user.id] = [soundLevel];
        }
      }));
    }
  }

  void updateActiveUserByTimer() {
    var maxAverageSoundLevel = 0.0;
    var activeUserID = '';
    rangeSoundLevels.forEach((userID, soundLevels) {
      final averageSoundLevel =
          soundLevels.reduce((a, b) => a + b) / soundLevels.length;

      if (averageSoundLevel > maxAverageSoundLevel) {
        activeUserID = userID;
        maxAverageSoundLevel = averageSoundLevel;
      }
    });
    activeUserIDNotifier.value = activeUserID;
    if (activeUserIDNotifier.value?.isEmpty ?? true) {
      activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
    }

    rangeSoundLevels.clear();
  }

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
