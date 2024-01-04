// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/mini_overlay_internal_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/data.dart';

import 'call_invitation/callkit/background_service.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/invitation.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/invitation.private.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/screen_sharing.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/minimize.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/minimize.private.dart';

part 'package:zego_uikit_prebuilt_call/src/controller/private.dart';

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
        ZegoCallControllerPrivate {
  factory ZegoUIKitPrebuiltCallController() => instance;

  /// This function is used to end the current call.
  /// You can pass the context [context] for any necessary pop-ups or page transitions.
  /// By using the [showConfirmation] parameter, you can control whether to display a confirmation dialog to confirm ending the call.
  /// This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the [onHangUpConfirmation] and [onHangUp] settings in the config.
  ///
  /// if you want hangUp in minimize state, please call [minimize.hangUp]
  Future<bool> hangUp(
    BuildContext context, {
    bool showConfirmation = false,
  }) async {
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
      final canHangUp =
          await private.events?.onHangUpConfirmation?.call(context) ?? true;
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

    final result = await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'hang up, leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'controller',
      );
      return 0 == result.errorCode;
    });

    final callEndEvent = ZegoUIKitCallEndEvent(
      reason: ZegoUIKitCallEndReason.localHangUp,
    );
    defaultAction() {
      private.defaultCallEndEvent(callEndEvent, context, true);
    }

    if (private.events?.onCallEnd != null) {
      private.events?.onCallEnd?.call(callEndEvent, defaultAction);
    } else {
      defaultAction.call();
    }

    ZegoLoggerService.logInfo(
      'hang up, restore mini state by hang up',
      tag: 'call',
      subTag: 'controller',
    );
    ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().changeState(
      PrebuiltCallMiniOverlayPageState.idle,
    );

    private.uninitByPrebuilt();
    invitation.private.uninitByPrebuilt();
    minimize.private.uninitByPrebuilt();

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.beauty) != null) {
      ZegoUIKit().getBeautyPlugin().uninit();
    }

    ZegoCallKitBackgroundService().setWaitCallPageDisposeFlag(false);

    ZegoLoggerService.logInfo(
      'hang up, finished',
      tag: 'call',
      subTag: 'controller',
    );

    return result;
  }

  ZegoUIKitPrebuiltCallController._internal() {
    ZegoLoggerService.logInfo(
      'ZegoUIKitPrebuiltCallController create',
      tag: 'call',
      subTag: 'call controller(${identityHashCode(this)})',
    );
  }

  static final ZegoUIKitPrebuiltCallController instance =
      ZegoUIKitPrebuiltCallController._internal();
}
