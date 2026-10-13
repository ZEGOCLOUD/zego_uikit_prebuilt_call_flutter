// Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

void ensureCallKitRoomLeaveSucceeded(int errorCode, Object? extendedData) {
  if (errorCode != 0) {
    throw StateError(
      'CallKit leave room failed: errorCode:$errorCode, '
      'extendedData:$extendedData',
    );
  }
}

/// Runs one iOS CallKit hangup cleanup for overlapping end-action callbacks.
class IOSCallKitHangupOperation {
  Future<void>? _activeOperation;

  Future<void> run(Future<void> Function() cleanup) {
    final activeOperation = _activeOperation;
    if (activeOperation != null) {
      return activeOperation;
    }

    final operation = Future<void>.sync(cleanup);
    _activeOperation = operation;

    return operation.whenComplete(() {
      if (identical(_activeOperation, operation)) {
        _activeOperation = null;
      }
    });
  }
}

/// Holds new CallKit entries while the current room and call page are cleaned up.
///
/// If cleanup leaves no call page to dispose, the wait flag is cleared as soon
/// as cleanup completes. Otherwise, the page's dispose callback clears it.
Future<void> runIOSCallKitHangupWithPageDisposeWait({
  required Future<void> Function() cleanup,
  required bool Function() hasCallPageToDispose,
  required void Function(bool) setWaitFlag,
  required void Function() beginCleanup,
  required bool Function() endCleanup,
}) async {
  beginCleanup();
  var cleanupSucceeded = false;

  try {
    setWaitFlag(true);
    await cleanup();
    cleanupSucceeded = true;
  } finally {
    final isLastCleanup = endCleanup();
    if (cleanupSucceeded && isLastCleanup && !hasCallPageToDispose()) {
      setWaitFlag(false);
    }
  }
}

/// @nodoc
class ZegoCallKitBackgroundService {
  factory ZegoCallKitBackgroundService() => instance;

  ZegoCallKitBackgroundService._internal();

  static final ZegoCallKitBackgroundService instance =
      ZegoCallKitBackgroundService._internal();

  ZegoCallInvitationPageManager? _pageManager;

  bool _iOSCallKitDisplaying = false;
  final _iOSCallKitHangupOperation = IOSCallKitHangupOperation();

  void register({required ZegoCallInvitationPageManager pageManager}) {
    ZegoLoggerService.logInfo(
      'register, pageManager:$pageManager',
      tag: 'call-invitation',
      subTag: 'callkit internal instance',
    );

    _pageManager = pageManager;
  }

  void acceptInvitationInBackground() {
    _pageManager?.isIOSCallKitAnswering = true;
    ZegoLoggerService.logInfo(
      'mark accept source as CallKit action callback',
      tag: 'call-invitation',
      subTag: 'call invitation service, ios callkit audio sequencing',
    );

    if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
      ZegoLoggerService.logInfo(
        'accept invitation, but has not callkit incoming cause by app in background',
        tag: 'call-invitation',
        subTag: 'call invitation service',
      );

      _pageManager?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
          true;

      return;
    }

