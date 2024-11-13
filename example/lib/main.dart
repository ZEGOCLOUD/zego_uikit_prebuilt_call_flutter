// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

/// Please follow the link below to see more details:
/// https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter

/// this is a normal call demo.
/// about call invitation or offline call, please see in github demo
Widget normalCallPage() {
  return ZegoUIKitPrebuiltCall(
    appID: -1, // your AppID,
    appSign: 'your AppSign',
    userID: 'local user id',
    userName: 'local user name',
    callID: 'call id',
    config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
  );
}
