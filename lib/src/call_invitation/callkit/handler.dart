// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zpns/zego_zpns.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/shared_pref_defines.dart';

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
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}',
    tag: 'call',
    subTag: 'background message',
  );

  final title = message.extras['title'] as String? ?? '';
  final body = message.extras['body'] as String? ?? '';
  final payload = message.extras['payload'] as String? ?? '';
  final invitationID = message.extras['call_id'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
  final inviterName = payloadMap['inviter_name'] as String;
  final callType = ZegoCallTypeExtension.mapValue[payloadMap['type'] as int] ??
      ZegoCallType.voiceCall;
  final invitationInternalData =
      InvitationInternalData.fromJson(payloadMap['data'] as String);

  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
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
        await _declineBackgroundCall(invitationID);
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
  setCurrentCallKitCallID(invitationInternalData.callID);

  await showCallkitIncoming(
    caller: ZegoUIKitUser(id: '', name: inviterName),
    callType: callType,
    invitationInternalData: invitationInternalData,
    title: title,
    body: body,
  );
}

Future<void> _declineBackgroundCall(String invitationID) async {
  final appSign = await getPreferenceString(
    serializationKeyAppSign,
    withDecode: true,
  );
  final handlerInfoJson =
      await getPreferenceString(serializationKeyHandlerInfo);
  final handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);

  ZegoLoggerService.logInfo(
    'decline android background call, handler info:$handlerInfo',
    tag: 'call',
    subTag: 'background message',
  );

  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);
  await ZegoUIKit()
      .getSignalingPlugin()
      .init(int.tryParse(handlerInfo.appID) ?? 0, appSign: appSign);
  await ZegoUIKit().getSignalingPlugin().login(
        id: handlerInfo.userID,
        name: handlerInfo.userName,
      );

  await ZegoUIKit()
      .getSignalingPlugin()
      .enableNotifyWhenAppRunningInBackgroundOrQuit(
        true,
        isIOSSandboxEnvironment: handlerInfo.isIOSSandboxEnvironment,
        enableIOSVoIP: handlerInfo.enableIOSVoIP,
        certificateIndex: handlerInfo.certificateIndex,
        appName: handlerInfo.appName,
        androidChannelID: handlerInfo.androidChannelID,
        androidChannelName: handlerInfo.androidChannelName,
        androidSound: '/raw/${handlerInfo.androidSound}',
      );

  await ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
        invitationID: invitationID,
        data: '{"reason":"decline"}',
      );
  await ZegoUIKit().getSignalingPlugin().uninit();
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

  final invitationID = extras['call_id'] as String? ?? '';
  final payload = extras['payload'] as String? ?? '';
  final extendedMap = jsonDecode(payload) as Map<String, dynamic>;
  final invitationInternalData =
      InvitationInternalData.fromJson(extendedMap['data'] as String);

  /// cache callkit param,
  /// and wait for the onInvitationReceive callback of page manger
  setCurrentCallKitCallID(invitationInternalData.callID);

  ZegoUIKit().getSignalingPlugin().activeAudioByCallKit();
}

class HandlerPrivateInfo {
  String appID;
  String userID;
  String userName;
  bool isIOSSandboxEnvironment;
  bool enableIOSVoIP;
  int certificateIndex;
  String appName;
  String androidChannelID;
  String androidChannelName;
  String androidSound;

  HandlerPrivateInfo({
    required this.appID,
    required this.userID,
    required this.userName,
    this.isIOSSandboxEnvironment = false,
    this.enableIOSVoIP = true,
    this.certificateIndex = 1,
    this.appName = '',
    this.androidChannelID = '',
    this.androidChannelName = '',
    this.androidSound = '',
  });

  factory HandlerPrivateInfo.fromJson(Map<String, dynamic> json) {
    return HandlerPrivateInfo(
      appID: json['aid'],
      userID: json['uid'],
      userName: json['un'],
      isIOSSandboxEnvironment: json['isse'] ?? false,
      enableIOSVoIP: json['eiv'] ?? true,
      certificateIndex: json['ci'] ?? 1,
      appName: json['an'] ?? '',
      androidChannelID: json['aci'] ?? '',
      androidChannelName: json['acn'] ?? '',
      androidSound: json['as'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': appID,
      'uid': userID,
      'un': userName,
      'isse': isIOSSandboxEnvironment,
      'eiv': enableIOSVoIP,
      'ci': certificateIndex,
      'an': appName,
      'aci': androidChannelID,
      'acn': androidChannelName,
      'as': androidSound,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static HandlerPrivateInfo fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return HandlerPrivateInfo.fromJson(json);
  }
}
