// Package imports:
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';

/// @nodoc
const String CallKitCalIDCacheKey = 'callkit_call_id';
const String CallKitParamsCacheKey = 'callkit_params';

/// @nodoc
///
/// Generate parameters required for third-party CallKit package.
///
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
Future<CallKitParams> _makeCallKitParam({
  required ZegoUIKitUser? caller,
  required ZegoCallType callType,
  required InvitationInternalData invitationInternalData,
  String? title,
  String? body,
  String? ringtonePath,
  String? iOSIconName,
}) async {
  final prefs = await SharedPreferences.getInstance();

  var _ringtonePath = ringtonePath ?? '';
  if (_ringtonePath.isEmpty) {
    _ringtonePath =
        prefs.getString(CallKitInnerVariable.ringtonePath.cacheKey) ??
            CallKitInnerVariable.ringtonePath.defaultValue;
  }

  var _title = title ?? '';
  if (_title.isEmpty) {
    _title = caller?.name ?? '';
  }

  var _body = body ?? '';
  if (_body.isEmpty) {
    _body = (prefs.getBool(CallKitInnerVariable.callIDVisibility.cacheKey) ??
            CallKitInnerVariable.callIDVisibility.defaultValue)
        ? invitationInternalData.callID
        : '';
  }

  return CallKitParams(
    id: const Uuid().v4(),
    nameCaller: _title,
    appName: prefs.getString(CallKitInnerVariable.textAppName.cacheKey) ??
        CallKitInnerVariable.textAppName.defaultValue,
    // avatar: 'https://i.pravatar.cc/100',
    handle: _body,
    //  callkit type: 0 - Audio Call, 1 - Video Call
    type: callType.index,
    duration: invitationInternalData.timeout * 1000,
    textAccept: prefs.getString(CallKitInnerVariable.textAccept.cacheKey) ??
        CallKitInnerVariable.textAccept.defaultValue,
    textDecline: prefs.getString(CallKitInnerVariable.textDecline.cacheKey) ??
        CallKitInnerVariable.textDecline.defaultValue,
    extra: <String, dynamic>{},
    headers: <String, dynamic>{},
    missedCallNotification: NotificationParams(
      showNotification: false,
      isShowCallback: true,
      subtitle: prefs.getString(CallKitInnerVariable.textMissedCall.cacheKey) ??
          CallKitInnerVariable.textMissedCall.defaultValue,
      callbackText:
          prefs.getString(CallKitInnerVariable.textCallback.cacheKey) ??
              CallKitInnerVariable.textCallback.defaultValue,
    ),
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: _ringtonePath,
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
      iconName: iOSIconName,
      handleType: '',
      supportsVideo: ZegoCallType.videoCall == callType,
      ringtonePath: _ringtonePath,
      maximumCallGroups: 1,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: false,
      supportsGrouping: false,
      supportsUngrouping: false,
    ),
  );
}

/// @nodoc
///
/// Display the call interface of a third-party CallKit.
/// - caller
/// - callType
/// - invitationInternalData
/// - ringtonePath
Future<void> showCallkitIncoming({
  required ZegoUIKitUser? caller,
  required ZegoCallType callType,
  required InvitationInternalData invitationInternalData,
  String? ringtonePath,
  String? title,
  String? body,
  String? iOSIconName,
}) async {
  final callKitParam = await _makeCallKitParam(
    caller: caller,
    callType: callType,
    invitationInternalData: invitationInternalData,
    ringtonePath: ringtonePath,
    title: title,
    body: body,
    iOSIconName: iOSIconName,
  );

  ZegoLoggerService.logInfo(
    'show callkit incoming, inviter name:${caller?.name}, call type:$callType, '
    'data:${invitationInternalData.toJson()}, '
    'callKitParam:${callKitParam.toJson()}',
    tag: 'call',
    subTag: 'callkit',
  );

  return FlutterCallkitIncoming.showCallkitIncoming(callKitParam);
}

/// @nodoc
///
/// Retrieve the cached ID of the current call, which is stored in the handler received from ZPNS.
Future<String?> getCurrentCallKitCallID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(CallKitCalIDCacheKey);
}

/// cached ID of the current cal
Future<void> setCurrentCallKitCallID(String callID) async {
  ZegoLoggerService.logInfo(
    'set current callkit id:$callID',
    tag: 'call',
    subTag: 'callkit',
  );

  final prefs = await SharedPreferences.getInstance();
  prefs.setString(CallKitCalIDCacheKey, callID);
}

/// cached ID of the current cal
Future<void> clearCurrentCallKitCallID() async {
  ZegoLoggerService.logInfo(
    'clear current callkit id',
    tag: 'call',
    subTag: 'callkit',
  );

  final prefs = await SharedPreferences.getInstance();
  prefs.remove(CallKitCalIDCacheKey);
}

/// @nodoc
///
/// Clear the call cache of a third-party CallKit.
Future<void> clearAllCallKitCalls() async {
  ZegoLoggerService.logInfo(
    'clear all callKit calls',
    tag: 'call',
    subTag: 'callkit',
  );

  return FlutterCallkitIncoming.endAllCalls();
}

/// cached ID of the current params
Future<void> setCurrentCallKitParams(String params) async {
  ZegoLoggerService.logInfo(
    'set current callkit params:$params',
    tag: 'call',
    subTag: 'callkit',
  );

  final prefs = await SharedPreferences.getInstance();
  prefs.setString(CallKitParamsCacheKey, params);
}

Future<String?> getCurrentCallKitParams() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(CallKitParamsCacheKey);
}
