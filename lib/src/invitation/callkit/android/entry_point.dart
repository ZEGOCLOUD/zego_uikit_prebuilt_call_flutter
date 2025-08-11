// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/handler.dart';

StreamSubscription<CallEvent?>? flutterCallkitIncomingStreamSubscription;

/// @nodoc
///
/// [Android] Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(
  ZegoSignalingPluginMessage message,
) async {
  /// ==========web===========
  /// title:Call invitation,
  /// content:,
  /// extras:{
  ///   zego: {
  ///     "call_id":"172604065779740667",
  ///     "version":1,
  ///     "zpns_request_id":"2819825754101714171"
  ///   },
  ///   body: Please join your call with our care personnel,
  ///   title: Call invitation,
  ///   payload: {
  ///     "call_id":"call_248232fd96ba4f8e9d938cc2b9e7cdb7_1726040657797",
  ///     "invitees":[
  ///       {"user_id":"3ae894260de84e389900e42b3bd987ab","user_name":"April Ninth"}
  ///     ],
  ///     "inviter":{"id":"248232fd96ba4f8e9d938cc2b9e7cdb7","name":"William Alias"},
  ///     "type":1,
  ///     "custom_data":"",
  ///     "inviter_name":"William Alias",
  ///     "data":"{
  ///       "call_id":"call_248232fd96ba4f8e9d938cc2b9e7cdb7_1726040657797",
  ///       "invitees":[
  ///         {"user_id":"3ae894260de84e389900e42b3bd987ab","user_name":"April Ninth"}
  ///       ],
  ///       "inviter":{"id":"248232fd96ba4f8e9d938cc2b9e7cdb7","name":"William Alias"},
  ///       "type":1,
  ///       "custom_data":""
  ///     }"
  ///   },
  ///   call_id: 172604065779740667
  /// }
  ///
  /// ==========flutter===========
  ///
  /// ----- cancel
  /// title:,
  /// content:,
  /// extras:
  /// {
  ///   "body": ”“,
  ///   "title": ”“,
  ///   "payload": {
  ///     "call_id": "call_073493_1693908313900",
  ///     "operation_type": "cancel_invitation"
  ///   },
  ///   "call_id": 4172113646365410763
  /// }
  ///
  /// ----- normal
  /// title:user_542,
  /// content:,
  /// extras:{
  ///   zego: {
  ///     "call_id":"14292543900357708322",
  ///     "version":1,
  ///     "zpns_request_id":"702041001865190434"
  ///   },
  ///   body: Incoming video call...,
  ///   title: user_542,
  ///   payload: {
  ///     "inviter_id":"542",
  ///     "inviter_name":"user_542",
  ///     "type":1,
  ///     "data":"{
  ///       "call_id":"call_542_1726039827282",
  ///       "inviter_name":"user_542",
  ///       "invitees":[
  ///         {"user_id":"946042","user_name":"user_946042"}
  ///       ],
  ///       "timeout":60,
  ///       "custom_data":"",
  ///       "v":"f1.0"
  ///     }"
  ///   },
  ///   call_id: 14292543900357708322
  /// },
  ///
  /// ----- advance
  /// title:user_542,
  /// content:,
  /// extras:{
  ///   zego: {
  ///     "call_id":"1204724609078844523",
  ///     "version":1,
  ///     "zpns_request_id":"6983256569312803082"
  ///   },
  ///   body: Incoming video call...,
  ///   title: user_542,
  ///   payload: {
  ///     "inviter":{"id":"542","name":"user_542"},
  ///     "invitees":[
  ///       "946042"
  ///     ],
  ///     "type":1,
  ///     "custom_data":"{
  ///       "call_id":"call_542_1726040168792",
  ///       "inviter_name":"user_542",
  ///       "invitees":[
  ///         {"user_id":"946042","user_name":"user_946042"}
  ///       ],
  ///       "timeout":60,
  ///       "custom_data":"",
  ///       "v":"f1.0"
  ///     }
  ///   },
  ///   call_id: 1204724609078844523
  /// }
  ///
  ///
  debugPrint('onBackgroundMessageReceived wait init log...');

  await ZegoUIKit().initLog();

  debugPrint('onBackgroundMessageReceived init log done...');

  ZegoLoggerService.logInfo(
    'on message received: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}, ',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  final isZegoMessage = message.extras.keys.contains('zego');
  if (!isZegoMessage) {
    ZegoLoggerService.logInfo(
      'is not zego protocol, drop it',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    return;
  }

  final handler = ZegoCallAndroidBackgroundMessageHandler();

  if (handler.trySendMessageIfAppRunning(
    title: message.title,
    extras: message.extras,
  )) {
    ZegoLoggerService.logInfo(
      'message send to running app, handler done',
      tag: 'call-invitation',
      subTag: 'offline',
    );

    return;
  }

  handler.observerIsolate();
  handler.listenIsolate();
  await handler.handleMessage(
    messageTitle: message.title,
    messageExtras: message.extras,
    messageFromIsolate: false,
  );
}
