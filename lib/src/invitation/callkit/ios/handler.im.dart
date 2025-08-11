// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/cache/cache.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/defines.dart';

class ZegoCallIOSIMBackgroundMessageHandler {
  /// title:zimkit title, content:,
  /// extras:{zego: {"version":1,"zpns_request_id":"6858191685210283321"},
  /// body: zimkit content,
  /// title: zimkit title,
  /// payload: zimkit payload}
  Future<void> handle(
    ZegoCallIOSBackgroundMessageHandlerMessage message,
  ) async {
    // iOS的extras结构：
    // extras:{
    //   aps: {
    //     alert: {title: user_870125, body: 喝酒据斤斤计较}
    //   },
    //   payload: {
    //     "operation_type":"text_msg",
    //     "id":"116802",
    //     "sender":{
    //         "id":"870125","name":"user_870125"
    //     },
    //     "type":1
    //   },
    //   zego: {version: 1, zpns_request_id: 4855622119122677075}
    // }

    final aps = message.extras['aps'] as Map<Object?, Object?>? ?? {};
    final alert = aps['alert'] as Map<Object?, Object?>? ?? {};
    final body = alert['body']?.toString() ?? '';
    final title = alert['title']?.toString() ?? '';

    // 需要先解析payloadMap
    await message.parse();

    final conversationID = message.payloadMap['id'] as String? ?? '';
    final conversationTypeIndex = message.payloadMap['type'] as int? ?? -1;

    final senderInfo =
        message.payloadMap['sender'] as Map<String, dynamic>? ?? {};
    final senderID = senderInfo['id'] as String? ?? '';
    final senderName = senderInfo['name'] as String? ?? '';

    ZegoLoggerService.logInfo(
      'iOS im message received, '
      'body:$body, conversationID:$conversationID, '
      'conversationTypeIndex:$conversationTypeIndex',
      tag: 'call-invitation',
      subTag: 'offline, ios im handler',
    );

    await ZegoCallPluginPlatform.instance.showNormalNotification(
      ZegoCallNormalNotificationConfig(
        id: Random().nextInt(2147483647),
        title: title.isNotEmpty ? title : senderName,
        content: body,
        clickCallback: (int notificationID) async {
          await ZegoUIKitCallCache().setOfflineIMKitMessageConversationInfo(
            conversationID: conversationID,
            conversationTypeIndex: conversationTypeIndex,
            senderID: senderID,
          );
          ZegoLoggerService.logInfo(
            'click offline message on iOS',
            tag: 'call-invitation',
            subTag: 'offline, ios im handler',
          );

          await ZegoUIKit().activeAppToForeground();
        },
      ),
    );
  }
}
