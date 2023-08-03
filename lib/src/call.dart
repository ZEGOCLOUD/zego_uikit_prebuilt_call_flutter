// Dart imports:
import 'dart:async';
import 'dart:core';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_controller.dart';
import 'package:zego_uikit_prebuilt_call/src/components/components.dart';
import 'package:zego_uikit_prebuilt_call/src/components/duration_time_board.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_overlay_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/prebuilt_data.dart';

/// Call Widget.
/// You can embed this widget into any page of your project to integrate the functionality of a call.
/// You can refer to our [documentation](https://docs.zegocloud.com/article/14826),
/// or our [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter).
///
/// If you need the function of `call invitation`, please use [ZegoUIKitPrebuiltCallInvitationService] together.
/// And refer to the [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter/tree/master/call_with_offline_invitation).
class ZegoUIKitPrebuiltCall extends StatefulWidget {
  const ZegoUIKitPrebuiltCall({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.config,
    this.onDispose,
    this.controller,
    this.plugins,
    @Deprecated('Since 3.3.1') this.appDesignSize,
  }) : super(key: key);

  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final int appID;

  /// You can create a project and obtain an appSign from the [ZEGOCLOUD Admin Console](https://console.zegocloud.com).
  final String appSign;

  /// The ID of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the ID from your own user system, such as Firebase.
  final String userID;

  /// The name of the currently logged-in user.
  /// It can be any valid string.
  /// Typically, you would use the name from your own user system, such as Firebase.
  final String userName;

  /// The ID of the call.
  /// This ID is a unique identifier for the current call, so you need to ensure its uniqueness.
  /// It can be any valid string.
  /// Users who provide the same callID will be logged into the same room for the call.
  final String callID;

  /// Initialize the configuration for the call.
  final ZegoUIKitPrebuiltCallConfig config;

  /// You can invoke the methods provided by [ZegoUIKitPrebuiltCall] through the [controller].
  final ZegoUIKitPrebuiltCallController? controller;

  /// Callback when the page is destroyed.
  final VoidCallback? onDispose;

  final List<IZegoUIKitPlugin>? plugins;

  /// @nodoc
  @Deprecated('Since 3.3.1')
  final Size? appDesignSize;

  /// @nodoc
  @override
  State<ZegoUIKitPrebuiltCall> createState() => _ZegoUIKitPrebuiltCallState();
}

