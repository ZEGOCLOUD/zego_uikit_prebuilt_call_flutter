// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/mini_call_page.dart';
import 'package:zego_uikit_prebuilt_call/src/components/mini_calling_page.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
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
    super.key,
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
    this.showLocalUserView = true,
    this.leaveButtonIcon,
    this.foreground,
    this.foregroundBuilder,
    this.backgroundBuilder,
    this.avatarBuilder,
  });

  final Size? size;
  final double padding;
  final double borderRadius;
  final Color borderColor;
  final Color soundWaveColor;
  final Offset topLeft;
  final bool showDevices;
  final bool showUserName;

  final bool showLeaveButton;
  final bool showLocalUserView;
  final Widget? leaveButtonIcon;

  final Widget? foreground;

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

  ZegoCallMinimizeData? get minimizeData =>
      ZegoUIKitPrebuiltCallController().minimize.private.minimizeData;

  @override
  void initState() {
    super.initState();

    // Adjust initial position to make overlay more visible
    topLeft = Offset(50, 100); // Changed from (100, 100) to (50, 100)

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ZegoCallMiniOverlayMachine()
          .listenStateChanged(onMiniOverlayMachineStateChanged);

      if (null != ZegoCallMiniOverlayMachine().machine.current) {
        syncState();
      }
    });

    ZegoUIKit().getRoomsStateStream().addListener(onRoomsStateChanged);
  }

  @override
  void dispose() {
    super.dispose();

    ZegoUIKit().getRoomsStateStream().removeListener(onRoomsStateChanged);
    userListStreamSubscription?.cancel();

    ZegoCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    itemSize = calculateItemSize();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
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
    // Adjust size to make overlay more visible
    final width = size.width / 3.0; // Changed from 1/4 to 1/3
    final height = 16.0 / 9.0 * width;
    return Size(width, height);
  }

  Widget overlayItem() {
    switch (currentState) {
      case ZegoCallMiniOverlayPageState.idle:
      case ZegoCallMiniOverlayPageState.inCall:
        return Container();
      case ZegoCallMiniOverlayPageState.inCallMinimized:
        return _buildInCallMinimizedWidget();
      case ZegoCallMiniOverlayPageState.invitingMinimized:
        return _buildInvitingMinimizedWidget();
    }
  }

  Widget _buildInCallMinimizedWidget() {
    final minimizeData =
        ZegoUIKitPrebuiltCallController().minimize.private.minimizeData;
    if (minimizeData?.inCall == null) return Container();

    return GestureDetector(
      onTap: () {
        ZegoUIKitPrebuiltCallController().minimize.restore(
              widget.contextQuery(),
              rootNavigator: widget.rootNavigator,
              withSafeArea: widget.navigatorWithSafeArea,
            );
      },
      child: ZegoMinimizingCallPage(
        roomID: minimizeData?.callID ??
            ZegoUIKitPrebuiltCallController().private.roomID,
        size: itemSize,
        durationNotifier: ZegoCallMiniOverlayMachine().durationNotifier(),
        showCameraButton: minimizeData?.inCall?.config.bottomMenuBar.buttons
                .contains(ZegoCallMenuBarButtonName.toggleCameraButton) ??
            true,
        showMicrophoneButton: minimizeData?.inCall?.config.bottomMenuBar.buttons
                .contains(ZegoCallMenuBarButtonName.toggleMicrophoneButton) ??
            true,
        durationVisible:
            minimizeData?.inCall?.config.duration.isVisible ?? true,
        showDevices: widget.showDevices,
        showUserName: widget.showUserName,
        showLeaveButton: widget.showLeaveButton,
        showLocalUserView: widget.showLocalUserView,
        leaveButtonIcon: widget.leaveButtonIcon,
        foreground: widget.foreground,
        foregroundBuilder: widget.foregroundBuilder,
        backgroundBuilder: widget.backgroundBuilder,
        avatarBuilder:
            widget.avatarBuilder ?? minimizeData?.inCall?.config.avatarBuilder,
      ),
    );
  }

  Widget _buildInvitingMinimizedWidget() {
    final minimizeData =
        ZegoUIKitPrebuiltCallController().minimize.private.minimizeData;
    if (minimizeData?.inviting == null) {
      return Container();
    }

    return GestureDetector(
      onTap: () {
        ZegoUIKitPrebuiltCallController().minimize.restoreInviting(
              widget.contextQuery(),
              rootNavigator: widget.rootNavigator,
              withSafeArea: widget.navigatorWithSafeArea,
            );
      },
      child: ZegoMinimizingCallingPage(
        roomID: minimizeData?.callID ??
            ZegoUIKitPrebuiltCallController().private.roomID,
        size: itemSize,
        invitationType: minimizeData!.inviting!.invitationType,
        inviter: minimizeData.inviting!.inviter,
        invitees: minimizeData.inviting!.invitees,
        isInviter: minimizeData.inviting!.isInviter,
        customData: minimizeData.inviting!.customData,
        pageManager: minimizeData.inviting!.pageManager,
        callInvitationData: minimizeData.inviting!.callInvitationData,
        inviterUIConfig:
            minimizeData.inviting!.callInvitationData.uiConfig.inviter,
        inviteeUIConfig:
            minimizeData.inviting!.callInvitationData.uiConfig.invitee,
        foreground: widget.foreground,
        foregroundBuilder: widget.foregroundBuilder,
        backgroundBuilder: widget.backgroundBuilder,
        avatarBuilder:
            widget.avatarBuilder ?? minimizeData.inCall?.config.avatarBuilder,
      ),
    );
  }

  void syncState() {
    final newState = ZegoCallMiniOverlayMachine().state();
    final newVisibility =
        newState == ZegoCallMiniOverlayPageState.inCallMinimized ||
            newState == ZegoCallMiniOverlayPageState.invitingMinimized;

    setState(() {
      currentState = newState;
      // Fix: inviting minimized state should also show overlay
      visibility = newVisibility;
    });
  }

  void onRoomsStateChanged() {
    if (minimizeData?.callID.isEmpty ?? true) {
      return;
    }

    if (ZegoUIKit().getCurrentRoom().isLogin) {
      userListStreamSubscription = ZegoUIKit()
          .getUserLeaveStream(
            targetRoomID: minimizeData!.callID,
          )
          .listen(onUserLeave);
    }
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
    if (ZegoCallMiniOverlayPageState.inCallMinimized !=
        ZegoUIKitPrebuiltCallController().minimize.state) {
      ZegoLoggerService.logInfo(
        'onUserLeave, not in minimizing',
        tag: 'call-minimize',
        subTag: 'overlay page',
      );

      return;
    }

    if (ZegoUIKit()
        .getRemoteUsers(
          targetRoomID: minimizeData?.callID ??
              ZegoUIKitPrebuiltCallController().private.roomID,
        )
        .isNotEmpty) {
      return;
    }

    ZegoLoggerService.logInfo(
      'onUserLeave',
      tag: 'call-minimize',
      subTag: 'overlay page',
    );

    ZegoUIKitPrebuiltCallController().pip.cancelBackground();

    final targetRoomID = minimizeData?.callID ??
        ZegoUIKitPrebuiltCallController().private.roomID;
    //  remote users is empty
    final callEndEvent = ZegoCallEndEvent(
      callID: targetRoomID,
      reason: ZegoCallEndReason.remoteHangUp,
      isFromMinimizing: true,
      invitationData: ZegoUIKitPrebuiltCallInvitationService()
          .private
          .currentCallInvitationData,
    );
    defaultAction() {
      /// now is minimizing state, not need to navigate, just switch to idle
      ZegoUIKitPrebuiltCallController().minimize.hide();

      uninitBaseBeautyConfig();
      uninitAdvanceEffectsPlugins();

      ZegoUIKitPrebuiltCallInvitationService().private.clearInvitation();

      ZegoUIKitPrebuiltCallController().room.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().user.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().audioVideo.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().minimize.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().permission.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().pip.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController()
          .screenSharing
          .private
          .uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().private.uninitByPrebuilt();

      ZegoUIKit().leaveRoom(targetRoomID: targetRoomID).then((_) {
        /// only effect call after leave room
        ZegoUIKit().enableCustomVideoProcessing(false);
      });
    }

    if (minimizeData?.inCall?.events.onCallEnd != null) {
      minimizeData?.inCall?.events.onCallEnd?.call(callEndEvent, defaultAction);
    } else {
      defaultAction.call();
    }
  }

  Future<void> uninitBaseBeautyConfig() async {
    await ZegoUIKit().resetSoundEffect();
    await ZegoUIKit().resetBeautyEffect();
    await ZegoUIKit().stopEffectsEnv();
    await ZegoUIKit().enableBeauty(false);
  }

  Future<void> uninitAdvanceEffectsPlugins() async {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().getBeautyPlugin().uninit();
    }

    ZegoUIKit().uninstallPlugins(
      ZegoUIKitPrebuiltCallController()
              .minimize
              .private
              .plugins
              ?.where((e) => e.getPluginType() == ZegoUIKitPluginType.beauty)
              .toList() ??
          [],
    );
  }
}
