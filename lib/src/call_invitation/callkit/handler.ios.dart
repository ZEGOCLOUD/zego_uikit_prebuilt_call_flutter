// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_zpns/zego_zpns.dart';

/// @nodoc
///
/// [iOS] VoIP event callback
void onIncomingPushReceived(Map<dynamic, dynamic> extras, UUID uuid) {
  ZegoLoggerService.logInfo(
    'on incoming push received: extras:$extras',
    tag: 'call',
    subTag: 'background message',
  );

  // final invitationID = extras['call_id'] as String? ?? '';
  final payload = extras['payload'] as String? ?? '';
  final extendedMap = jsonDecode(payload) as Map<String, dynamic>;
  final invitationInternalData =
      InvitationInternalData.fromJson(extendedMap['data'] as String);

  /// cache callkit param,
  /// and wait for the onInvitationReceive callback of page manger
  setCurrentCallKitCallID(invitationInternalData.callID);

  ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
}
