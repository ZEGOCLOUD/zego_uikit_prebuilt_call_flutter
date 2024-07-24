// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_machine.dart';

part 'controller/audio_video.dart';

part 'controller/invitation.dart';

part 'controller/screen_sharing.dart';

part 'controller/minimize.dart';

part 'controller/permission.dart';

part 'controller/user.dart';

part 'controller/room.dart';

part 'controller/private/audio_video.dart';

part 'controller/private/minimize.dart';

part 'controller/private/user.dart';

part 'controller/private/permission.dart';

part 'controller/private/private.dart';

/// Used to control the call functionality.
///
/// [ZegoUIKitPrebuiltCallController] is a **singleton instance** class,
/// you can directly invoke it by ZegoUIKitPrebuiltCallController().
///
/// If the default call UI and interactions do not meet your requirements,
/// you can use this [ZegoUIKitPrebuiltCallController] to actively control the business logic.
///
/// If you use `invitation` series API about, you must [init] by
/// [ZegoUIKitPrebuiltCallInvitationService] firstly.
class ZegoUIKitPrebuiltCallController
    with
        ZegoCallControllerScreenSharing,
        ZegoCallControllerInvitation,
        ZegoCallControllerMinimizing,
        ZegoCallControllerAudioVideo,
        ZegoCallControllerUser,
        ZegoCallControllerPermission,
        ZegoCallControllerRoom,
        ZegoCallControllerPrivate {
  factory ZegoUIKitPrebuiltCallController() => instance;

  /// This function is used to end the current call.
  ///
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the call.
  ///
  /// if you want hangUp in minimize state, please call [minimize.hangUp]
  ///
  /// Related APIs:
  /// [ZegoUIKitPrebuiltCallEvents.onHangUpConfirmation]
  /// [ZegoUIKitPrebuiltCallEvents.onCallEnd]
  Future<bool> hangUp(
    BuildContext context, {
    bool showConfirmation = false,
    ZegoCallEndReason reason = ZegoCallEndReason.localHangUp,
  }) async {
    if (ZegoUIKit().getRoom().id.isEmpty) {
      ZegoLoggerService.logInfo(
        'hang up, not in call',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    if (null == private.prebuiltConfig) {
      ZegoLoggerService.logInfo(
        'hang up, config is null',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    if (private.isHangUpRequestingNotifier.value) {
      ZegoLoggerService.logInfo(
        'hang up, is hang up requesting...',
        tag: 'call',
        subTag: 'controller',
      );

      return false;
    }

    ZegoLoggerService.logInfo(
      'hang up, show confirmation:$showConfirmation',
      tag: 'call',
      subTag: 'controller',
    );

    if (showConfirmation) {
      private.isHangUpRequestingNotifier.value = true;

      ///  if there is a user-defined event before the click,
      ///  wait the synchronize execution result
      final hangUpConfirmationEvent = ZegoCallHangUpConfirmationEvent(
        context: context,
      );
      defaultAction() async {
        return private.defaultHangUpConfirmationAction(
          hangUpConfirmationEvent,
          context,
        );
      }

      var canHangUp = true;
      if (private.events?.onHangUpConfirmation != null) {
        canHangUp = await private.events?.onHangUpConfirmation?.call(
              hangUpConfirmationEvent,
              defaultAction,
            ) ??
            true;
      } else {
        canHangUp = await defaultAction.call();
      }
      if (!canHangUp) {
        ZegoLoggerService.logInfo(
          'hang up, reject',
          tag: 'call',
          subTag: 'controller',
        );

        private.isHangUpRequestingNotifier.value = false;

        return false;
      }
    }

    ZegoLoggerService.logInfo(
      'hang up, restore mini state by hang up',
      tag: 'call',
      subTag: 'controller',
    );
    minimize.hide();

    private.uninitByPrebuilt();
    user.private.uninitByPrebuilt();
    audioVideo.private.uninitByPrebuilt();
    minimize.private.uninitByPrebuilt();

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'hang up, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'controller',
      );
      return 0 == result.errorCode;
    });

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().getBeautyPlugin().uninit();
    }

    ZegoCallKitBackgroundService().setWaitCallPageDisposeFlag(false);

    await ZegoUIKitPrebuiltCallInvitationService().private.clearInvitation();

    final endEvent = ZegoCallEndEvent(
      callID: ZegoUIKit().getRoom().id,
      reason: reason,
      isFromMinimizing:
          ZegoCallMiniOverlayPageState.minimizing == minimize.state,
    );
    defaultAction() {
      private.defaultEndEvent(endEvent, context);
    }

    if (private.events?.onCallEnd != null) {
      private.events?.onCallEnd?.call(endEvent, defaultAction);
    } else {
      defaultAction.call();
    }

    ZegoLoggerService.logInfo(
      'hang up, finished',
      tag: 'call',
      subTag: 'controller',
    );

    return result;
  }

  ZegoUIKitPrebuiltCallController._internal() {
    ZegoLoggerService.logInfo(
      'create',
      tag: 'call',
      subTag: 'controller(${identityHashCode(this)})',
    );
  }

  static final ZegoUIKitPrebuiltCallController instance =
      ZegoUIKitPrebuiltCallController._internal();
}
