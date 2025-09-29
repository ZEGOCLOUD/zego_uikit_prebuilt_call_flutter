// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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

  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final bool isPrebuiltFromMinimizing;
  final List<IZegoUIKitPlugin>? plugins;
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

  final ZegoCallInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final bool isInviter;
  final ZegoCallInvitationPageManager pageManager;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  final String? customData;
}

/// Minimized data - using union type pattern
class ZegoCallMinimizeData {
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

  final int appID;
  final String appSign;
  final String token;
  final String userID;
  final String userName;
  final String callID;
  final VoidCallback? onDispose;

  // Union type data - only one can be non-null
  final ZegoInCallMinimizeData? inCallData;
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
