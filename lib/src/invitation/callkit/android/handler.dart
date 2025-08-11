// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/entry_point.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/handler.call.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/handler.im.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/isolate_name_server_guard.dart';

extension ReceivePortExtension on ReceivePort {
  String toStringX() {
    return 'hashcode:($hashCode), '
        'port(${sendPort.hashCode}), ';
  }
}

class ZegoCallAndroidBackgroundMessageHandler {
  ReceivePort? _listeningIsolatePort;

  final imHandler = ZegoCallAndroidIMBackgroundMessageHandler();
  final callHandler = ZegoCallAndroidCallBackgroundMessageHandler();

  bool trySendMessageIfAppRunning({
    required String title,
    required Map<String, Object?> extras,
  }) {
    final currentListeningIsolatePort =
        IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
    final isAppRunning = null != currentListeningIsolatePort;

    if (!isAppRunning) {
      return false;
    }

    // await ZegoCallPluginPlatform.instance.activeAppToForeground();

    /// after app being screen-locked for more than 10 minutes, the app was not
    /// killed(suspended) but the zpns login timed out, so that's why receive
    /// offline call when app was alive.
    ///
    /// At this time, because the fcm push will make the Dart open another isolate (thread) to process,
    /// it will cause the problem of double opening of the app.
    ///
    /// So, send this offline call to [ZegoUIKitPrebuiltCallInvitationService] to handle.
    ZegoLoggerService.logInfo(
      'has another isolate port:${currentListeningIsolatePort.hashCode}, '
      'app is running, '
      'send background message, '
      'title:$title, extras:$extras',
      tag: 'call-invitation',
      subTag: 'offline, isolate',
    );
    currentListeningIsolatePort.send(jsonEncode({
      'title': title,
      'extras': extras,
    }));

    return true;
  }

  void observerIsolate() {
    _listeningIsolatePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _listeningIsolatePort!.sendPort,
      backgroundMessageIsolatePortName,
    );

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(ZegoCallIsolateNameServerGuard(
      backgroundPort: _listeningIsolatePort!,
      portName: backgroundMessageIsolatePortName,
    ));

    ZegoLoggerService.logInfo(
      'registered, ',
      tag: 'call-invitation',
      subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
    );
  }

  void closeIsolate() {
    ZegoLoggerService.logInfo(
      'close',
      tag: 'call-invitation',
      subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
    );

    _listeningIsolatePort?.close();
    _listeningIsolatePort = null;

    IsolateNameServer.removePortNameMapping(
      backgroundMessageIsolatePortName,
    );
  }

  void listenIsolate() {
    if (null == _listeningIsolatePort) {
      ZegoLoggerService.logInfo(
        'listen failed, isolate is null',
        tag: 'call-invitation',
        subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
      );

      return;
    }

    _listeningIsolatePort?.listen(onIsolateMessageReceived);

    ZegoLoggerService.logInfo(
      'listening, ',
      tag: 'call-invitation',
      subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
    );
  }

  void onIsolateMessageReceived(dynamic message) async {
    ZegoLoggerService.logInfo(
      'receive message:$message',
      tag: 'call-invitation',
      subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
    );

    /// this will fix the issue that when offline call dialog popup, user click app icon to open app,
    if (message is String && message == backgroundMessageIsolateCloseCommand) {
      ZegoLoggerService.logInfo(
        'close port command received',
        tag: 'call-invitation',
        subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
      );

      ZegoLoggerService.logInfo(
        'cancel the flutterCallkitIncomingStreamSubscription(${flutterCallkitIncomingStreamSubscription?.hashCode})',
        tag: 'call-invitation',
        subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
      );
      flutterCallkitIncomingStreamSubscription?.cancel();
      flutterCallkitIncomingStreamSubscription = null;

      _listeningIsolatePort?.close();
      _listeningIsolatePort = null;

      ZegoLoggerService.logInfo(
        'closed.',
        tag: 'call-invitation',
        subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
      );

      return;
    }

    Map<String, dynamic> messageMap = {};
    try {
      messageMap = jsonDecode(message) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logInfo(
        'json parse exception:$e, message:$message',
        tag: 'call-invitation',
        subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
      );
    }
    final messageTitle = messageMap['title'] as String? ?? '';
    final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

    ZegoLoggerService.logInfo(
      'message received, '
      'title:$messageTitle, '
      'extras:$messageExtras, ',
      tag: 'call-invitation',
      subTag: 'offline, isolate(${_listeningIsolatePort?.toStringX()})',
    );
    await handleMessage(
      messageTitle: messageTitle,
      messageExtras: messageExtras,
      messageFromIsolate: true,
    );
  }

  Future<void> handleMessage({
    required String messageTitle,
    required Map<String, Object?> messageExtras,
    required bool messageFromIsolate,
  }) async {
    final message = ZegoCallAndroidCallBackgroundMessageHandlerMessage(
      title: messageTitle,
      extras: messageExtras,
    );

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventReceivedInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: message.invitationID,
        ZegoUIKitSignalingReporter.eventKeyInviter: message.inviter.id,
        ZegoUIKitReporter.eventKeyAppState:
            ZegoUIKitReporter.eventKeyAppStateBackground,
        ZegoCallReporter.eventKeyExtendedData: message.customData,
      },
    );

    await message.parse().then((_) {
      if (message.isIMType) {
        imHandler.handle(message);

        closeIsolate();

        return;
      }

      /// operation type is empty, is send/cancel request
      callHandler.init(
        port: _listeningIsolatePort!,
        messageFromIsolate: messageFromIsolate,
      );
      callHandler.handle(message);
    });
  }
}
