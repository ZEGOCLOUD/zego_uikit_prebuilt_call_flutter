// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/handler.dart';

String? iOSIncomingPushUUID;

/// @nodoc
///
/// [iOS] VoIP event callback
void onIncomingPushReceived(Map<dynamic, dynamic> extras, String uuid) async {
  ///   extras:{
  ///     aps: {
  ///        alert: {title: user_870125, body: im message}
  ///     },
  ///     payload: {
  ///        "operation_type":"text_msg",
  ///        "id":"116802",
  ///        "sender":{
  ///            "id":"870125","name":"user_870125"
  ///        },
  ///        "type":1
  ///     },
  ///     zego: {version: 1, zpns_request_id: 4855622119122677075}
  ///     },
  ///     uuid:Instance of 'UUIDImpl'
  /// }
  ZegoLoggerService.logInfo(
    'on message received: '
    'extras:$extras, uuid:$uuid',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  final isZegoMessage = extras.keys.contains('zego');
  if (!isZegoMessage) {
    ZegoLoggerService.logInfo(
      'is not zego protocol, drop it',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    return;
  }

  iOSIncomingPushUUID = uuid;

  final handler = ZegoCallIOSBackgroundMessageHandler();
  await handler.handleMessage(
    messageExtras: Map<String, Object?>.from(extras),
  );
}
