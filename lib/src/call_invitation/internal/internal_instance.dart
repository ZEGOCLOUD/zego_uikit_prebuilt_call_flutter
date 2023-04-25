// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/call_invitation_config.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoCallInvitationInternalInstance {
  factory ZegoCallInvitationInternalInstance() => instance;

  ZegoCallInvitationInternalInstance._internal();

  static final ZegoCallInvitationInternalInstance instance =
      ZegoCallInvitationInternalInstance._internal();

  ZegoInvitationPageManager? _pageManager;
  ZegoCallInvitationConfig? _callInvitationConfig;

  ZegoInvitationPageManager? get pageManager => _pageManager;

  ZegoCallInvitationConfig? get callInvitationConfig => _callInvitationConfig;

  void register({
    required ZegoInvitationPageManager pageManager,
    required ZegoCallInvitationConfig callInvitationConfig,
  }) {
    ZegoLoggerService.logInfo(
      'register, pageManager:$pageManager, callInvitationConfig:$callInvitationConfig',
      tag: 'call',
      subTag: 'internal instance',
    );

    _pageManager = pageManager;
    _callInvitationConfig = callInvitationConfig;
  }
}
