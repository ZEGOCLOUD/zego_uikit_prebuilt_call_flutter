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
}
