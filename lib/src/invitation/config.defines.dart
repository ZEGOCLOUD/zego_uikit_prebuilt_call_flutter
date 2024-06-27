// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

class ZegoCallingBuilderInfo {
  ZegoCallingBuilderInfo({
    required this.inviter,
    required this.invitees,
    required this.callType,
  });

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallInvitationType callType;
}

typedef ZegoCallingBackgroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);

typedef ZegoCallingForegroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);

typedef ZegoCallingPageBuilder = Widget? Function(
  BuildContext context,
  ZegoCallingBuilderInfo info,
);

class ZegoCallButtonUIConfig {
  Size? size;
  bool visible;

  /// Customize the icon through [icon]
  Widget? icon;
  Size? iconSize;

  TextStyle? textStyle;

  ZegoCallButtonUIConfig({
    this.visible = true,
    this.size,
    this.icon,
    this.iconSize,
    this.textStyle,
  });

  @override
  String toString() {
    return 'ZegoCallButtonUIConfig:{'
        'visible:$visible, '
        'icon:$icon, '
        '}';
  }
}

typedef ZegoCallInvitationNotifyDialogBuilder = Widget Function(
  ZegoCallInvitationData invitationData,
);

class ZegoCallInvitationNotifyPopUpUIConfig {
  EdgeInsetsGeometry? padding;
  double? width;
  double? height;
  Decoration? decoration;

  /// when receiving an online call, whether to pop up the top pop-up dialog
  ///
  /// If you want to customize the invitation pop-up dialog, set
  /// [visible] to false and listen
  /// [ZegoUIKitPrebuiltCallInvitationEvents.onIncomingCallReceived], when
  /// you receive the invitation event, show invitation widget
  /// ```dart
  /// invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
  ///   onIncomingCallReceived: (
  ///     String callID,
  ///     ZegoCallUser caller,
  ///     ZegoCallInvitationType callType,
  ///     List<ZegoCallUser> callees,
  ///     String customData,
  ///   ) {
  ///   /// show your custom call notification
  ///   },
  /// ),
  /// uiConfig: ZegoCallInvitationUIConfig(
  ///   popUp: ZegoCallInvitationNotifyPopUpUIConfig(
  ///     visible: false,
  ///   ),
  /// ),
  /// ```
  bool visible;

  /// custom the top pop-up dialog which receiving an online call
  /// ```dart
  /// popUp: ZegoCallInvitationNotifyPopUpUIConfig(
  ///         builder: (
  ///           ZegoCallInvitationData invitationData,
  ///         ) {
  ///         /// show your custom popup dialog,
  ///         /// and call ZegoUIKitPrebuiltCallInvitationService().accept() if you accept
  ///         /// and call ZegoUIKitPrebuiltCallInvitationService().reject() if you reject
  ///         },
  ///       ),
  /// ```
  ZegoCallInvitationNotifyDialogBuilder? builder;

  ZegoCallInvitationNotifyPopUpUIConfig({
    this.width,
    this.height,
    this.decoration,
    this.padding,
    this.builder,
    this.visible = true,
  });

  @override
  String toString() {
    return 'ZegoCallInvitationNotifyPopUpUIConfig:{'
        'width: $width, '
        'height: $height, '
        'decoration: $decoration, '
        'padding: $padding, '
        'builder: $builder, '
        'visible: $visible, '
        '}';
  }
}

enum ZegoCallInvitationPermission {
  camera,
  microphone,
}
