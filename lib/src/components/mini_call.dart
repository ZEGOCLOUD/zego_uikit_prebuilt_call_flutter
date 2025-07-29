// Dart imports:
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/controller/private/pip/pip_ios.dart';
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
    this.showLocalUserView = true,
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
  final bool showLocalUserView;
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
  bool infoDelayRendered = false;

  final pipLayoutUserListNotifier = ValueNotifier<List<ZegoUIKitUser>>([]);

  Size get buttonArea => Size(widget.size.width * 0.2, widget.size.width * 0.2);

  Size get buttonSize => Size(widget.size.width * 0.1, widget.size.width * 0.1);

  bool get playingStreamInPIPUnderIOS {
    bool isPlaying = false;
    if (Platform.isIOS) {
      isPlaying = (ZegoUIKitPrebuiltCallController().pip.private.pipImpl()
              as ZegoCallControllerIOSPIP)
          .isSupportInConfig;
    }

    return isPlaying;
  }

  @override
  void initState() {
    super.initState();

    ZegoUIKitPrebuiltCallController().minimize.private.activeUser.start(
          showLocalUserView: widget.showLocalUserView,
        );
  }

  @override
  void dispose() {
    super.dispose();

    ZegoUIKitPrebuiltCallController().minimize.private.activeUser.stop();
  }

  @override
  Widget build(BuildContext context) {
    final view = ValueListenableBuilder<String?>(
      valueListenable: ZegoUIKitPrebuiltCallController()
          .minimize
          .private
          .activeUser
          .activeUserIDNotifier,
      builder: (context, activeUserID, _) {
        return audioVideoContainer(
          activeUserID ?? ZegoUIKit().getLocalUser().id,
        );
      },
    );

    return widget.withCircleBorder ? circleBorder(child: view) : view;
  }

  Widget audioVideoContainer(String activeUserID) {
    final avList = ZegoUIKit().getAudioVideoList();
    if (!widget.showLocalUserView) {
      avList.removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    var displayWidthFactor = avList.length.toDouble();
    if (avList.length >= 3) {
      displayWidthFactor = 4.0;
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final smallViewWidth = constraints.maxWidth / displayWidthFactor;
        final smallViewHeight = 16.0 / 9.0 * smallViewWidth;

        return Stack(
          children: [
            widget.background ?? Container(),
            IgnorePointer(
              ignoring: true,
              child: ZegoAudioVideoContainer(
                layout: ZegoLayout.pictureInPicture(
                  smallViewPosition: ZegoViewPosition.bottomLeft,
                  smallViewMargin: EdgeInsets.only(
                    left: 10.zR,
                    top: 10.zR,
                    right: 10.zR,
                    bottom: 15.zR,
                  ),
                  smallViewSize: Size(smallViewWidth, smallViewHeight),
                  isSmallViewDraggable: false,
                  switchLargeOrSmallViewByClick: true,
                  isSmallViewsScrollable: false,
                  bigViewUserID: activeUserID,
                ),
                filterAudioVideo: (List<ZegoUIKitUser> users) {
                  if (!widget.showLocalUserView) {
                    users.removeWhere(
                        (user) => user.id == ZegoUIKit().getLocalUser().id);
                  }

                  return users;
                },
                avatarConfig: ZegoAvatarConfig(
                  builder: widget.avatarBuilder,
                  soundWaveColor: widget.soundWaveColor,
                ),
                foregroundBuilder: (
                  BuildContext context,
                  Size size,
                  ZegoUIKitUser? user,

                  /// {ZegoViewBuilderMapExtraInfoKey:value}
                  /// final value = extraInfo[ZegoViewBuilderMapExtraInfoKey.key.name]
                  Map<String, dynamic> extraInfo,
                ) {
                  if (playingStreamInPIPUnderIOS) {
                    /// not support if ios pip, platform view will be render wrong user
                    /// after changed
                    return Container();
                  }

                  final isActiveUser = activeUserID == user?.id;
                  return Stack(
                    children: [
                      if (isActiveUser) devices(user),
                      userName(user, alignCenter: !isActiveUser),
                    ],
                  );
                },
                backgroundBuilder: widget.backgroundBuilder,
                onUserListUpdated: (List<ZegoUIKitUser> userList) {
                  pipLayoutUserListNotifier.value = userList;
                },
              ),
            ),
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

  Widget minimizingUserWidget(ZegoUIKitUser? targetUser) {
    return widget.builder?.call(targetUser) ??
        Stack(
          children: [
            widget.background ?? Container(),
            ZegoAudioVideoView(
              user: targetUser,
              foregroundBuilder: widget.foregroundBuilder,
              backgroundBuilder: widget.backgroundBuilder,
              avatarConfig: ZegoAvatarConfig(
                builder: widget.avatarBuilder,
                soundWaveColor: widget.soundWaveColor,
              ),
            ),
            devices(targetUser),
            userName(targetUser),
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

  Widget leaveButton() {
    return ZegoTextIconButton(
      buttonSize: Size(widget.size.width * 0.4, widget.size.width * 0.4),
      iconSize: Size(widget.size.width * 0.2, widget.size.width * 0.2),
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

  Widget userName(
    ZegoUIKitUser? activeUser, {
    bool alignCenter = false,
  }) {
    return widget.showUserName
        ? Positioned(
            left: alignCenter ? 0 : null,
            right: alignCenter ? 0 : 2.zW,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.black.withValues(alpha: 0.2),
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
      bottom: buttonArea.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.showCameraButton) ...[
            cameraControl(activeUser),
            SizedBox(width: 10.zR),
          ],
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

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
