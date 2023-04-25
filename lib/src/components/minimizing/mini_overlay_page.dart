// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// @deprecated Use ZegoUIKitPrebuiltCallMiniOverlayPage
typedef ZegoMiniOverlayPage = ZegoUIKitPrebuiltCallMiniOverlayPage;

class ZegoUIKitPrebuiltCallMiniOverlayPage extends StatefulWidget {
  const ZegoUIKitPrebuiltCallMiniOverlayPage({
    Key? key,
    required this.contextQuery,
    this.size,
    this.topLeft = const Offset(100, 100),
    this.borderRadius = 6.0,
    this.borderColor = Colors.black12,
    this.soundWaveColor = const Color(0xff2254f6),
    this.padding = 0.0,
    this.showDevices = true,
    this.showUserName = true,
    this.builder,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
  }) : super(key: key);

  final Size? size;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final Color soundWaveColor;
  final Offset topLeft;
  final bool showDevices;
  final bool showUserName;
  final BuildContext Function() contextQuery;

  final Widget Function(ZegoUIKitUser? activeUser)? builder;
  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarBuilder? avatarBuilder;

  @override
  ZegoUIKitPrebuiltCallMiniOverlayPageState createState() =>
      ZegoUIKitPrebuiltCallMiniOverlayPageState();
}

