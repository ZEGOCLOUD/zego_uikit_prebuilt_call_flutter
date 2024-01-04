// Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/protocols.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallKitBackgroundService {
  factory ZegoCallKitBackgroundService() => instance;

  ZegoCallKitBackgroundService._internal();

  static final ZegoCallKitBackgroundService instance =
      ZegoCallKitBackgroundService._internal();

  ZegoInvitationPageManager? _pageManager;

  bool _iOSCallKitDisplaying = false;

  void register({
    required ZegoInvitationPageManager pageManager,
  }) {
    ZegoLoggerService.logInfo(
      'register, pageManager:$pageManager',
      tag: 'call',
      subTag: 'callkit internal instance',
    );

    _pageManager = pageManager;
  }

  void acceptInvitationInBackground() {
    if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
      ZegoLoggerService.logInfo(
        'accept invitation, but has not callkit incoming cause by app in background',
        tag: 'call',
        subTag: 'call invitation service',
      );

      _pageManager?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
          true;

      return;
    }

    if (_pageManager?.invitationData.callID.isNotEmpty ?? false) {
      ZegoUIKit()
          .getSignalingPlugin()
          .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              data: '')
          .then((result) {
        _pageManager?.onLocalAcceptInvitation(
          result.error?.code ?? '',
          result.error?.message ?? '',
        );
      });
    }
  }

  Future<void> refuseInvitationInBackground({
    bool needClearCallKit = true,
  }) async {
    if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
      ZegoLoggerService.logInfo(
        'refuse invitation, but has not callkit incoming cause by app in background',
        tag: 'call',
        subTag: 'call invitation service',
      );

      _pageManager?.waitingCallInvitationReceivedAfterCallKitIncomingRejected =
          true;

      return;
    }

    _pageManager?.hasCallkitIncomingCauseAppInBackground = false;

    ZegoLoggerService.logInfo(
      'refuse invitation(${_pageManager?.invitationData}) by callkit',
      tag: 'call',
      subTag: 'call invitation service',
    );

    await ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: _pageManager?.invitationData.inviter?.id ?? '',
          data: const JsonEncoder().convert({
            CallInvitationProtocolKey.reason:
                CallInvitationProtocolKey.refuseByDecline,
          }),
        )
        .then((result) {
      _pageManager?.onLocalRefuseInvitation(
        result.error?.code ?? '',
        result.error?.message ?? '',
        needClearCallKit: needClearCallKit,
      );
    });
  }

  Future<void> acceptCallKitIncomingCauseInBackground(
    String? callKitCallID,
  ) async {
    if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
      ZegoLoggerService.logInfo(
        'accept invitation, but has not callkit incoming cause by app in background',
        tag: 'call',
        subTag: 'call invitation service',
      );

      _pageManager?.waitingCallInvitationReceivedAfterCallKitIncomingAccepted =
          true;

      return;
    }

    ZegoLoggerService.logInfo(
      'accept invitation, callkit call id: $callKitCallID',
      tag: 'call',
      subTag: 'call invitation service',
    );

    if (callKitCallID != null &&
        callKitCallID == _pageManager?.invitationData.callID) {
      ZegoLoggerService.logInfo(
        'accept invitation, auto agree, cause exist callkit params same as current call',
        tag: 'call',
        subTag: 'call invitation service',
      );

      await ZegoUIKit()
          .getSignalingPlugin()
          .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              data: '')
          .then((result) {
        _pageManager?.onLocalAcceptInvitation(
          result.error?.code ?? '',
          result.error?.message ?? '',
        );
      });
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

  Future<void> handUpCurrentCallByCallKit() async {
    ZegoLoggerService.logInfo(
      'hang up by call kit, iOSBackgroundLockCalling:${_pageManager?.inCallingByIOSBackgroundLock}',
      tag: 'call',
      subTag: 'call invitation service',
    );

    /// If the call is ended by the end button of iOS CallKit,
    /// the widget navigation of the CallPage will not be properly
    /// execute dispose function.
    ///
    /// As a result, during the next offline call,
    /// the dispose of the previous CallPage will cause confusion in the widget
    /// navigation.
    ///
    /// Here, it is marked as requiring waiting for the dispose of the previous call page.
    ZegoCallKitBackgroundService().setWaitCallPageDisposeFlag(true);

    await ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'call invitation service',
      );
    });

    if (Platform.isIOS &&
        ((_pageManager?.inCallingByIOSBackgroundLock ?? false) ||
            (_pageManager?.appInBackground ?? false))) {
      _pageManager?.restoreToIdle();
    } else {
      /// background callkit call, not need to navigate
      try {
        Navigator.of(_pageManager!.callInvitationData.contextQuery!.call())
            .pop();
      } catch (e) {
        ZegoLoggerService.logError(
          'Navigator pop exception:$e, '
          'contextQuery:${_pageManager?.callInvitationData.contextQuery}',
          tag: 'call',
          subTag: 'call invitation service',
        );
      }
    }

    _pageManager?.inCallingByIOSBackgroundLock = false;
  }

  bool get isIOSCallKitDisplaying => _iOSCallKitDisplaying;

  void setIOSCallKitCallingDisplayState(bool isCalling) {
    _iOSCallKitDisplaying = isCalling;

    ZegoLoggerService.logInfo(
      'setIOSCallKitCallingState:$isCalling',
      tag: 'call',
      subTag: 'call invitation service',
    );
  }
}
