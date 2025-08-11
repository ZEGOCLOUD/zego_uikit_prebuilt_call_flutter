// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/handler.call.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/ios/handler.im.dart';

class ZegoCallIOSBackgroundMessageHandler {
  final imHandler = ZegoCallIOSIMBackgroundMessageHandler();
  final callHandler = ZegoCallIOSCallBackgroundMessageHandler();

  Future<void> handleMessage({
    required Map<String, Object?> messageExtras,
  }) async {
    final message = ZegoCallIOSBackgroundMessageHandlerMessage(
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
        ZegoLoggerService.logInfo(
          'is im type',
          tag: 'call-invitation',
          subTag: 'ios background handler',
        );

        imHandler.handle(message);
        return;
      }

      ZegoLoggerService.logInfo(
        'is call type',
        tag: 'call-invitation',
        subTag: 'ios background handler',
      );

      /// operation type is empty, is send/cancel request
      callHandler.handle(message);
    });
  }
}
