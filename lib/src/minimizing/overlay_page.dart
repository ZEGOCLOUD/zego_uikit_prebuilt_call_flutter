// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// The page can be minimized within the app
///
/// To support the minimize functionality in the app:
///
/// 1. Add a minimize button.
/// ```dart
/// ZegoUIKitPrebuiltCallConfig.topMenuBar.buttons.add(ZegoCallMenuBarButtonName.minimizingButton)
/// ```
/// Alternatively, if you have defined your own button, you can call:
/// ```dart
/// ZegoUIKitPrebuiltCallController().minimize.minimize().
/// ```
///
/// 2. Nest the `ZegoUIKitPrebuiltCallMiniOverlayPage` within your MaterialApp widget. Make sure to return the correct context in the `contextQuery` parameter.
///
/// How to add in MaterialApp, example:
/// ```dart
///
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   final navigatorKey = GlobalKey<NavigatorState>();
///   runApp(MyApp(
///     navigatorKey: navigatorKey,
///   ));
/// }
///
/// class MyApp extends StatefulWidget {
///   final GlobalKey<NavigatorState> navigatorKey;
///
///   const MyApp({
///     required this.navigatorKey,
///     Key? key,
///   }) : super(key: key);
///
///   @override
///   State<StatefulWidget> createState() => MyAppState();
/// }
///
/// class MyAppState extends State<MyApp> {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Flutter Demo',
///       home: const ZegoUIKitPrebuiltCallMiniPopScope(
///         child: HomePage(),
///       ),
///       navigatorKey: widget.navigatorKey,
///       builder: (BuildContext context, Widget? child) {
///         return Stack(
///           children: [
///             child!,
///
///             /// support minimizing
///             ZegoUIKitPrebuiltCallMiniOverlayPage(
///               contextQuery: () {
///                 return widget.navigatorKey.currentState!.context;
///               },
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```
class ZegoUIKitPrebuiltCallMiniOverlayPage extends StatefulWidget {
  const ZegoUIKitPrebuiltCallMiniOverlayPage({
    Key? key,
    required this.contextQuery,
    this.rootNavigator = true,
    this.navigatorWithSafeArea = true,
    this.size,
    this.topLeft = const Offset(100, 100),
    this.borderRadius = 6.0,
    this.borderColor = Colors.black12,
    this.soundWaveColor = const Color(0xff2254f6),
    this.padding = 0.0,
    this.showDevices = true,
    this.showUserName = true,
    this.showLeaveButton = true,
    this.leaveButtonIcon,
    this.foreground,
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

  final bool showLeaveButton;
  final Widget? leaveButtonIcon;

  final Widget? foreground;
  final Widget Function(ZegoUIKitUser? activeUser)? builder;

  final ZegoAudioVideoViewForegroundBuilder? foregroundBuilder;
  final ZegoAudioVideoViewBackgroundBuilder? backgroundBuilder;
  final ZegoAvatarBuilder? avatarBuilder;

  /// You need to return the `context` of NavigatorState in this callback
  final BuildContext Function() contextQuery;
  final bool rootNavigator;
  final bool navigatorWithSafeArea;

  @override
  ZegoUIKitPrebuiltCallMiniOverlayPageState createState() =>
      ZegoUIKitPrebuiltCallMiniOverlayPageState();
}

/// @nodoc
class ZegoUIKitPrebuiltCallMiniOverlayPageState
    extends State<ZegoUIKitPrebuiltCallMiniOverlayPage> {
  late Size itemSize;

  ZegoCallMiniOverlayPageState currentState = ZegoCallMiniOverlayPageState.idle;

  bool visibility = true;
  late Offset topLeft;

  StreamSubscription<dynamic>? userListStreamSubscription;

  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final activeUserIDNotifier = ValueNotifier<String?>(null);
  final Map<String, List<double>> rangeSoundLevels = {};

  Size get buttonArea => Size(itemSize.width * 0.3, itemSize.width * 0.3);

  Size get buttonSize => Size(itemSize.width * 0.2, itemSize.width * 0.2);

  ZegoCallMinimizeData? get minimizeData =>
      ZegoUIKitPrebuiltCallController().minimize.private.minimizeData;

  @override
  void initState() {
    super.initState();

    topLeft = widget.topLeft;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZegoCallMiniOverlayMachine()
          .listenStateChanged(onMiniOverlayMachineStateChanged);

      if (null != ZegoCallMiniOverlayMachine().machine.current) {
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

    ZegoCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    itemSize = calculateItemSize();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
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
      case ZegoCallMiniOverlayPageState.idle:
      case ZegoCallMiniOverlayPageState.calling:
        return Container();
      case ZegoCallMiniOverlayPageState.minimizing:
        return GestureDetector(
          onTap: () {
            ZegoUIKitPrebuiltCallController().minimize.restore(
                  widget.contextQuery(),
                  rootNavigator: widget.rootNavigator,
                  withSafeArea: widget.navigatorWithSafeArea,
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
                builder:
                    widget.avatarBuilder ?? minimizeData?.config.avatarBuilder,
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
            top: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
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
                  fontSize: itemSize.width * 0.08,
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

  Widget durationTimeBoard() {
    if (!(minimizeData?.config.duration.isVisible ?? true)) {
      return Container();
    }

    return Positioned(
      left: 0,
      right: 0,
      top: 1,
      child: ZegoCallDurationTimeBoard(
        durationNotifier: ZegoCallMiniOverlayMachine().durationNotifier(),
        fontSize: 8,
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

    final cameraEnabled = minimizeData?.config.bottomMenuBar.buttons
            .contains(ZegoCallMenuBarButtonName.toggleCameraButton) ??
        true;
    final microphoneEnabled = minimizeData?.config.bottomMenuBar.buttons
            .contains(ZegoCallMenuBarButtonName.toggleMicrophoneButton) ??
        true;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (cameraEnabled) cameraControl(activeUser),
          if (microphoneEnabled) microphoneControl(activeUser),
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

  void syncState() {
    setState(() {
      currentState = ZegoCallMiniOverlayMachine().state();
      visibility = currentState == ZegoCallMiniOverlayPageState.minimizing;

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

  void onMiniOverlayMachineStateChanged(ZegoCallMiniOverlayPageState state) {
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
    if (ZegoUIKit().getRemoteUsers().isNotEmpty) {
      return;
    }

    if (ZegoCallMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltCallController().minimize.state) {
      ZegoLoggerService.logInfo(
        'onUserLeave, not in minimizing',
        tag: 'call-minimize',
        subTag: 'overlay page',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'onUserLeave',
      tag: 'call-minimize',
      subTag: 'overlay page',
    );

    //  remote users is empty
    final callEndEvent = ZegoCallEndEvent(
      callID: minimizeData?.callID ?? ZegoUIKit().getRoom().id,
      reason: ZegoCallEndReason.remoteHangUp,
      isFromMinimizing: true,
    );
    defaultAction() {
      /// now is minimizing state, not need to navigate, just switch to idle
      ZegoUIKitPrebuiltCallController().minimize.hide();
    }

    if (minimizeData?.events.onCallEnd != null) {
      minimizeData?.events.onCallEnd?.call(callEndEvent, defaultAction);
    } else {
      defaultAction.call();
    }
  }

  Image uikitImage(String name) {
    return Image.asset(name, package: 'zego_uikit');
  }
}
