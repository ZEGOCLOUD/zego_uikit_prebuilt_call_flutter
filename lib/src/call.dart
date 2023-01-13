// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:core';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'call_config.dart';
import 'components/components.dart';

class ZegoUIKitPrebuiltCall extends StatefulWidget {
  const ZegoUIKitPrebuiltCall({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.config,
    this.tokenServerUrl = '',
    this.onDispose,
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// You can customize the callID arbitrarily,
  /// just need to know: users who use the same callID can talk with each other.
  final String callID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltCall(
  ///     appID: appID,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     userID: userID,
  ///     userName: userName,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  final ZegoUIKitPrebuiltCallConfig config;

  final VoidCallback? onDispose;

  @override
  State<ZegoUIKitPrebuiltCall> createState() => _ZegoUIKitPrebuiltCallState();
}

class _ZegoUIKitPrebuiltCallState extends State<ZegoUIKitPrebuiltCall>
    with SingleTickerProviderStateMixin {
  var barVisibilityNotifier = ValueNotifier<bool>(true);
  var barRestartHideTimerNotifier = ValueNotifier<int>(0);

  StreamSubscription<dynamic>? userListStreamSubscription;

  @override
  void initState() {
    super.initState();

    ZegoUIKit().getZegoUIKitVersion().then((version) {
      ZegoLoggerService.logInfo(
        "version: zego_uikit_prebuilt_call:1.4.2; $version",
        tag: "call",
        subTag: "prebuilt",
      );
    });

    initContext();

    userListStreamSubscription =
        ZegoUIKit().getUserLeaveStream().listen(onUserLeave);
  }

  @override
  void dispose() async {
    super.dispose();

    userListStreamSubscription?.cancel();

    await ZegoUIKit().leaveRoom();
    // await ZegoUIKit().uninit();

    widget.onDispose?.call();
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
        child: ScreenUtilInit(
          designSize: const Size(750, 1334),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return LayoutBuilder(builder: (context, constraints) {
              return clickListener(
                child: Stack(
                  children: [
                    background(constraints.maxWidth),
                    audioVideoContainer(context, constraints.maxHeight),
                    widget.config.topMenuBarConfig.isVisible
                        ? topMenuBar()
                        : Container(),
                    bottomMenuBar(),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> initPermissions() async {
    if (widget.config.turnOnCameraWhenJoining) {
      await requestPermission(Permission.camera);
    }
    if (widget.config.turnOnMicrophoneWhenJoining) {
      await requestPermission(Permission.microphone);
    }
  }

  void initContext() {
    correctConfigValue();

    ZegoUIKitPrebuiltCallConfig config = widget.config;
    if (!kIsWeb) {
      assert(widget.appSign.isNotEmpty);
      initPermissions().then((value) {
        ZegoUIKit().login(widget.userID, widget.userName).then((value) {
          ZegoUIKit()
              .init(appID: widget.appID, appSign: widget.appSign)
              .then((value) {
            ZegoUIKit()
              ..useFrontFacingCamera(true)
              ..updateVideoViewMode(
                  config.audioVideoViewConfig.useVideoViewAspectFill)
              ..enableVideoMirroring(config.audioVideoViewConfig.isVideoMirror)
              ..turnCameraOn(config.turnOnCameraWhenJoining)
              ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
              ..setAudioOutputToSpeaker(config.useSpeakerWhenJoining)
              ..joinRoom(widget.callID);
          });
        });
      });
    } else {
      assert(widget.tokenServerUrl.isNotEmpty);
      ZegoUIKit().login(widget.userID, widget.userName).then((value) {
        ZegoUIKit()
            .init(appID: widget.appID, tokenServerUrl: widget.tokenServerUrl)
            .then((value) {
          ZegoUIKit()
            ..updateVideoViewMode(
                config.audioVideoViewConfig.useVideoViewAspectFill)
            ..turnCameraOn(config.turnOnCameraWhenJoining)
            ..turnMicrophoneOn(config.turnOnMicrophoneWhenJoining)
            ..setAudioOutputToSpeaker(config.useSpeakerWhenJoining);

          getToken(widget.userID).then((token) {
            assert(token.isNotEmpty);
            ZegoUIKit().joinRoom(widget.callID, token: token);
          });
        });
      });
    }
  }

  void correctConfigValue() {
    if (widget.config.bottomMenuBarConfig.maxCount > 5) {
      widget.config.bottomMenuBarConfig.maxCount = 5;
      ZegoLoggerService.logInfo(
        'menu bar buttons limited count\'s value  is exceeding the maximum limit',
        tag: "call",
        subTag: "prebuilt",
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

  Widget audioVideoContainer(BuildContext context, double height) {
    late Widget container;
    if (widget.config.audioVideoContainerBuilder != null) {
      /// custom
      container = StreamBuilder<List<ZegoUIKitUser>>(
        stream: ZegoUIKit().getUserListStream(),
        builder: (context, snapshot) {
          List<ZegoUIKitUser> allUsers = ZegoUIKit().getAllUsers();
          return StreamBuilder<List<ZegoUIKitUser>>(
            stream: ZegoUIKit().getAudioVideoListStream(),
            builder: (context, snapshot) {
              List<ZegoUIKitUser> streamUsers = snapshot.data ?? [];
              return widget.config.audioVideoContainerBuilder!
                  .call(context, allUsers, streamUsers);
            },
          );
        },
      );
    } else {
      /// audio video container
      if (widget.config.layout is ZegoLayoutPictureInPictureConfig) {
        var layout = widget.config.layout as ZegoLayoutPictureInPictureConfig;
        layout.smallViewPosition = ZegoViewPosition.topRight;
        layout.smallViewSize = Size(190.0.w, 338.0.h);
        layout.smallViewMargin =
            EdgeInsets.only(left: 20.r, top: 50.r, right: 20.r, bottom: 30.r);
        widget.config.layout = layout;
      }

      container = ZegoAudioVideoContainer(
        layout: widget.config.layout!,
        backgroundBuilder: audioVideoViewBackground,
        foregroundBuilder: audioVideoViewForeground,
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
                users.removeAt(0);
                users.insert(1, ZegoUIKit().getLocalUser());
              }
            }
          } else {
            var localUserIndex = users
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
        width: 750.w,
        height: height,
        child: container,
      ),
    );
  }

  Widget topMenuBar() {
    var isLightStyle =
        ZegoMenuBarStyle.light == widget.config.bottomMenuBarConfig.style;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ZegoTopMenuBar(
        buttonSize: Size(96.r, 96.r),
        config: widget.config,
        visibilityNotifier: barVisibilityNotifier,
        restartHideTimerNotifier: barRestartHideTimerNotifier,
        height: 88.r,
        backgroundColor:
            isLightStyle ? null : ZegoUIKitDefaultTheme.viewBackgroundColor,
      ),
    );
  }

  Widget bottomMenuBar() {
    var isLightStyle =
        ZegoMenuBarStyle.light == widget.config.bottomMenuBarConfig.style;

    return Positioned(
      left: 0,
      right: 0,
      bottom: isLightStyle ? 10 : 0,
      child: ZegoBottomMenuBar(
        buttonSize: Size(96.r, 96.r),
        config: widget.config,
        visibilityNotifier: barVisibilityNotifier,
        restartHideTimerNotifier: barRestartHideTimerNotifier,
        height: isLightStyle ? null : 208.r,
        backgroundColor:
            isLightStyle ? null : ZegoUIKitDefaultTheme.viewBackgroundColor,
        borderRadius: isLightStyle ? null : 32.r,
      ),
    );
  }

  /// Get your token from tokenServer
  Future<String> getToken(String userID) async {
    final response = await http
        .get(Uri.parse('${widget.tokenServerUrl}/access_token?uid=$userID'));
    if (response.statusCode == 200) {
      final jsonObj = json.decode(response.body);
      return jsonObj['token'];
    } else {
      return "";
    }
  }

  Future<bool> onHangUpConfirmation(BuildContext context) async {
    if (widget.config.hangUpConfirmDialogInfo == null) {
      return true;
    }

    return await showAlertDialog(
      context,
      widget.config.hangUpConfirmDialogInfo!.title,
      widget.config.hangUpConfirmDialogInfo!.message,
      [
        CupertinoDialogAction(
          child: Text(
            widget.config.hangUpConfirmDialogInfo!.cancelButtonName,
            style: TextStyle(fontSize: 26.r, color: const Color(0xff0055FF)),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(context).pop(false);
          },
        ),
        CupertinoDialogAction(
          child: Text(
            widget.config.hangUpConfirmDialogInfo!.confirmButtonName,
            style: TextStyle(fontSize: 26.r, color: Colors.white),
          ),
          onPressed: () {
            //  pop this dialog
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  Widget audioVideoViewForeground(
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
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
      BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    var screenSize = MediaQuery.of(context).size;
    var isSmallView = (screenSize.width - size.width).abs() > 1;

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
    var screenSize = MediaQuery.of(context).size;
    var isSmallView = (screenSize.width - maxWidth).abs() > 1;

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
}
