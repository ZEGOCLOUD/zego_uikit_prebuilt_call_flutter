// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_callkit/zego_callkit.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';

UUID? iOSIncomingPushUUID;

/// @nodoc
///
/// [iOS] VoIP event callback
void onIncomingPushReceived(Map<dynamic, dynamic> extras, UUID uuid) async {
  ZegoLoggerService.logInfo(
    'on incoming push received: extras:$extras, uuid:$uuid',
    tag: 'call',
    subTag: 'background message',
  );

  iOSIncomingPushUUID = uuid;

  // final invitationID = extras['call_id'] as String? ?? '';
  final payload = extras['payload'] as String? ?? '';
  final extendedMap = jsonDecode(payload) as Map<String, dynamic>;
  final invitationInternalData =
      InvitationSendRequestData.fromJson(extendedMap['data'] as String);

  /// cache callkit param,
  /// and wait for the onInvitationReceive callback of page manger
  await setOfflineCallKitCallID(invitationInternalData.callID).then((value) {
    ZegoLoggerService.logInfo(
      'cache ${invitationInternalData.callID}',
      tag: 'call',
      subTag: 'background message',
    );
  });

  await ZegoCallPluginPlatform.instance.activeAudioByCallKit().then((value) {
    ZegoLoggerService.logInfo(
      'activeAudioByCallKit',
      tag: 'call',
      subTag: 'background message',
    );
  });
}
