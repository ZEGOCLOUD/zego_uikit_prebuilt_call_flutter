// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/notification.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

/// This button is used to send a call invitation to one or more specified users.
///
/// You can provide a target user list [invitees] and specify whether it is a video call [isVideoCall]. If it is not a video call, it defaults to an audio call.
/// You can also pass additional custom data [customData] to the invitees.
/// If you want to set a custom ringtone for the offline call invitation, set [resourceID] to a value that matches the push resource ID in the ZEGOCLOUD management console.
/// You can also set the notification title [notificationTitle] and message [notificationMessage].
/// If the call times out, the call will automatically hang up after the specified timeout period [timeoutSeconds] (in seconds).
class ZegoSendCallInvitationButton extends StatefulWidget {
  const ZegoSendCallInvitationButton({
    Key? key,
    required this.invitees,
    required this.isVideoCall,
    this.callID,
    this.customData = '',
    this.onWillPressed,
    this.onPressed,
    this.resourceID,
    this.notificationTitle,
    this.notificationMessage,
    this.buttonSize,
    this.borderRadius,
    this.icon,
    this.iconSize,
    this.iconVisible = true,
    this.text,
    this.textStyle,
    this.iconTextSpacing,
    this.verticalLayout = true,
    this.margin,
    this.padding,
    this.timeoutSeconds = 60,
    this.clickableTextColor = Colors.black,
    this.unclickableTextColor = Colors.black,
    this.clickableBackgroundColor = Colors.transparent,
    this.unclickableBackgroundColor = Colors.transparent,
  }) : super(key: key);

  /// The list of invitees to send the call invitation to.
  final List<ZegoUIKitUser> invitees;

  /// you can specify the call ID.
  /// If not provided, the system will generate one automatically based on certain rules.
  final String? callID;

  /// Determines whether the call is a video call. If false, it is an audio call by default.
  final bool isVideoCall;

  /// Custom data to be passed to the invitee.
  final String customData;

  /// send call invitation if return true, false will do nothing
  final Future<bool> Function()? onWillPressed;

  /// Callback function that is executed when the button is pressed.
  final void Function(String code, String message, List<String>)? onPressed;

  /// The [resource id] for notification which same as [Zego Console](https://console.zegocloud.com/)
  final String? resourceID;

  /// The title for the notification.
  final String? notificationTitle;

  /// The message for the notification.
  final String? notificationMessage;

  /// The timeout duration in seconds for the call invitation.
  final int timeoutSeconds;

  /// The size of the button.
  final Size? buttonSize;

  /// The radius of the button.
  final double? borderRadius;

  /// The icon widget for the button.
  final ButtonIcon? icon;

  /// is icon visible or not
  final bool iconVisible;

  /// The size of the icon.
  final Size? iconSize;

  /// The text displayed on the button.
  final String? text;

  /// The text style for the button text.
  final TextStyle? textStyle;

  /// The spacing between the icon and text.
  final double? iconTextSpacing;

  /// Determines whether the layout is vertical or horizontal.
  final bool verticalLayout;

  /// padding of button
  final EdgeInsetsGeometry? margin;

  /// padding of button
  final EdgeInsetsGeometry? padding;

  /// The text color when the button is clickable.
  final Color? clickableTextColor;

  /// The text color when the button is unclickable.
  final Color? unclickableTextColor;

  /// The background color when the button is clickable.
  final Color? clickableBackgroundColor;

  /// The background color when the button is unclickable.
  final Color? unclickableBackgroundColor;

  @override
  State<ZegoSendCallInvitationButton> createState() =>
      _ZegoSendCallInvitationButtonState();
}