    if (_pageManager?.invitationData.callID.isNotEmpty ?? false) {
      if (_pageManager?.isAdvanceInvitationMode ?? true) {
        ZegoUIKit()
            .getSignalingPlugin()
            .acceptAdvanceInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              invitationID: _pageManager?.invitationData.invitationID ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
              _pageManager?.onLocalAcceptInvitation(
                result.invitationID,
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
            });
      } else {
        ZegoUIKit()
            .getSignalingPlugin()
            .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              targetInvitationID:
                  _pageManager?.invitationData.invitationID ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
              _pageManager?.onLocalAcceptInvitation(
                result.invitationID,
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
            });
      }
    }
  }

  Future<void> refuseInvitationInBackground({
    bool needClearCallKit = true,
    bool needCheckHasCallkitIncoming = true,
  }) async {
    ZegoLoggerService.logInfo(
      'refuse invitation by callkit, '
      'invitationData:${_pageManager?.invitationData}'
      'isAdvanceInvitationMode:${_pageManager?.isAdvanceInvitationMode}, '
      'needClearCallKit:$needClearCallKit, '
      'needCheckHasCallkitIncoming:$needCheckHasCallkitIncoming, ',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );

    if (needCheckHasCallkitIncoming) {
      if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
        /// 这里返回了
        ZegoLoggerService.logInfo(
          'refuse invitation, but has not callkit incoming cause by app in background',
          tag: 'call-invitation',
          subTag: 'call invitation service',
        );

        _pageManager
                ?.waitingCallInvitationReceivedAfterCallKitIncomingRejected =
            true;

        return;
      }
    }

    /// hasCallkitIncomingCauseAppInBackground is true
    _pageManager?.hasCallkitIncomingCauseAppInBackground = false;

    if (_pageManager?.isAdvanceInvitationMode ?? true) {
      await ZegoUIKit()
          .getSignalingPlugin()
          .refuseAdvanceInvitation(
            inviterID: _pageManager?.invitationData.inviter?.id ?? '',
            invitationID: _pageManager?.invitationData.invitationID ?? '',
            data: const JsonEncoder().convert({
              ZegoCallInvitationProtocolKey.reason:
                  ZegoCallInvitationProtocolKey.refuseByDecline,
            }),
          )
          .then((result) async {
            ZegoLoggerService.logInfo(
              'refuse advance done',
              tag: 'call-invitation',
              subTag: 'call invitation service',
            );

            await _pageManager?.onLocalRefuseInvitation(
              result.invitationID,
              result.error?.code ?? '',
              result.error?.message ?? '',
              needClearCallKit: needClearCallKit,
            );
          });
    } else {
      await ZegoUIKit()
          .getSignalingPlugin()
          .refuseInvitation(
            inviterID: _pageManager?.invitationData.inviter?.id ?? '',
            targetInvitationID: _pageManager?.invitationData.invitationID ?? '',
            data: const JsonEncoder().convert({
              ZegoCallInvitationProtocolKey.reason:
                  ZegoCallInvitationProtocolKey.refuseByDecline,
            }),
          )
          .then((result) async {
            ZegoLoggerService.logInfo(
              'refuse done',
              tag: 'call-invitation',
              subTag: 'call invitation service',
            );

            await _pageManager?.onLocalRefuseInvitation(
              result.invitationID,
              result.error?.code ?? '',
              result.error?.message ?? '',
              needClearCallKit: needClearCallKit,
            );
          });
    }
  }

  Future<void> acceptCallKitIncomingCauseInBackground(
    String? callKitCallID, {
    bool needCheckHasCallkitIncoming = true,
  }) async {
    // This method is called from CallKit's performAnswerCallAction. Keep the
    // source marker independent of lifecycle and incoming-push ordering.
    _pageManager?.isIOSCallKitAnswering = true;
    ZegoLoggerService.logInfo(
      'mark accept source as CallKit performAnswerCallAction, '
      'callKitCallID:$callKitCallID',
      tag: 'call-invitation',
      subTag: 'call invitation service, ios callkit audio sequencing',
    );

    ZegoLoggerService.logInfo(
      'accept invitation by callkit, '
      'callKitCallID:$callKitCallID, '
      'invitationData:${_pageManager?.invitationData}'
      'isAdvanceInvitationMode:${_pageManager?.isAdvanceInvitationMode}, '
      'needCheckHasCallkitIncoming:$needCheckHasCallkitIncoming, ',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );

    if (needCheckHasCallkitIncoming) {
      if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
        ZegoLoggerService.logInfo(
          'accept callkit invitation, but has not callkit incoming cause by app in background',
          tag: 'call-invitation',
          subTag: 'call invitation service',
        );

        _pageManager
                ?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
            true;

        return;
      }
    }

    if (callKitCallID != null &&
        callKitCallID == _pageManager?.invitationData.callID) {
      ZegoLoggerService.logInfo(
        'accept invitation, auto agree, cause exist callkit params same as current call',
        tag: 'call-invitation',
        subTag: 'call invitation service',
      );

      if (_pageManager?.isAdvanceInvitationMode ?? true) {
        await ZegoUIKit()
            .getSignalingPlugin()
            .acceptAdvanceInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              invitationID: _pageManager?.invitationData.invitationID ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
              _pageManager?.onLocalAcceptInvitation(
                result.invitationID,
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
            });
      } else {
        await ZegoUIKit()
            .getSignalingPlugin()
            .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              targetInvitationID:
                  _pageManager?.invitationData.invitationID ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
              _pageManager?.onLocalAcceptInvitation(
                result.invitationID,
                result.error?.code ?? '',
                result.error?.message ?? '',
              );
            });
      }
    }
  }

  /// If the call is ended by the end button of iOS CallKit,
  /// the widget navigation of the CallPage will not be properly
  /// execute dispose function.
  ///
  /// As a result, during the next offline call,
  /// the dispose of the previous CallPage will cause confusion in the widget
  /// navigation.
  void setWaitCallPageDisposeFlag(bool value) {
    _pageManager?.setWaitCallPageDisposeFlag(value);
  }

  Future<void> handUpCurrentCallByCallKit() {
    if (Platform.isIOS) {
      return _iOSCallKitHangupOperation.run(_handUpCurrentCallByCallKit);
    }

    return _handUpCurrentCallByCallKit();
  }

  Future<void> _handUpCurrentCallByCallKit() async {
    final pageManager = _pageManager;

    ZegoLoggerService.logInfo(
      'hang up by call kit, iOSBackgroundLockCalling:${pageManager?.inCallingByIOSBackgroundLock}',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );

    Future<void> cleanupCurrentCall() async {
      final leaveResult = await ZegoUIKit().leaveRoom();
      ZegoLoggerService.logInfo(
        'leave room result, ${leaveResult.errorCode} ${leaveResult.extendedData}',
        tag: 'call-invitation',
        subTag: 'call invitation service',
      );
      if (Platform.isIOS) {
        ensureCallKitRoomLeaveSucceeded(
          leaveResult.errorCode,
          leaveResult.extendedData,
        );
      }

      if (Platform.isIOS &&
          ((pageManager?.inCallingByIOSBackgroundLock ?? false) ||
              (pageManager?.appInBackground ?? false))) {
        await pageManager?.restoreToIdle();
      } else {
        ZegoLoggerService.logInfo(
          'pop from hangup, ',
          tag: 'call',
          subTag: 'call invitation service, Navigator',
        );

        /// background callkit call, not need to navigate
        try {
          Navigator.of(
            pageManager!.callInvitationData.contextQuery!.call(),
          ).pop();
        } catch (e) {
          ZegoLoggerService.logError(
            'Navigator pop exception:$e, '
            'contextQuery:${pageManager?.callInvitationData.contextQuery}',
            tag: 'call-invitation',
            subTag: 'call invitation service',
          );
        }
      }
    }

    if (Platform.isIOS) {
      try {
        await runIOSCallKitHangupWithPageDisposeWait(
          cleanup: cleanupCurrentCall,
          hasCallPageToDispose: () =>
              pageManager?.callingMachine?.isPagePushed ?? false,
          setWaitFlag: (value) =>
              pageManager?.setWaitCallPageDisposeFlag(value),
          beginCleanup: () => pageManager?.beginIOSCallKitHangupCleanup(),
          endCleanup: () => pageManager?.endIOSCallKitHangupCleanup() ?? true,
        );
      } catch (e) {
        ZegoLoggerService.logError(
          'CallKit hangup cleanup failed; keep the page-dispose wait flag set '
          'until a later cleanup succeeds: $e',
          tag: 'call-invitation',
          subTag: 'call invitation service',
        );
        rethrow;
      }
    } else {
      await cleanupCurrentCall();
    }

    // Keep this state true when cleanup throws so a later CallKit event can retry.
    pageManager?.inCallingByIOSBackgroundLock = false;
  }

  bool get isIOSCallKitDisplaying => _iOSCallKitDisplaying;

  void setIOSCallKitCallingDisplayState(bool isCalling) {
    _iOSCallKitDisplaying = isCalling;

    ZegoLoggerService.logInfo(
      'setIOSCallKitCallingState:$isCalling',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );
  }
}
