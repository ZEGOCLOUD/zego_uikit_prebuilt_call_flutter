// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_zpns/zego_zpns.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/call_invitation_service.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';

/// @nodoc
///
/// [Android] Silent Notification event notify
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
      case Event.actionDidUpdateDevicePushTokenVoip:
        break;
      case Event.actionCallIncoming:
        break;
      case Event.actionCallStart:
        break;
      case Event.actionCallAccept:

        /// android only receive onBackgroundMessageReceived if App BE KILLED,
        /// so [ACTION_CALL_ACCEPT] event should be ignore,
        /// deal in [onInvitationReceived] supply again by ZIM when app re-start
        break;
      case Event.actionCallDecline:

        /// todo@yuyj [onBackgroundMessageReceived] lack of invitationID
        // ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
        //       invitationID: '',
        //       data: '{"reason":"decline"}',
        //     );
        break;
      case Event.actionCallEnded:
        break;
      case Event.actionCallTimeout:
        break;
      case Event.actionCallCallback:
        break;
      case Event.actionCallToggleHold:
        break;
      case Event.actionCallToggleMute:
        break;
      case Event.actionCallToggleDmtf:
        break;
      case Event.actionCallToggleGroup:
        break;
      case Event.actionCallToggleAudioSession:
        break;
      case Event.actionCallCustom:
        // TODO: Handle this case.
        break;
    }
  });

  /// cache
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(CallKitCalIDCacheKey, invitationInternalData.callID);

  await showCallkitIncoming(
    caller: ZegoUIKitUser(id: '', name: inviterName),
    callType: callType,
    invitationInternalData: invitationInternalData,
  );
}

/// @nodoc
///
/// [iOS] VoIP event callback
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
  ZegoUIKitPrebuiltCallInvitationService().callKitCallID = callKitParam.handle;

  ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
}
