// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

/// Builder information for the calling page.
/// Contains information about the inviter, invitees, call type, and custom data.
class ZegoCallingBuilderInfo {
  /// The user who initiated the call invitation.
  final ZegoUIKitUser inviter;

  /// The list of users being invited.
  final List<ZegoUIKitUser> invitees;

  /// The type of call (voice or video).
  final ZegoCallInvitationType callType;

  /// Custom data passed with the invitation.
  final String customData;

  ZegoCallingBuilderInfo({
    required this.inviter,
    required this.invitees,
    required this.callType,
    required this.customData,
  });
}

/// Background builder function for the calling page.
/// This allows you to customize the background of the calling view.
typedef ZegoCallingBackgroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);

/// Foreground builder function for the calling page.
/// This allows you to add custom widgets on top of the calling view.
typedef ZegoCallingForegroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);

/// Custom page builder function for the calling page.
/// This allows you to replace the entire calling page with a custom widget.
typedef ZegoCallingPageBuilder = Widget? Function(
  BuildContext context,
  ZegoCallingBuilderInfo info,
);

/// Button UI configuration class for button visibility, size, icons, and styling.
class ZegoCallButtonUIConfig {
  /// The size of the button.
  Size? size;

  /// Whether the button is visible.
  bool visible;

  /// Customize the icon through [icon]
  Widget? icon;

  /// The size of the button icon.
  Size? iconSize;

  /// The text style for the button.
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

/// Builder function for the invitation notification dialog.
/// This allows you to customize the dialog that appears when receiving a call invitation.
typedef ZegoCallInvitationNotifyDialogBuilder = Widget Function(
  ZegoCallInvitationData invitationData,
);

/// Invitation popup UI configuration class for displaying invitation popups and custom builders when receiving invitations.
class ZegoCallInvitationNotifyPopUpUIConfig {
  /// The padding around the popup.
  EdgeInsetsGeometry? padding;

  /// The width of the popup.
  double? width;

  /// The height of the popup.
  double? height;

  /// The decoration for the popup.
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

  /// Not using it will cause full-screen pop-ups to fail to appear on the lock screen
  systemAlertWindow,

  /// Some permissions cannot be obtained directly and must be set manually by the user
  ///
  /// If this item is included, a pop-up window will guide the customer to
  /// turn on these options when ZegoUIKitPrebuiltCallInvitationService is initialized for the first time
  manuallyByUser,
}

/// Predefined permission configurations for call invitations.
class ZegoCallInvitationPermissions {
  /// Permissions without system alert window (camera and microphone).
  static List<ZegoCallInvitationPermission> get withoutSystemAlertWindow => [
        ZegoCallInvitationPermission.camera,
        ZegoCallInvitationPermission.microphone,
      ];

  /// Audio-only permissions (microphone only).
  static List<ZegoCallInvitationPermission> get audio => [
        ZegoCallInvitationPermission.microphone,
      ];
}

/// System confirmation dialog info for permission requests.
/// Used when requesting system permissions like system alert window on Android.
class ZegoCallSystemConfirmDialogInfo extends ZegoCallConfirmDialogInfo {
  ZegoCallSystemConfirmDialogInfo({
    required super.title,
    super.message = '',
    super.cancelButtonName = 'Deny',
    super.confirmButtonName = 'Allow',
  });
}
