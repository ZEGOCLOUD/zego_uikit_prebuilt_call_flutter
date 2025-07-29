// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/mini_call.dart';
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
    this.showLocalUserView = true,
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
  final bool showLocalUserView;
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
          child: ZegoMinimizingCallPage(
            size: itemSize,
            durationNotifier: ZegoCallMiniOverlayMachine().durationNotifier(),
            showCameraButton: minimizeData?.config.bottomMenuBar.buttons
                    .contains(ZegoCallMenuBarButtonName.toggleCameraButton) ??
                true,
            showMicrophoneButton: minimizeData?.config.bottomMenuBar.buttons
                    .contains(
                        ZegoCallMenuBarButtonName.toggleMicrophoneButton) ??
                true,
            durationVisible: minimizeData?.config.duration.isVisible ?? true,
            showDevices: widget.showDevices,
            showUserName: widget.showUserName,
            showLeaveButton: widget.showLeaveButton,
            showLocalUserView: widget.showLocalUserView,
            leaveButtonIcon: widget.leaveButtonIcon,
            foreground: widget.foreground,
            builder: widget.builder,
            foregroundBuilder: widget.foregroundBuilder,
            backgroundBuilder: widget.backgroundBuilder,
            avatarBuilder:
                widget.avatarBuilder ?? minimizeData?.config.avatarBuilder,
          ),
        );
    }
  }

  void syncState() {
    setState(() {
      currentState = ZegoCallMiniOverlayMachine().state();
      visibility = currentState == ZegoCallMiniOverlayPageState.minimizing;
    });
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

    ZegoUIKitPrebuiltCallController().pip.cancelBackground();

    //  remote users is empty
    final callEndEvent = ZegoCallEndEvent(
      callID: minimizeData?.callID ?? ZegoUIKit().getRoom().id,
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

      ZegoUIKitPrebuiltCallController().private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().user.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().audioVideo.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().minimize.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().permission.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController().pip.private.uninitByPrebuilt();
      ZegoUIKitPrebuiltCallController()
          .screenSharing
          .private
          .uninitByPrebuilt();

      ZegoUIKit().leaveRoom().then((_) {
        /// only effect call after leave room
        ZegoUIKit().enableCustomVideoProcessing(false);
      });
    }

    if (minimizeData?.events.onCallEnd != null) {
      minimizeData?.events.onCallEnd?.call(callEndEvent, defaultAction);
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
