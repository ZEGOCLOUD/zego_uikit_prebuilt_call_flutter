// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_callkit/zego_callkit.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';

UUID? iOSIncomingPushUUID;

/// @nodoc
///
/// [iOS] VoIP event callback
void onIncomingPushReceived(Map<dynamic, dynamic> extras, UUID uuid) async {
  ZegoLoggerService.logInfo(
    'on message received: '
    'extras:$extras, uuid:$uuid',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  iOSIncomingPushUUID = uuid;

  final payload = extras['payload'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;

  final isAdvanceMode =
      ZegoUIKitAdvanceInvitationSendProtocol.typeOf(payloadMap);
  ZegoLoggerService.logInfo(
    'isAdvanceMode:$isAdvanceMode',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  String payloadCustomData = '';
  if (isAdvanceMode) {
    final sendProtocol =
        ZegoUIKitAdvanceInvitationSendProtocol.fromJson(payloadMap);

    ZegoLoggerService.logInfo(
      'advance sendProtocol:$sendProtocol',
      tag: 'call-invitation',
      subTag: 'offline',
    );

    payloadCustomData = sendProtocol.customData;
  } else {
    final sendProtocol = ZegoUIKitInvitationSendProtocol.fromJson(payloadMap);

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
  await setOfflineCallKitCallID(invitationInternalData.callID).then((value) {
    // flag[0] = true;

    ZegoLoggerService.logInfo(
      'cache ${invitationInternalData.callID}',
      tag: 'call-invitation',
      subTag: 'offline',
    );
  });
}
