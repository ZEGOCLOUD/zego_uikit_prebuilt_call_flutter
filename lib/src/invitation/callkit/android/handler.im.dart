// Dart imports:
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';

import 'defines.dart';
import 'handler.call.dart';

class ZegoCallAndroidIMBackgroundMessageHandler {
  /// title:zimkit title, content:,
  /// extras:{zego: {"version":1,"zpns_request_id":"6858191685210283321"},
  /// body: zimkit content,
  /// title: zimkit title,
  /// payload: zimkit payload}
  Future<void> handle(
    ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
  ) async {
    final body = message.extras['body'] as String? ?? '';

    final conversationID = message.payloadMap['id'] as String? ?? '';
    final conversationTypeIndex = message.payloadMap['type'] as int? ?? -1;

    final senderInfo =
        message.payloadMap['sender'] as Map<String, dynamic>? ?? {};
    final senderID = senderInfo['id'] as String? ?? '';
    final senderName = senderInfo['name'] as String? ?? '';

    ZegoLoggerService.logInfo(
      'im message received, '
      'body:$body, conversationID:$conversationID, '
      'conversationTypeIndex:$conversationTypeIndex',
      tag: 'call-invitation',
      subTag: 'im handler',
    );

    var channelID =
        message.handlerInfo?.androidMessageChannelID ?? defaultMessageChannelID;
    if (channelID.isEmpty) {
      channelID = defaultMessageChannelID;
    }
    await ZegoCallPluginPlatform.instance.addLocalIMNotification(
      ZegoSignalingPluginLocalIMNotificationConfig(
        id: Random().nextInt(2147483647),
        channelID: channelID,
        title: senderName,
        content: body,
        vibrate: message.handlerInfo?.androidMessageVibrate ?? false,
        iconSource: ZegoCallInvitationNotificationManager.getIconSource(
          message.handlerInfo?.androidMessageIcon ?? '',
        ),
        soundSource: ZegoCallInvitationNotificationManager.getSoundSource(
          message.handlerInfo?.androidMessageSound ?? '',
        ),
        clickCallback: (int notificationID) async {
          await setOfflineIMKitMessageConversationInfo(
            conversationID: conversationID,
            conversationTypeIndex: conversationTypeIndex,
            senderID: senderID,
          );

          await ZegoUIKit().activeAppToForeground();
          await ZegoUIKit().requestDismissKeyguard();
        },
      ),
    );
  }
}