/// @nodoc
class _ZegoSendCallInvitationButtonState
    extends State<ZegoSendCallInvitationButton> {
  bool requesting = false;
  ValueNotifier<String> callIDNotifier = ValueNotifier<String>('');

  StreamSubscription<dynamic>? localUserJoinedSubscriptiong;

  ZegoCallInvitationPageManager? get pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoUIKitPrebuiltCallInvitationData? get callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationData;

  ZegoCallInvitationInnerText? get innerText => callInvitationConfig?.innerText;

  @override
  void initState() {
    super.initState();

    if (ZegoUIKit().getLocalUser().id.isEmpty) {
      localUserJoinedSubscriptiong =
          ZegoUIKit().getUserJoinStream().listen(onUserJoined);
    } else {
      updateCallID();
    }
  }

  @override
  void dispose() {
    super.dispose();

    localUserJoinedSubscriptiong?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: callIDNotifier,
      builder: (context, callID, _) {
        return button();
      },
    );
  }

  void updateCallID() {
    callIDNotifier.value = widget.callID ??
        'call_${ZegoUIKit().getLocalUser().id}_${DateTime.now().millisecondsSinceEpoch}';
    // ZegoLoggerService.logInfo(
    //   'update call id, ${callIDNotifier.value}',
    //   tag: 'call-invitation',
    //   subTag: 'components, send call button',
    // );
    if ((widget.callID?.isNotEmpty ?? false) &&
        callIDNotifier.value != widget.callID) {
      ZegoLoggerService.logWarn(
        'callID(${widget.callID}) is not valid, replace by ${callIDNotifier.value}',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );
    }
  }

  Widget button() {
    final canInvitingInCalling = ZegoUIKitPrebuiltCallInvitationService()
            .private
            .callInvitationConfig
            ?.canInvitingInCalling ??
        true;
    // ZegoLoggerService.logError(
    //   'button, '
    //   'canInvitingInCalling:$canInvitingInCalling, ',
    //   tag: 'call-invitation',
    //   subTag: 'components, send call button',
    // );

    return ZegoStartInvitationButton(
      isAdvancedMode: canInvitingInCalling,
      invitationType: ZegoCallTypeExtension(
        widget.isVideoCall
            ? ZegoCallInvitationType.videoCall
            : ZegoCallInvitationType.voiceCall,
      ).value,
      invitees: widget.invitees.map((user) {
        return user.id;
      }).toList(),
      timeoutSeconds: widget.timeoutSeconds,
      data: ZegoCallInvitationSendRequestProtocol(
        callID: callIDNotifier.value,
        invitees: List.from(widget.invitees),
        timeout: widget.timeoutSeconds,
        customData: widget.customData,
      ).toJson(),
      notificationConfig: ZegoNotificationConfig(
        resourceID: widget.resourceID ?? '',
        title: getNotificationTitle(
          defaultTitle: widget.notificationTitle,
          callees:
              widget.invitees.map((e) => ZegoCallUser(e.id, e.name)).toList(),
          isVideoCall: widget.isVideoCall,
          innerText: innerText,
        ),
        message: getNotificationMessage(
          defaultMessage: widget.notificationMessage,
          callees:
              widget.invitees.map((e) => ZegoCallUser(e.id, e.name)).toList(),
          isVideoCall: widget.isVideoCall,
          innerText: innerText,
        ),
        voIPConfig: ZegoNotificationVoIPConfig(
          iOSVoIPHasVideo: widget.isVideoCall,
        ),
      ),
      icon: widget.iconVisible
          ? (widget.icon ??
              ButtonIcon(
                icon: widget.isVideoCall
                    ? ZegoCallImage.asset(InvitationStyleIconUrls.inviteVideo)
                    : ZegoCallImage.asset(InvitationStyleIconUrls.inviteVoice),
              ))
          : null,
      iconSize: widget.iconSize,
      text: widget.text,
      textStyle: widget.textStyle,
      iconTextSpacing: widget.iconTextSpacing,
      verticalLayout: widget.verticalLayout,
      buttonSize: widget.buttonSize,
      borderRadius: widget.borderRadius,
      margin: widget.margin,
      padding: widget.padding,
      onWillPressed: onWillPressed,
      onPressed: onPressed,
      clickableTextColor: widget.clickableTextColor,
      unclickableTextColor: widget.unclickableTextColor,
      clickableBackgroundColor: widget.clickableBackgroundColor,
      unclickableBackgroundColor: widget.unclickableBackgroundColor,
    );
  }

  Future<bool> onWillPressed() async {
    if (ZegoSignalingPluginConnectionState.connected !=
        ZegoUIKit().getSignalingPlugin().getConnectionState()) {
      ZegoLoggerService.logError(
        'signaling is not connected:${ZegoUIKit().getSignalingPlugin().getConnectionState()}, '
        'please call ZegoUIKitPrebuiltCallInvitationService.init with ZegoUIKitSignalingPlugin first',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );
      return false;
    }

    if (requesting) {
      ZegoLoggerService.logError(
        'still in request',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );
      return false;
    }

    if (ZegoCallMiniOverlayMachine().isMinimizing) {
      ZegoLoggerService.logError(
        'is in minimizing now',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );
      return false;
    }

    final currentState =
        pageManager?.callingMachine?.machine.current?.identifier ??
            CallingState.kIdle;
    if (CallingState.kIdle != currentState) {
      ZegoLoggerService.logError(
        'is in calling, $currentState',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );
      return false;
    }

    final canRequest = await widget.onWillPressed?.call() ?? true;
    if (!canRequest) {
      ZegoLoggerService.logWarn(
        'onWillPressed stop click process',
        tag: 'call-invitation',
        subTag: 'components, send call button',
      );

      return false;
    }

    requesting = true;
    ZegoLoggerService.logInfo(
      'start request',
      tag: 'call-invitation',
      subTag: 'components, send call button',
    );

    return true;
  }

  void onPressed(
    String code,
    String message,
    String invitationID,
    List<String> errorInvitees,
  ) {
    ZegoLoggerService.logInfo(
      'pressed, code:$code, message:$message, '
      'invitation id:$invitationID, error invitees:$errorInvitees',
      tag: 'call-invitation',
      subTag: 'components, send call button',
    );

    pageManager?.onLocalSendInvitation(
      callID: callIDNotifier.value,
      invitees: List.from(widget.invitees),
      invitationType: widget.isVideoCall
          ? ZegoCallInvitationType.videoCall
          : ZegoCallInvitationType.voiceCall,
      customData: widget.customData,
      code: code,
      message: message,
      invitationID: invitationID,
      errorInvitees: errorInvitees,
      localConfig: ZegoCallInvitationLocalParameter(
        resourceID: widget.resourceID,
        notificationTitle: widget.notificationTitle,
        notificationMessage: widget.notificationMessage,
        timeoutSeconds: widget.timeoutSeconds,
      ),
    );

    if (widget.onPressed != null) {
      widget.onPressed!(code, message, errorInvitees);
    }

    updateCallID();

    requesting = false;

    ZegoLoggerService.logInfo(
      'pressed, finish request',
      tag: 'call-invitation',
      subTag: 'components, send call button',
    );
  }

  void onUserJoined(List<ZegoUIKitUser> users) {
    final index = users.indexWhere((user) {
      if (user.id.isEmpty) {
        return false;
      }

      return user.id == ZegoUIKit().getLocalUser().id;
    });

    if (-1 == index) {
      return;
    }

    /// local user joined
    localUserJoinedSubscriptiong?.cancel();
    updateCallID();
  }
}
