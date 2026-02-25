// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// Minimization type
enum ZegoMinimizeType {
  none, // Not minimized
  inCall, // In-call minimized
  inviting, // Inviting minimized
}

/// In-call minimized data
class ZegoInCallMinimizeData {
  const ZegoInCallMinimizeData({
    required this.config,
    required this.events,
    required this.isPrebuiltFromMinimizing,
    required this.plugins,
    required this.durationStartTime,
  });

  /// The call configuration.
  final ZegoUIKitPrebuiltCallConfig config;

  /// The call events handler.
  final ZegoUIKitPrebuiltCallEvents events;

  /// Whether the call was prebuilt from a minimized state.
  final bool isPrebuiltFromMinimizing;

  /// The plugins used by the call.
  final List<IZegoUIKitPlugin>? plugins;

  /// The start time of the call duration.
  final DateTime durationStartTime;
}

/// Inviting minimized data
class ZegoInvitingMinimizeData {
  const ZegoInvitingMinimizeData({
    required this.invitationType,
    required this.inviter,
    required this.invitees,
    required this.isInviter,
    required this.pageManager,
    required this.callInvitationData,
    this.customData,
  });

  /// The type of call invitation (voice or video).
  final ZegoCallInvitationType invitationType;

  /// The user who initiated the invitation.
  final ZegoUIKitUser inviter;

  /// The list of users being invited.
  final List<ZegoUIKitUser> invitees;

  /// Whether the current user is the inviter.
  final bool isInviter;

  /// The page manager for the invitation.
  final ZegoCallInvitationPageManager pageManager;

  /// The call invitation data.
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;

  /// Custom data passed with the invitation.
  final String? customData;
}

/// Minimized data - using union type pattern
/// Minimized data containing information needed to restore or manage minimized call states.
class ZegoCallMinimizeData {
  /// Creates minimized data for an in-call minimized state.
  const ZegoCallMinimizeData.inCall({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    required this.onDispose,
    required this.inCallData,
  }) : invitingData = null;

  /// Creates minimized data for an inviting minimized state.
  const ZegoCallMinimizeData.inviting({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    required this.onDispose,
    required this.invitingData,
  }) : inCallData = null;

  /// The ZEGOCLOUD app ID.
  final int appID;

  /// The app sign for authentication.
  final String appSign;

  /// The token for authentication.
  final String token;

  /// The user ID.
  final String userID;

  /// The user name.
  final String userName;

  /// The call ID.
  final String callID;

  /// Callback when the call is disposed.
  final VoidCallback? onDispose;

  // Union type data - only one can be non-null

  /// In-call minimized data (non-null when in inCall state).
  final ZegoInCallMinimizeData? inCallData;

  /// Inviting minimized data (non-null when in inviting state).
  final ZegoInvitingMinimizeData? invitingData;

  /// Get minimization type
  ZegoMinimizeType get type {
    if (inCallData != null) return ZegoMinimizeType.inCall;
    if (invitingData != null) return ZegoMinimizeType.inviting;
    return ZegoMinimizeType.none;
  }

  /// Check if it's in-call minimized
  bool get isInCall => type == ZegoMinimizeType.inCall;

  /// Check if it's inviting minimized
  bool get isInviting => type == ZegoMinimizeType.inviting;

  /// Get in-call data
  ZegoInCallMinimizeData? get inCall => inCallData;

  /// Get inviting data
  ZegoInvitingMinimizeData? get inviting => invitingData;
}
