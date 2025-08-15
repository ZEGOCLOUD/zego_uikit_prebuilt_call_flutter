// Dart imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// 最小化类型
enum ZegoMinimizeType {
  none,    // 未最小化
  inCall,  // 通话中最小化
  inviting, // 邀请中最小化
}

/// 通话中最小化数据
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

/// 邀请中最小化数据
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

/// 最小化数据 - 使用联合类型
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

  // 联合类型数据 - 只能有一个不为null
  final ZegoInCallMinimizeData? inCallData;
  final ZegoInvitingMinimizeData? invitingData;

  /// 获取最小化类型
  ZegoMinimizeType get type {
    if (inCallData != null) return ZegoMinimizeType.inCall;
    if (invitingData != null) return ZegoMinimizeType.inviting;
    return ZegoMinimizeType.none;
  }

  /// 检查是否为通话中最小化
  bool get isInCall => type == ZegoMinimizeType.inCall;

  /// 检查是否为邀请中最小化
  bool get isInviting => type == ZegoMinimizeType.inviting;

  /// 获取通话中数据
  ZegoInCallMinimizeData? get inCall => inCallData;

  /// 获取邀请中数据
  ZegoInvitingMinimizeData? get inviting => invitingData;
}
