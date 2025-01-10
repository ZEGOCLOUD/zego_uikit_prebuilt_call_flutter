// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_callkit_incoming_yoer/entities/call_event.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_zpns/zego_zpns.dart';

import 'handler.dart';

StreamSubscription<CallEvent?>? flutterCallkitIncomingStreamSubscription;

/// @nodoc
///
/// [Android] Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(ZPNsMessage message) async {
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
