// Flutter imports:
import 'package:flutter/material.dart';

/// @nodoc
class ZegoCallImage {
  static Image asset(
    String name, {
    double? width,
    double? height,
  }) {
    return Image.asset(
      name,
      package: 'zego_uikit_prebuilt_call',
      width: width,
      height: height,
    );
  }
}

/// @nodoc
class ZegoCallIconUrls {
  static const String back = 'assets/icons/back.png';
  static const String minimizing = 'assets/icons/minimizing.png';
  static const String pip = 'assets/icons/pip.png';
  static const String im = 'assets/icons/im.png';

  static const String topMemberNormal = 'assets/icons/top_member_normal.png';
  static const String topCameraOverturn =
      'assets/icons/top_camera_overturn.png';
  static const String toolbarBeautyEffect = 'assets/icons/toolbar_beauty.png';
  static const String toolbarSoundEffect = 'assets/icons/toolbar_sound.png';
  static const String topMemberIM = 'assets/icons/top_im.png';
}
