// Flutter imports:
import 'package:flutter/material.dart';

class PrebuiltCallImage {
  static Image asset(String name) {
    return Image.asset(name, package: "zego_uikit_prebuilt_call");
  }
}

class PrebuiltCallIconUrls {
  static const String iconS1ControlBarMore =
      'assets/icons/s1_ctrl_bar_more_normal.png';
  static const String iconS1ControlBarMoreChecked =
      'assets/icons/s1_ctrl_bar_more_checked.png';
}

class InvitationStyleIconUrls {
  static const String inviteVoice = 'assets/icons/invite_voice.png';
  static const String inviteVideo = 'assets/icons/invite_video.png';
  static const String inviteReject = 'assets/icons/invite_reject.png';
  static const String inviteBackground = 'assets/icons/invite_background.png';

  static const String toolbarBottomVideo =
      'assets/icons/toolbar_bottom_video.png';
  static const String toolbarBottomVoice =
      'assets/icons/toolbar_bottom_voice.png';
  static const String toolbarBottomDecline =
      'assets/icons/toolbar_bottom_decline.png';
  static const String toolbarBottomCancel =
      'assets/icons/toolbar_bottom_cancel.png';
  static const String toolbarBottomEnd =
      'assets/icons/toolbar_bottom_cancel.png';
  static const String toolbarTopSwitchCamera =
      'assets/icons/toolbar_top_switch_camera.png';

  static const String memberCameraNormal =
      'assets/icons/member_camera_normal.png';
  static const String memberCameraOff = 'assets/icons/member_camera_off.png';
  static const String memberMicNormal = 'assets/icons/member_mic_normal.png';
  static const String memberMicOff = 'assets/icons/member_mic_off.png';
  static const String memberMicSpeaking =
      'assets/icons/member_mic_speaking.png';
}
