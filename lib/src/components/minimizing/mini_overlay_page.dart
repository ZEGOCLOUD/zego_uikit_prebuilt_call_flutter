// Flutter imports:
import 'dart:async';

import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoMiniOverlayPage extends StatefulWidget {
  const ZegoMiniOverlayPage({
    Key? key,
    required this.contextQuery,
    this.size,
    this.topLeft = const Offset(100, 100),
    this.borderRadius = 12.0,
    this.borderColor = const Color(0xffA4A4A4),
    this.padding = 0.0,
  }) : super(key: key);

  final Size? size;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final Offset topLeft;
  final BuildContext Function() contextQuery;

  @override
  ZegoMiniOverlayPageState createState() => ZegoMiniOverlayPageState();
}

class ZegoMiniOverlayPageState extends State<ZegoMiniOverlayPage> {
  MiniOverlayPageState currentState = MiniOverlayPageState.idle;

  bool visibility = true;
  late Offset topLeft;

  StreamSubscription<dynamic>? userListStreamSubscription;

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserNotifier = ValueNotifier<ZegoUIKitUser?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  @override
  void initState() {
    super.initState();

    topLeft = widget.topLeft;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      ZegoMiniOverlayMachine()
          .listenStateChanged(onMiniOverlayMachineStateChanged);

      if (null != ZegoMiniOverlayMachine().machine.current) {
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

    ZegoMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
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
                final itemSize = calculateItemSize();

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
              final itemSize = calculateItemSize();
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
    final width = size.width / 3.0;
    final height = 16.0 / 9.0 * width;
    return Size(width, height);
  }

  Widget overlayItem() {
    switch (currentState) {
      case MiniOverlayPageState.idle:
      case MiniOverlayPageState.calling:
        return Container();
      case MiniOverlayPageState.minimizing:
        return GestureDetector(
          onTap: () {
            final prebuiltCallData = ZegoMiniOverlayMachine().prebuiltCallData;
            assert(null != prebuiltCallData);

            /// re-enter prebuilt call
            ZegoMiniOverlayMachine().changeState(MiniOverlayPageState.calling);

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
                    appDesignSize: prebuiltCallData.appDesignSize,
                  ),
                );
              }),
            );
          },
          child: ValueListenableBuilder<ZegoUIKitUser?>(
            valueListenable: activeUserNotifier,
            builder: (context, activeUser, _) {
              return circleBorder(
                  child: activeUser == null
                      ? Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffA4A4A4),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.borderRadius),
                            ),
                          ),
                        )
                      : ZegoAudioVideoView(user: activeUser)); //
            },
          ),
        );
    }
  }

  Widget circleBorder({required Widget child}) {
    final decoration = BoxDecoration(
      border: Border.all(color: widget.borderColor, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
    );

    return Container(
      padding: EdgeInsets.all(widget.padding),
      decoration: decoration,
      child: PhysicalModel(
        color: widget.borderColor,
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        shadowColor: widget.borderColor.withOpacity(0.3),
        child: child,
      ),
    );
  }

  void syncState() {
    setState(() {
      currentState = ZegoMiniOverlayMachine().state();
      visibility = currentState == MiniOverlayPageState.minimizing;

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
    activeUserNotifier.value = ZegoUIKit().getAudioVideoList().isEmpty
        ? null
        : ZegoUIKit().getAudioVideoList().first;
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
    var activeUserID = activeUserNotifier.value?.id ?? '';
    rangeSoundLevels.forEach((userID, soundLevels) {
      final averageSoundLevel =
          soundLevels.reduce((a, b) => a + b) / soundLevels.length;

      if (averageSoundLevel > maxAverageSoundLevel) {
        activeUserID = userID;
        maxAverageSoundLevel = averageSoundLevel;
      }
    });
    activeUserNotifier.value = ZegoUIKit().getUser(activeUserID);

    rangeSoundLevels.clear();
  }

  void onMiniOverlayMachineStateChanged(MiniOverlayPageState state) {
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

      ZegoMiniOverlayMachine()
          .prebuiltCallData
          ?.config
          .onOnlySelfInRoom
          ?.call(context);
    }
  }
}
