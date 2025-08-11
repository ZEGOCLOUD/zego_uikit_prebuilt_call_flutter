// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/cache/cache.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/callkit_incoming.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';
import 'defines.dart';

class ZegoCallIOSCallBackgroundMessageHandler {
  Future<void> handle(
    ZegoCallIOSBackgroundMessageHandlerMessage message,
  ) async {
    final isAdvanceMode = ZegoUIKitAdvanceInvitationSendProtocol.typeOf(
      message.payloadMap,
    );
    ZegoLoggerService.logInfo(
      'isAdvanceMode:$isAdvanceMode',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    String payloadCustomData = '';
    if (isAdvanceMode) {
      final sendProtocol = ZegoUIKitAdvanceInvitationSendProtocol.fromJson(
        message.payloadMap,
      );

      ZegoLoggerService.logInfo(
        'advance sendProtocol:$sendProtocol',
        tag: 'call-invitation',
        subTag: 'offline',
      );

      payloadCustomData = sendProtocol.customData;
    } else {
      final sendProtocol = ZegoUIKitInvitationSendProtocol.fromJson(
        message.payloadMap,
      );

      ZegoLoggerService.logInfo(
        'sendProtocol:$sendProtocol',
        tag: 'call-invitation',
        subTag: 'offline',
      );

      payloadCustomData = sendProtocol.customData;
    }
    ZegoLoggerService.logInfo(
      'payload custom data:$payloadCustomData',
      tag: 'call-invitation',
      subTag: 'offline',
    );

    final invitationInternalData =
        ZegoCallInvitationSendRequestProtocol.fromJson(payloadCustomData);

    /// cache callkit param,
    /// and wait for the onInvitationReceive callback of page manger
    await ZegoUIKitCallCache()
        .offlineCallKit
        .setCallID(invitationInternalData.callID)
        .then((value) {
      // flag[0] = true;

      ZegoLoggerService.logInfo(
        'cache ${invitationInternalData.callID} done',
        tag: 'call-invitation',
        subTag: 'offline',
      );
    });
  }
}