class ZegoUIKitPrebuiltCallMiniOverlayPageState
    extends State<ZegoUIKitPrebuiltCallMiniOverlayPage> {
  late Size itemSize;

  PrebuiltCallMiniOverlayPageState currentState =
      PrebuiltCallMiniOverlayPageState.idle;

  bool visibility = true;
  late Offset topLeft;

  StreamSubscription<dynamic>? userListStreamSubscription;

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserIDNotifier = ValueNotifier<String?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  @override
  void initState() {
    super.initState();

    topLeft = widget.topLeft;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ZegoUIKitPrebuiltCallMiniOverlayMachine()
          .listenStateChanged(onMiniOverlayMachineStateChanged);

      if (null != ZegoUIKitPrebuiltCallMiniOverlayMachine().machine.current) {
        syncState();
      }
    });

    userListStreamSubscription =
        ZegoUIKit().getUserLeaveStream().listen(onUserLeave);
  }

  @override
  void dispose() {
    super.dispose();

    activeUserTimer?.cancel();
    activeUserTimer = null;

    userListStreamSubscription?.cancel();
    audioVideoListSubscription?.cancel();

    ZegoUIKitPrebuiltCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    itemSize = calculateItemSize();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Visibility(
        visible: visibility,
        child: Positioned(
          left: topLeft.dx,
          top: topLeft.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                var x = topLeft.dx + details.delta.dx;
                var y = topLeft.dy + details.delta.dy;
                x = x.clamp(
                    0.0, MediaQuery.of(context).size.width - itemSize.width);
                y = y.clamp(
                    0.0, MediaQuery.of(context).size.height - itemSize.height);
                topLeft = Offset(x, y);
              });
            },
            child: LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                width: itemSize.width,
                height: itemSize.height,
                child: overlayItem(),
              );
            }),
          ),
        ),
      ),
    );
  }

  Size calculateItemSize() {
    if (null != widget.size) {
      return widget.size!;
    }

    final size = MediaQuery.of(context).size;
    final width = size.width / 4.0;
    final height = 16.0 / 9.0 * width;
    return Size(width, height);
  }

  Widget overlayItem() {
    switch (currentState) {
      case PrebuiltCallMiniOverlayPageState.idle:
      case PrebuiltCallMiniOverlayPageState.calling:
        return Container();
      case PrebuiltCallMiniOverlayPageState.minimizing:
        return GestureDetector(
          onTap: () {
            final prebuiltCallData =
                ZegoUIKitPrebuiltCallMiniOverlayMachine().prebuiltCallData;
            assert(null != prebuiltCallData);

            /// re-enter prebuilt call
            ZegoUIKitPrebuiltCallMiniOverlayMachine()
                .changeState(PrebuiltCallMiniOverlayPageState.calling);

            Navigator.of(widget.contextQuery(), rootNavigator: true).push(
              MaterialPageRoute(builder: (context) {
                return SafeArea(
                  child: ZegoUIKitPrebuiltCall(
                    appID: prebuiltCallData!.appID,
                    appSign: prebuiltCallData.appSign,
                    userID: prebuiltCallData.userID,
                    userName: prebuiltCallData.userName,
                    callID: prebuiltCallData.callID,
                    config: prebuiltCallData.config,
                    onDispose: prebuiltCallData.onDispose,
                    controller: prebuiltCallData.controller,
                  ),
                );
              }),
            );
          },
          child: ValueListenableBuilder<String?>(
            valueListenable: activeUserIDNotifier,
            builder: (context, activeUserID, _) {
              final activeUser = ZegoUIKit().getUser(activeUserID ?? '');
              return circleBorder(
                child: minimizingUserWidget(activeUser),
              );
            },
          ),
        );
    }
  }

  Widget minimizingUserWidget(ZegoUIKitUser? activeUser) {
    return widget.builder?.call(activeUser) ??
        Stack(
          children: [
            ZegoAudioVideoView(
              user: activeUser,
              foregroundBuilder: widget.foregroundBuilder,
              backgroundBuilder: widget.backgroundBuilder,
              avatarConfig: ZegoAvatarConfig(
                builder: widget.avatarBuilder ??
                    ZegoUIKitPrebuiltCallMiniOverlayMachine()
                        .prebuiltCallData
                        ?.config
                        .avatarBuilder,
                soundWaveColor: widget.soundWaveColor,
              ),
            ),
            devices(activeUser),
            userName(activeUser),
          ],
        );
  }

  Widget userName(ZegoUIKitUser? activeUser) {
    return widget.showUserName
        ? Positioned(
            right: 5,
            top: 5,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.black.withOpacity(0.2),
              ),
              width: itemSize.width / 3 * 2,
              child: Text(
                activeUser?.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: itemSize.width * 0.1,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget circleBorder({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      child: PhysicalModel(
        color: const Color(0xffA4A4A4),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: Colors.black,
        child: child,
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

    const toolbarCameraNormal = 'assets/icons/s1_ctrl_bar_camera_normal.png';
    const toolbarCameraOff = 'assets/icons/s1_ctrl_bar_camera_off.png';
    const toolbarMicNormal = 'assets/icons/s1_ctrl_bar_mic_normal.png';
    const toolbarMicOff = 'assets/icons/s1_ctrl_bar_mic_off.png';
    return Positioned(
      left: 0,
      right: 0,
      bottom: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: ZegoUIKit().getCameraStateNotifier(activeUser.id),
            builder: (context, isCameraEnabled, _) {
              return GestureDetector(
                onTap: activeUser.id == ZegoUIKit().getLocalUser().id
                    ? () {
                        ZegoUIKit().turnCameraOn(!isCameraEnabled,
                            userID: activeUser.id);
                      }
                    : null,
                child: Container(
                  width: itemSize.width * 0.3,
                  height: itemSize.width * 0.3,
                  decoration: BoxDecoration(
                    color: isCameraEnabled
                        ? controlBarButtonCheckedBackgroundColor
                        : controlBarButtonBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: itemSize.width * 0.2,
                      height: itemSize.width * 0.2,
                      child: uikitImage(
                        isCameraEnabled
                            ? toolbarCameraNormal
                            : toolbarCameraOff,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable:
                ZegoUIKit().getMicrophoneStateNotifier(activeUser.id),
            builder: (context, isMicrophoneEnabled, _) {
              return GestureDetector(
                onTap: activeUser.id == ZegoUIKit().getLocalUser().id
                    ? () {
                        ZegoUIKit().turnMicrophoneOn(!isMicrophoneEnabled,
                            userID: activeUser.id);
                      }
                    : null,
                child: Container(
                  width: itemSize.width * 0.3,
                  height: itemSize.width * 0.3,
                  decoration: BoxDecoration(
                    color: isMicrophoneEnabled
                        ? controlBarButtonCheckedBackgroundColor
                        : controlBarButtonBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: itemSize.width * 0.2,
                      height: itemSize.width * 0.2,
                      child: uikitImage(
                        isMicrophoneEnabled ? toolbarMicNormal : toolbarMicOff,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  void syncState() {
    setState(() {
      currentState = ZegoUIKitPrebuiltCallMiniOverlayMachine().state();
      visibility = currentState == PrebuiltCallMiniOverlayPageState.minimizing;

      if (visibility) {
        listenAudioVideoList();
        activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          updateActiveUserByTimer();
        });
      } else {
        audioVideoListSubscription?.cancel();
        activeUserTimer?.cancel();
        activeUserTimer = null;
      }
    });
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

  void onMiniOverlayMachineStateChanged(
      PrebuiltCallMiniOverlayPageState state) {
    /// Overlay and setState may be in different contexts, causing the framework to be unable to update.
    ///
    /// The purpose of Future.delayed(Duration.zero, callback) is to execute the callback function in the next frame,
    /// which is equivalent to putting the callback function at the end of the queue,
    /// thus avoiding conflicts with the current frame and preventing the above-mentioned error from occurring.
    Future.delayed(Duration.zero, () {
      syncState();
    });
  }

  void onUserLeave(List<ZegoUIKitUser> users) {
    if (ZegoUIKit().getRemoteUsers().isEmpty) {
      //  remote users is empty

      ZegoUIKitPrebuiltCallMiniOverlayMachine()
          .prebuiltCallData
          ?.config
          .onOnlySelfInRoom
          ?.call(context);
    }
  }

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
