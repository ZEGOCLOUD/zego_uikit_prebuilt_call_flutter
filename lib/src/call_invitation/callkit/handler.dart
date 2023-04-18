// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';

// Package imports:
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zpns/zego_zpns.dart';

/// Android Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(ZPNsMessage message) async {
  /// message data format:
  ///
  /// title:user_378508
  /// content:
  /// extras:
  /// {
  /// 	body: Incoming video call...,
  /// 	title: user_378508,
  /// 	payload: {
  /// 		"inviter_name": "user_378508",
  /// 		"type": 1,
  /// 		"data": {
  ///             	"call_id": "call_378508_1681123982106",
  ///             	"invitees": [{
  ///             		"user_id": "553625",
  ///             		"user_name": "user_553625"
  ///             	}],
  ///             	"custom_data": ""
  ///             }
  /// 	}
  /// }

  ZegoLoggerService.logInfo(
    'on background message received: '
    'title:${message.title}'
    'content:${message.content}'
    'extras:${message.extras}',
    tag: 'call',
    subTag: 'background message',
  );

  final payload = message.extras['payload'] as String? ?? '';
  final extendedMap = jsonDecode(payload) as Map<String, dynamic>;
  final inviterName = extendedMap['inviter_name'] as String;
  final callType = ZegoCallTypeExtension.mapValue[extendedMap['type'] as int] ??
      ZegoCallType.voiceCall;
  final invitationInternalData =
      InvitationInternalData.fromJson(extendedMap['data'] as String);

  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
    ZegoLoggerService.logInfo(
      'callkit incoming event, body:${event?.body}, event:${event?.event}',
      tag: 'call',
      subTag: 'background message',
    );

    switch (event!.event) {
      case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
        break;
      case Event.ACTION_CALL_INCOMING:
        break;
      case Event.ACTION_CALL_START:
        break;
      case Event.ACTION_CALL_ACCEPT:
        break;
      case Event.ACTION_CALL_DECLINE:

        /// todo@yuyj lack of invitationID
        // ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
        //       invitationID: '',
        //       data: '{"reason":"decline"}',
        //     );
        break;
      case Event.ACTION_CALL_ENDED:
        break;
      case Event.ACTION_CALL_TIMEOUT:
        break;
      case Event.ACTION_CALL_CALLBACK:
        break;
      case Event.ACTION_CALL_TOGGLE_HOLD:
        break;
      case Event.ACTION_CALL_TOGGLE_MUTE:
        break;
      case Event.ACTION_CALL_TOGGLE_DMTF:
        break;
      case Event.ACTION_CALL_TOGGLE_GROUP:
        break;
      case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
        break;
    }
  });
  await showCallkitIncoming(
    caller: ZegoUIKitUser(id: '', name: inviterName),
    callType: callType,
    invitationInternalData: invitationInternalData,
  );
}

/// iOS VoIP event callback
void onIncomingPushReceived(Map extras, UUID uuid) {
  ZegoLoggerService.logInfo(
    'on incoming push received: extras:$extras',
    tag: 'call',
    subTag: 'background message',
  );

  final payload = extras['payload'] as String? ?? '';
  final extendedMap = jsonDecode(payload) as Map<String, dynamic>;
  final inviterName = extendedMap['inviter_name'] as String;
  final callType = ZegoCallTypeExtension.mapValue[extendedMap['type'] as int] ??
      ZegoCallType.voiceCall;
  final invitationInternalData =
      InvitationInternalData.fromJson(extendedMap['data'] as String);

  /// cache callkit param,
  /// and wait for the onInvitationReceive callback of page manger
  final callKitParam = makeSimpleCallKitParam(
    caller: ZegoUIKitUser(id: '', name: inviterName),
    callType: callType,
    invitationInternalData: invitationInternalData,
  );
  ZegoUIKitPrebuiltCallInvitationService().callKitParams = callKitParam;
}
