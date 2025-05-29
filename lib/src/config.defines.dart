// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/defines.dart';

typedef ZegoCallAudioVideoContainerBuilder = Widget? Function(
  BuildContext context,
  List<ZegoUIKitUser> allUsers,
  List<ZegoUIKitUser> audioVideoUsers,

  /// The default audio-video view creator, you can also use [ZegoAudioVideoView] as a child control to continue encapsulating
  ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator,
);

class ZegoCallHangUpConfirmDialogInfo extends ZegoCallConfirmDialogInfo {
  ZegoCallHangUpConfirmDialogInfo({
    String title = 'Hangup Confirmation',
    String message = 'Do you want to hangup?',
  }) : super(
          title: title,
          message: message,
        );

  @override
  String toString() {
    return 'ZegoCallHangUpConfirmDialogInfo:{'
        'title:$title, '
        'message:$message, '
        '}';
  }
}

/// screen sharing
class ZegoCallScreenSharingConfig {
  /// when ending screen sharing from a non-app,
  /// the automatic check end mechanism will be triggered.
  ZegoCallScreenSharingAutoStopConfig autoStop;

  /// If true, then when there is screen sharing display, it will automatically be full screen
  /// default is false
  bool defaultFullScreen;

  ZegoCallScreenSharingConfig({
    ZegoCallScreenSharingAutoStopConfig? autoStop,
    this.defaultFullScreen = false,
  }) : autoStop = autoStop ?? ZegoCallScreenSharingAutoStopConfig();

  @override
  String toString() {
    return 'ZegoCallScreenSharingConfig:{'
        'autoStop:$autoStop, '
        'defaultFullScreen:$defaultFullScreen, '
        '}';
  }
}

/// when ending screen sharing from a non-app,
/// the automatic check end mechanism will be triggered.
class ZegoCallScreenSharingAutoStopConfig {
  /// Count of the check fails before automatically end the screen sharing
  int invalidCount;

  /// Determines whether to end;
  /// returns false if you don't want to end
  bool Function()? canEnd;

  ZegoCallScreenSharingAutoStopConfig({
    this.invalidCount = 3,
    this.canEnd,
  });

  @override
  String toString() {
    return 'ZegoCallScreenSharingAutoStopConfig:{'
        'invalidCount:$invalidCount, '
        'canEnd:${canEnd != null}, '
        '}';
  }
}