/// @nodoc
class _ZegoUIKitPrebuiltCallState extends State<ZegoUIKitPrebuiltCall>
    with SingleTickerProviderStateMixin {
  var barVisibilityNotifier = ValueNotifier<bool>(true);
  var barRestartHideTimerNotifier = ValueNotifier<int>(0);

  StreamSubscription<dynamic>? userListStreamSubscription;
  List<StreamSubscription<dynamic>?> subscriptions = [];

  late ZegoUIKitPrebuiltCallData prebuiltData;

  Timer? durationTimer;
  DateTime? durationStartTime;
  var durationNotifier = ValueNotifier<Duration>(Duration.zero);

  final popUpManager = ZegoPopUpManager();

  @override
  void initState() {
    super.initState();

    ZegoLoggerService.logInfo(
      'mini machine state is ${ZegoUIKitPrebuiltCallMiniOverlayMachine().state()}',
      tag: 'call',
      subTag: 'prebuilt',
    );

    final isPrebuiltFromMinimizing = PrebuiltCallMiniOverlayPageState.idle !=
        ZegoUIKitPrebuiltCallMiniOverlayMachine().state();

    initDurationTimer(
      isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
    );

    correctConfigValue();
    widget.controller?.initByPrebuilt(prebuiltConfig: widget.config);

    prebuiltData = ZegoUIKitPrebuiltCallData(
      appID: widget.appID,
      appSign: widget.appSign,
      callID: widget.callID,
      userID: widget.userID,
      userName: widget.userName,
      config: widget.config,
      onDispose: widget.onDispose,
      controller: widget.controller,
      isPrebuiltFromMinimizing: isPrebuiltFromMinimizing,
      durationStartTime: durationStartTime,
    );

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      ZegoLoggerService.logInfo(
        'version: zego_uikit_prebuilt_call:3.11.1; $version',
        tag: 'call',
        subTag: 'prebuilt',
      );
    });

    if (isPrebuiltFromMinimizing) {
      ZegoLoggerService.logInfo(
        'mini machine state is not idle, context will not be init',
        tag: 'call',
        subTag: 'prebuilt',
      );
    } else {
      /// not wake from mini page
      initContext();
    }
    ZegoUIKitPrebuiltCallMiniOverlayMachine()
        .changeState(PrebuiltCallMiniOverlayPageState.idle);

    subscriptions.add(
        ZegoUIKit().getMeRemovedFromRoomStream().listen(onMeRemovedFromRoom));
    userListStreamSubscription =
        ZegoUIKit().getUserLeaveStream().listen(onUserLeave);
  }

  @override
  void dispose() {
    super.dispose();

    userListStreamSubscription?.cancel();
    widget.onDispose?.call();

    durationTimer?.cancel();

    widget.controller?.uninitByPrebuilt();

    if (PrebuiltCallMiniOverlayPageState.minimizing !=
        ZegoUIKitPrebuiltCallMiniOverlayMachine().state()) {
      ZegoUIKit().leaveRoom();
      // await ZegoUIKit().uninit();
    } else {
      ZegoLoggerService.logInfo(
        'mini machine state is minimizing, room will not be leave',
        tag: 'call',
        subTag: 'prebuilt',
      );
    }

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().getBeautyPlugin().uninit();
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.config.onHangUpConfirmation ??= onHangUpConfirmation;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: () async {
          return await widget.config.onHangUpConfirmation!(context) ?? false;
        },
        child: ZegoScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return LayoutBuilder(builder: (context, constraints) {
              return clickListener(
                child: Stack(
                  children: [
                    background(constraints.maxWidth),
                    audioVideoContainer(
                      context,
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    if (widget.config.topMenuBarConfig.isVisible)
                      topMenuBar()
                    else
                      Container(),
                    bottomMenuBar(),
                    durationTimeBoard(),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void initDurationTimer({required bool isPrebuiltFromMinimizing}) {
    if (!widget.config.durationConfig.isVisible) {
      return;
    }

    ZegoLoggerService.logInfo(
      'init duration',
      tag: 'call',
      subTag: 'prebuilt',
    );

    durationStartTime = isPrebuiltFromMinimizing
        ? ZegoUIKitPrebuiltCallMiniOverlayMachine().durationStartTime()
        : DateTime.now();
    durationNotifier.value = DateTime.now().difference(durationStartTime!);
    durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      durationNotifier.value = DateTime.now().difference(durationStartTime!);
      widget.config.durationConfig.onDurationUpdate
          ?.call(durationNotifier.value);
    });
  }

  Future<void> initPermissions() async {
    if (widget.config.turnOnCameraWhenJoining) {
      await requestPermission(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      await requestPermission(Permission.microphone);
    }
  }

  Future<void> initContext() async {
    assert(widget.userID.isNotEmpty);
    assert(widget.userName.isNotEmpty);
    assert(widget.appID > 0);
    assert(widget.appSign.isNotEmpty);

    await initEffectsPlugins();

    final config = widget.config;
    initPermissions().then((value) {
      ZegoUIKit().login(widget.userID, widget.userName);

      ZegoUIKit()
          .init(appID: widget.appID, appSign: widget.appSign)
          .then((value) {
        // enableCustomVideoProcessing
        if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
          ZegoUIKit().enableCustomVideoProcessing(true);
        }

        ZegoUIKit()
          ..useFrontFacingCamera(true)
          ..updateVideoViewMode(
              config.audioVideoViewConfig.useVideoViewAspectFill)
          ..enableVideoMirroring(config.audioVideoViewConfig.isVideoMirror)
          ..turnCameraOn(config.turnOnCameraWhenJoining)
          ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
          ..setAudioOutputToSpeaker(config.useSpeakerWhenJoining);

        ZegoUIKit().joinRoom(widget.callID).then((result) async {
          assert(result.errorCode == 0);

          if (result.errorCode != 0) {
            ZegoLoggerService.logError(
              'failed to login room:${result.errorCode},${result.extendedData}',
              tag: 'call',
              subTag: 'prebuilt',
            );
          }
        });
      });
    });
  }

  Future<void> initEffectsPlugins() async {
    if (widget.plugins != null) {
      ZegoUIKit().installPlugins(widget.plugins!);
    }

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit()
          .getBeautyPlugin()
          .setConfig(widget.config.beautyConfig ?? ZegoBeautyPluginConfig());
      await ZegoUIKit()
          .getBeautyPlugin()
          .init(widget.appID, appSign: widget.appSign)
          .then((value) {
        ZegoLoggerService.logInfo(
          'effects plugin init done',
          tag: 'live streaming',
          subTag: 'plugin',
        );
      });
    }
  }

  void correctConfigValue() {
    if (widget.config.bottomMenuBarConfig.maxCount > 5) {
      widget.config.bottomMenuBarConfig.maxCount = 5;
      ZegoLoggerService.logInfo(
        "menu bar buttons limited count's value  is exceeding the maximum limit",
        tag: 'call',
        subTag: 'prebuilt',
      );
    }
  }

  void onUserLeave(List<ZegoUIKitUser> users) {
    if (ZegoUIKit().getRemoteUsers().isEmpty) {
      //  remote users is empty
      widget.config.onOnlySelfInRoom?.call(context);
    }
  }

  Widget clickListener({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        /// listen only click event in empty space
        if (widget.config.bottomMenuBarConfig.hideByClick) {
          barVisibilityNotifier.value = !barVisibilityNotifier.value;
        }
      },
      child: Listener(
        ///  listen for all click events in current view, include the click
        ///  receivers(such as button...), but only listen
        onPointerDown: (e) {
          barRestartHideTimerNotifier.value =
              DateTime.now().millisecondsSinceEpoch;
        },
        child: AbsorbPointer(
          absorbing: false,
          child: child,
        ),
      ),
    );
  }

  Widget audioVideoContainer(
    BuildContext context,
    double width,
    double height,
  ) {
    late Widget avContainer;
    if (widget.config.audioVideoContainerBuilder != null) {
      /// custom
      avContainer = StreamBuilder<List<ZegoUIKitUser>>(
        stream: ZegoUIKit().getUserListStream(),
        builder: (context, snapshot) {
          final allUsers = ZegoUIKit().getAllUsers();
          return StreamBuilder<List<ZegoUIKitUser>>(
            stream: ZegoUIKit().getAudioVideoListStream(),
            builder: (context, snapshot) {
              return widget.config.audioVideoContainerBuilder!.call(
                context,
                allUsers,
                ZegoUIKit().getAudioVideoList(),
              );
            },
          );
        },
      );
    } else {
      /// audio video container
      if (widget.config.layout is ZegoLayoutPictureInPictureConfig) {
        final layout = (widget.config.layout
            as ZegoLayoutPictureInPictureConfig)
          ..smallViewPosition = ZegoViewPosition.topRight
          ..smallViewSize = Size(190.0.zW, 338.0.zH)
          ..smallViewMargin = EdgeInsets.only(
              left: 20.zR, top: 50.zR, right: 20.zR, bottom: 30.zR);
        widget.config.layout = layout;
      }

      avContainer = ZegoAudioVideoContainer(
        layout: widget.config.layout!,
        backgroundBuilder: audioVideoViewBackground,
        foregroundBuilder: audioVideoViewForeground,
        screenSharingViewController:
            widget.controller?.screenSharingViewController,
        avatarConfig: ZegoAvatarConfig(
          showInAudioMode:
              widget.config.audioVideoViewConfig.showAvatarInAudioMode,
          showSoundWavesInAudioMode:
              widget.config.audioVideoViewConfig.showSoundWavesInAudioMode,
          builder: widget.config.avatarBuilder,
        ),
        sortAudioVideo: (List<ZegoUIKitUser> users) {
          if (widget.config.layout is ZegoLayoutPictureInPictureConfig) {
            if (users.length > 1) {
              if (users.first.id == ZegoUIKit().getLocalUser().id) {
                /// local display small view
                users
                  ..removeAt(0)
                  ..insert(1, ZegoUIKit().getLocalUser());
              }
            }
          } else {
            final localUserIndex = users
                .indexWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
            if (-1 != localUserIndex) {
              users.removeAt(localUserIndex);
              users = [
                ZegoUIKit().getLocalUser(),
                ...List<ZegoUIKitUser>.from(users.reversed)
              ];
            }
          }
          return users;
        },
      );
    }

    return Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: width,
        height: height,
        child: avContainer,
      ),
    );
  }

  Widget topMenuBar() {
    final isLightStyle =
        ZegoMenuBarStyle.light == widget.config.topMenuBarConfig.style;
    final safeAreaInsets = MediaQuery.of(context).padding;

    return Positioned(
      left: 0,
      right: 0,
      top: safeAreaInsets.top,
      child: ZegoTopMenuBar(
        buttonSize: Size(96.zR, 96.zR),
        config: widget.config,
        visibilityNotifier: barVisibilityNotifier,
        restartHideTimerNotifier: barRestartHideTimerNotifier,
        prebuiltData: prebuiltData,
        isHangUpRequestingNotifier:
            widget.controller?.isHangUpRequestingNotifier,
        height: widget.config.topMenuBarConfig.height ?? 88.zR,
        backgroundColor: widget.config.topMenuBarConfig.backgroundColor ??
            (isLightStyle ? null : ZegoUIKitDefaultTheme.viewBackgroundColor),
      ),
    );
  }

  Widget bottomMenuBar() {
    final isLightStyle =
        ZegoMenuBarStyle.light == widget.config.bottomMenuBarConfig.style;
    final safeAreaInsets = MediaQuery.of(context).padding;

    return Positioned(
      left: 0,
      right: 0,
      bottom:
          isLightStyle ? safeAreaInsets.bottom + 10.zR : safeAreaInsets.bottom,
      child: ZegoBottomMenuBar(
        buttonSize: Size(96.zR, 96.zR),
        config: widget.config,
        visibilityNotifier: barVisibilityNotifier,
        restartHideTimerNotifier: barRestartHideTimerNotifier,
        prebuiltData: prebuiltData,
        isHangUpRequestingNotifier:
            widget.controller?.isHangUpRequestingNotifier,
        height: widget.config.bottomMenuBarConfig.height ??
            (isLightStyle ? null : 208.zR),
        backgroundColor: widget.config.bottomMenuBarConfig.backgroundColor ??
            (isLightStyle ? null : ZegoUIKitDefaultTheme.viewBackgroundColor),
        borderRadius: isLightStyle ? null : 32.zR,
      ),
    );
  }

  Widget durationTimeBoard() {
    if (!widget.config.durationConfig.isVisible) {
      return Container();
    }

    final safeAreaInsets = MediaQuery.of(context).padding;

    return Positioned(
      top: safeAreaInsets.top + 10.zR,
      left: 0,
      right: 0,
      child: CallDurationTimeBoard(
        durationNotifier: durationNotifier,
        fontSize: 25.zR,
      ),
    );
  }

  Future<bool> onHangUpConfirmation(BuildContext context) async {
    if (widget.config.hangUpConfirmDialogInfo == null) {
      return true;
    }

    final key = DateTime.now().millisecondsSinceEpoch;
    popUpManager.addAPopUpSheet(key);

    return showAlertDialog(
      context,
      widget.config.hangUpConfirmDialogInfo!.title,
      widget.config.hangUpConfirmDialogInfo!.message,
      [
        CupertinoDialogAction(
          child: Text(
            widget.config.hangUpConfirmDialogInfo!.cancelButtonName,
            style: TextStyle(fontSize: 26.zR, color: const Color(0xff0055FF)),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(
              context,
              rootNavigator: widget.config.rootNavigator,
            ).pop(false);
          },
        ),
        CupertinoDialogAction(
          child: Text(
            widget.config.hangUpConfirmDialogInfo!.confirmButtonName,
            style: TextStyle(fontSize: 26.zR, color: Colors.white),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(
              context,
              rootNavigator: widget.config.rootNavigator,
            ).pop(true);
          },
        ),
      ],
    ).then((result) {
      popUpManager.removeAPopUpSheet(key);

      return result;
    });
  }

  Widget audioVideoViewForeground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    if (extraInfo[ZegoViewBuilderMapExtraInfoKey.isScreenSharingView.name]
            as bool? ??
        false) {
      return Container();
    }

    return Stack(
      children: [
        widget.config.audioVideoViewConfig.foregroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
        ZegoAudioVideoForeground(
          size: size,
          user: user,
          showMicrophoneStateOnView:
              widget.config.audioVideoViewConfig.showMicrophoneStateOnView,
          showCameraStateOnView:
              widget.config.audioVideoViewConfig.showCameraStateOnView,
          showUserNameOnView:
              widget.config.audioVideoViewConfig.showUserNameOnView,
        ),
      ],
    );
  }

  Widget audioVideoViewBackground(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = (screenSize.width - size.width).abs() > 1;

    var backgroundColor =
        isSmallView ? const Color(0xff333437) : const Color(0xff4A4B4D);
    if (widget.config.layout is ZegoLayoutGalleryConfig) {
      backgroundColor = const Color(0xff4A4B4D);
    }

    return Stack(
      children: [
        Container(color: backgroundColor),
        widget.config.audioVideoViewConfig.backgroundBuilder
                ?.call(context, size, user, extraInfo) ??
            Container(color: Colors.transparent),
      ],
    );
  }

  Widget background(double maxWidth) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallView = (screenSize.width - maxWidth).abs() > 1;

    var backgroundColor =
        isSmallView ? const Color(0xff333437) : const Color(0xff4A4B4D);
    if (widget.config.layout is ZegoLayoutGalleryConfig) {
      backgroundColor = const Color(0xff4A4B4D);
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(color: backgroundColor),
    );
  }

  void onMeRemovedFromRoom(String fromUserID) {
    ZegoLoggerService.logInfo(
      'local user removed by $fromUserID',
      tag: 'call',
      subTag: 'prebuilt',
    );

    ///more button, member list, chat dialog
    popUpManager.autoPop(context, widget.config.rootNavigator);

    if (null != widget.config.onMeRemovedFromRoom) {
      widget.config.onMeRemovedFromRoom!.call(fromUserID);
    } else {
      //  pop this dialog
      Navigator.of(
        context,
        rootNavigator: widget.config.rootNavigator,
      ).pop(true);
    }
  }
}
