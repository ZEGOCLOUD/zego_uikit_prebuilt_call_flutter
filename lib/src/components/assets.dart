// Flutter imports:
import 'package:flutter/material.dart';

/// @nodoc
class PrebuiltCallImage {
  static Image asset(String name) {
    return Image.asset(name, package: 'zego_uikit_prebuilt_call');
  }
}

/// @nodoc
class PrebuiltCallIconUrls {
  static const String back = 'assets/icons/back.png';
  static const String minimizing = 'assets/icons/minimizing.png';

  static const String topMemberNormal = 'assets/icons/top_member_normal.png';
  static const String topCameraOverturn =
      'assets/icons/top_camera_overturn.png';
}
