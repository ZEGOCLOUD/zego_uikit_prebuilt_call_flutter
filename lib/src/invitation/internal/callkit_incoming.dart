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
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

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
  required ZegoCallInvitationType callType,
  required String callID,
  required int timeoutSeconds,
  required String callChannelName,
  required String missedCallChannelName,
  String? title,
  String? body,
  String? ringtonePath,
  String? iOSIconName,
}) async {
  final prefs = await SharedPreferences.getInstance();

  var tempRingtonePath = ringtonePath ?? '';
  if (tempRingtonePath.isEmpty) {
    tempRingtonePath =
        prefs.getString(CallKitInnerVariable.ringtonePath.cacheKey) ??
            CallKitInnerVariable.ringtonePath.defaultValue;
  }

  var tempTitle = title ?? '';
  if (tempTitle.isEmpty) {
    tempTitle = caller?.name ?? '';
  }

  var tempBody = body ?? '';
  if (tempBody.isEmpty) {
    tempBody = (prefs.getBool(CallKitInnerVariable.callIDVisibility.cacheKey) ??
            CallKitInnerVariable.callIDVisibility.defaultValue)
        ? callID
        : '';
  }

  final isShowFullScreen =
      (prefs.getBool(CallKitInnerVariable.showFullScreen.cacheKey) ??
          CallKitInnerVariable.showFullScreen.defaultValue);

  return CallKitParams(
    id: const Uuid().v4(),
    nameCaller: tempTitle,
    appName: prefs.getString(CallKitInnerVariable.textAppName.cacheKey) ??
        CallKitInnerVariable.textAppName.defaultValue,
    // avatar: 'https://i.pravatar.cc/100',
    handle: tempBody,
    //  callkit type: 0 - Audio Call, 1 - Video Call
    type: callType.index,
    duration: timeoutSeconds * 1000,
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
      isShowFullLockedScreen: isShowFullScreen,
      isShowLogo: false,
      ringtonePath: tempRingtonePath,
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
      supportsVideo: ZegoCallInvitationType.videoCall == callType,
      ringtonePath: tempRingtonePath,
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
  required ZegoCallInvitationType callType,
  required String callID,
  required int timeoutSeconds,
  required String callChannelName,
  required String missedCallChannelName,
  String? ringtonePath,
  String? title,
  String? body,
  String? iOSIconName,
}) async {
  final callKitParam = await _makeCallKitParam(
    caller: caller,
    callType: callType,
    callID: callID,
    timeoutSeconds: timeoutSeconds,
    callChannelName: callChannelName,
    missedCallChannelName: missedCallChannelName,
    ringtonePath: ringtonePath,
    title: title,
    body: body,
    iOSIconName: iOSIconName,
  );

  ZegoLoggerService.logInfo(
    'show callkit incoming, '
    'inviter name:${caller?.name}, '
    'call type:$callType, '
    'callID:$callID, '
    'timeoutSeconds:$timeoutSeconds, '
    'callKitParam:${callKitParam.toJson()}',
    tag: 'call-invitation',
    subTag: 'callkit',
  );

  return FlutterCallkitIncoming.showCallkitIncoming(callKitParam);
}

/// @nodoc
///
/// Clear the call cache of a third-party CallKit.
Future<void> clearAllCallKitCalls() async {
  ZegoLoggerService.logInfo(
    'clear all callKit calls',
    tag: 'call-invitation',
    subTag: 'callkit',
  );

  return FlutterCallkitIncoming.endAllCalls();
}
