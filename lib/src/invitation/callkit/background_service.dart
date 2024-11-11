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

/// @nodoc
class ZegoCallKitBackgroundService {
  factory ZegoCallKitBackgroundService() => instance;

  ZegoCallKitBackgroundService._internal();

  static final ZegoCallKitBackgroundService instance =
      ZegoCallKitBackgroundService._internal();

  ZegoCallInvitationPageManager? _pageManager;

  bool _iOSCallKitDisplaying = false;

  void register({
    required ZegoCallInvitationPageManager pageManager,
  }) {
    ZegoLoggerService.logInfo(
      'register, pageManager:$pageManager',
      tag: 'call-invitation',
      subTag: 'callkit internal instance',
    );

    _pageManager = pageManager;
  }

  void acceptInvitationInBackground() {
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
            result.error?.code ?? '',
            result.error?.message ?? '',
          );
        });
      } else {
        ZegoUIKit()
            .getSignalingPlugin()
            .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
          _pageManager?.onLocalAcceptInvitation(
            result.error?.code ?? '',
            result.error?.message ?? '',
          );
        });
      }
    }
  }

  Future<void> refuseInvitationInBackground({
    bool needClearCallKit = true,
  }) async {
    if (!(_pageManager?.hasCallkitIncomingCauseAppInBackground ?? false)) {
      ZegoLoggerService.logInfo(
        'refuse invitation, but has not callkit incoming cause by app in background',
        tag: 'call-invitation',
        subTag: 'call invitation service',
      );

      _pageManager?.waitingCallInvitationReceivedAfterCallKitIncomingRejected =
          true;

      return;
    }

    _pageManager?.hasCallkitIncomingCauseAppInBackground = false;

    ZegoLoggerService.logInfo(
      'refuse invitation(${_pageManager?.invitationData}) by callkit',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );

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
          .then((result) {
        _pageManager?.onLocalRefuseInvitation(
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
            data: const JsonEncoder().convert({
              ZegoCallInvitationProtocolKey.reason:
                  ZegoCallInvitationProtocolKey.refuseByDecline,
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
  }

  Future<void> acceptCallKitIncomingCauseInBackground(
    String? callKitCallID,
  ) async {
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

    ZegoLoggerService.logInfo(
      'accept invitation, callkit call id: $callKitCallID',
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );

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
            result.error?.code ?? '',
            result.error?.message ?? '',
          );
        });
      } else {
        await ZegoUIKit()
            .getSignalingPlugin()
            .acceptInvitation(
              inviterID: _pageManager?.invitationData.inviter?.id ?? '',
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
            )
            .then((result) {
          _pageManager?.onLocalAcceptInvitation(
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

  Future<void> handUpCurrentCallByCallKit() async {
    ZegoLoggerService.logInfo(
      'hang up by call kit, iOSBackgroundLockCalling:${_pageManager?.inCallingByIOSBackgroundLock}',
      tag: 'call-invitation',
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
        tag: 'call-invitation',
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
          tag: 'call-invitation',
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
      tag: 'call-invitation',
      subTag: 'call invitation service',
    );
  }
}
