// Dart imports:
import 'dart:isolate';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class ZegoCallIsolateNameServerGuard extends WidgetsBindingObserver {
  ReceivePort backgroundPort;
  String portName;
  ZegoCallIsolateNameServerGuard({
    required this.backgroundPort,
    required this.portName,
  }) {
    ZegoLoggerService.logInfo(
      'add port:$backgroundPort, name:$portName',
      tag: 'call-invitation',
      subTag: 'isolate guard',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ZegoLoggerService.logInfo(
      'app life style:$state',
      tag: 'call-invitation',
      subTag: 'isolate guard',
    );

    if (state == AppLifecycleState.detached) {
      ZegoLoggerService.logInfo(
        'close',
        tag: 'call-invitation',
        subTag: 'isolate guard',
      );

      backgroundPort.close();
      IsolateNameServer.removePortNameMapping(portName);
    }
  }
}
