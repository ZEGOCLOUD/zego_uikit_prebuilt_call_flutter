// Package imports:
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const String CallKitCalIDCacheKey = 'callkit_call_id';

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
Future<CallKitParams> makeCallKitParam({
  required ZegoUIKitUser? caller,
  required ZegoCallType callType,
  required InvitationInternalData invitationInternalData,
  String ringtonePath = 'system_ringtone_default',
}) async {
  // final timestampFormat = DateTime.fromMillisecondsSinceEpoch(
  //         int.tryParse(invitationInternalData.callID.split('_').last) ?? 0)
  //     .toString();

  final prefs = await SharedPreferences.getInstance();

  return CallKitParams(
    id: const Uuid().v4(),
    //invitationInternalData.callID
    nameCaller: caller?.name ?? '',
    appName: prefs.getString(CallKitInnerVariable.textAppName.cacheKey) ??
        CallKitInnerVariable.textAppName.defaultValue,
    // avatar: 'https://i.pravatar.cc/100',
    handle: invitationInternalData.callID,
    //timestampFormat.substring(0, timestampFormat.length - 4),
    //  callkit type: 0 - Audio Call, 1 - Video Call
    type: callType.index.toDouble(),
    duration: prefs.getDouble(CallKitInnerVariable.duration.cacheKey) ??
        CallKitInnerVariable.duration.defaultValue,
    textAccept: prefs.getString(CallKitInnerVariable.textAccept.cacheKey) ??
        CallKitInnerVariable.textAccept.defaultValue,
    textDecline: prefs.getString(CallKitInnerVariable.textDecline.cacheKey) ??
        CallKitInnerVariable.textDecline.defaultValue,
    textMissedCall:
        prefs.getString(CallKitInnerVariable.textMissedCall.cacheKey) ??
            CallKitInnerVariable.textMissedCall.defaultValue,
    textCallback: prefs.getString(CallKitInnerVariable.textCallback.cacheKey) ??
        CallKitInnerVariable.textCallback.defaultValue,
    extra: <String, dynamic>{},
    headers: <String, dynamic>{},
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      isShowCallback: true,
      isShowMissedCallNotification: false,
      ringtonePath: ringtonePath,
      backgroundColor:
          prefs.getString(CallKitInnerVariable.backgroundColor.cacheKey) ??
              CallKitInnerVariable.backgroundColor.defaultValue,
      backgroundUrl:
          prefs.getString(CallKitInnerVariable.backgroundUrl.cacheKey) ??
              CallKitInnerVariable.backgroundUrl.defaultValue,
      actionColor: prefs.getString(CallKitInnerVariable.actionColor.cacheKey) ??
          CallKitInnerVariable.actionColor.defaultValue,
    ),
    ios: IOSParams(
      iconName: prefs.getString(CallKitInnerVariable.iconName.cacheKey) ??
          CallKitInnerVariable.iconName.defaultValue,
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: ringtonePath,
    ),
  );
}

CallKitParams makeSimpleCallKitParam({
  required ZegoUIKitUser? caller,
  required ZegoCallType callType,
  required InvitationInternalData invitationInternalData,
  String ringtonePath = 'system_ringtone_default',
}) {
  // final timestampFormat = DateTime.fromMillisecondsSinceEpoch(
  //         int.tryParse(invitationInternalData.callID.split('_').last) ?? 0)
  //     .toString();

  return CallKitParams(
    id: const Uuid().v4(),
    //invitationInternalData.callID
    nameCaller: caller?.name ?? '',
    appName: CallKitInnerVariable.textAppName.defaultValue,
    // avatar: 'https://i.pravatar.cc/100',
    //timestampFormat.substring(0, timestampFormat.length - 4),
    handle: invitationInternalData.callID,
    //  callkit type: 0 - Audio Call, 1 - Video Call
    type: callType.index.toDouble(),
    duration: CallKitInnerVariable.duration.defaultValue,
    textAccept: CallKitInnerVariable.textAccept.defaultValue,
    textDecline: CallKitInnerVariable.textDecline.defaultValue,
    textMissedCall: CallKitInnerVariable.textMissedCall.defaultValue,
    textCallback: CallKitInnerVariable.textCallback.defaultValue,
    extra: <String, dynamic>{},
    headers: <String, dynamic>{},
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      isShowCallback: true,
      isShowMissedCallNotification: false,
      ringtonePath: ringtonePath,
      backgroundColor: CallKitInnerVariable.backgroundColor.defaultValue,
      backgroundUrl: CallKitInnerVariable.backgroundUrl.defaultValue,
      actionColor: CallKitInnerVariable.actionColor.defaultValue,
    ),
    ios: IOSParams(
      iconName: CallKitInnerVariable.iconName.defaultValue,
      handleType: '',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: ringtonePath,
    ),
  );
}

Future<void> showCallkitIncoming({
  required ZegoUIKitUser? caller,
  required ZegoCallType callType,
  required InvitationInternalData invitationInternalData,
  String ringtonePath = 'system_ringtone_default',
}) async {
  final callKitParam = await makeCallKitParam(
    caller: caller,
    callType: callType,
    invitationInternalData: invitationInternalData,
  );

  ZegoLoggerService.logInfo(
    'show callkit incoming, inviter name:${caller?.name}, call type:$callType, '
    'data:${invitationInternalData.toJson()}, '
    'callKitParam:${callKitParam.toJson()}',
    tag: 'call',
    subTag: 'background message',
  );

  return FlutterCallkitIncoming.showCallkitIncoming(callKitParam);
}

/// {
/// 	id: $uuid,
/// 	nameCaller: $inviter_name,
/// 	appName: ,
/// 	handle: $call_id,
/// 	avatar: https: //i.pravatar.cc/100,
/// 	type: $call_type,
/// 	duration: 30000.0,
/// 	textAccept: Accept,
/// 	textDecline: Decline,
/// 	textMissedCall: Missed call,
/// 	textCallback: Call back,
/// 	extra: {
/// 		userId: 1 a2b3c4d
/// 	},
/// 	headers: {
/// 		apiKey: Abc @123!,
/// 		platform: flutter
/// 	},
/// 	android: null,
/// 	ios: null
/// }
Future<CallKitParams?> getCurrentCallKitCall() async {
  final calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    ZegoLoggerService.logInfo(
      'activeCalls:${calls.length}',
      tag: 'call',
      subTag: 'background message',
    );
    if (calls.isNotEmpty) {
      return convertCallKitCallToParam(calls.last as Map<dynamic, dynamic>);
    }
  }

  return null;
}

Future<String?> getCurrentCallKitCallID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(CallKitCalIDCacheKey);
}

CallKitParams? convertCallKitCallToParam(Map<dynamic, dynamic> targetCall) {
  final activeCallRawParam = <String, dynamic>{};
  targetCall.forEach((key, value) {
    if (value is Map) {
      final _value = <String, dynamic>{};
      value.forEach((key, value) {
        _value[key as String] = value;
      });
      activeCallRawParam[key as String] = _value;
    } else {
      activeCallRawParam[key as String] = value;
    }
  });

  //  sdk bug
  if (activeCallRawParam.containsKey('number') &&
      !activeCallRawParam.containsKey('handle')) {
    activeCallRawParam['handle'] = activeCallRawParam['number'];
  }

  return CallKitParams.fromJson(activeCallRawParam);
}

Future<void> clearAllCallKitCalls() async {
  ZegoLoggerService.logInfo(
    'clear all callKit calls',
    tag: 'call',
    subTag: 'background message',
  );

  return FlutterCallkitIncoming.endAllCalls();
}
