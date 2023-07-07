// Package imports:
import 'package:zego_uikit/zego_uikit.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallKitBackgroundService {
  factory ZegoCallKitBackgroundService() => instance;

  ZegoCallKitBackgroundService._internal();

  static final ZegoCallKitBackgroundService instance =
      ZegoCallKitBackgroundService._internal();

  ZegoInvitationPageManager? _pageManager;

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

  void refuseInvitationInBackground() {
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

    ZegoUIKit()
        .getSignalingPlugin()
        .refuseInvitation(
          inviterID: _pageManager?.invitationData.inviter?.id ?? '',
          data: '{"reason":"decline"}',
        )
        .then((result) {
      _pageManager?.onLocalRefuseInvitation(
          result.error?.code ?? '', result.error?.message ?? '');
    });
  }

  void acceptCallKitIncomingCauseInBackground(
    String? callKitCallID,
  ) {
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
      'callkit call id: $callKitCallID',
      tag: 'call',
      subTag: 'call invitation service',
    );

    if (callKitCallID != null &&
        callKitCallID == _pageManager?.invitationData.callID) {
      ZegoLoggerService.logInfo(
        'auto agree, cause exist callkit params same as current call',
        tag: 'call',
        subTag: 'call invitation service',
      );

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

  void handUpCurrentCallByCallKit() {
    ZegoLoggerService.logInfo(
      'hang up by call kit',
      tag: 'call',
      subTag: 'call invitation service',
    );

    ZegoUIKit().leaveRoom().then((result) {
      ZegoLoggerService.logInfo(
        'leave room result, ${result.errorCode} ${result.extendedData}',
        tag: 'call',
        subTag: 'call invitation service',
      );
    });

    Navigator.of(_pageManager!.callInvitationConfig.contextQuery!.call()).pop();
  }
}
