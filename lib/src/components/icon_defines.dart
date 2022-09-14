// Flutter imports:
import 'package:flutter/material.dart';

class PrebuiltCallImage {
  static Image asset(String name) {
    return Image.asset(name, package: "zego_uikit_prebuilt_call");
  }
}

class PrebuiltCallIconUrls {
  static const String back = 'assets/icons/back.png';

  static const String memberCameraNormal =
      'assets/icons/member_camera_normal.png';
  static const String memberCameraOff = 'assets/icons/member_camera_off.png';
  static const String memberMicNormal = 'assets/icons/member_mic_normal.png';
  static const String memberMicOff = 'assets/icons/member_mic_off.png';
  static const String memberMicSpeaking =
      'assets/icons/member_mic_speaking.png';

  static const String topMemberNormal = 'assets/icons/top_member_normal.png';
  static const String topCameraOverturn =
      'assets/icons/top_camera_overturn.png';
}
