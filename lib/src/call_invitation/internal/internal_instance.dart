// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

/// @nodoc
class ZegoCallInvitationInternalInstance {
  factory ZegoCallInvitationInternalInstance() => instance;

  ZegoCallInvitationInternalInstance._internal();

  static final ZegoCallInvitationInternalInstance instance =
      ZegoCallInvitationInternalInstance._internal();

  ZegoInvitationPageManager? _pageManager;
  ZegoUIKitPrebuiltCallInvitationData? _callInvitationData;

  ZegoInvitationPageManager? get pageManager {
    assert(_pageManager != null,
        'pageManager is null, plugins call ZegoUIKitPrebuiltCallInvitationService().init(...) when user login');
    return _pageManager;
  }

  ZegoUIKitPrebuiltCallInvitationData? get callInvitationData =>
      _callInvitationData;

  void register({
    required ZegoInvitationPageManager pageManager,
    required ZegoUIKitPrebuiltCallInvitationData callInvitationData,
  }) {
    ZegoLoggerService.logInfo(
      'register, pageManager:$pageManager, callInvitationData:$callInvitationData',
      tag: 'call',
      subTag: 'internal instance',
    );

    _pageManager = pageManager;
    _callInvitationData = callInvitationData;
  }

  void unregister() {
    ZegoLoggerService.logInfo(
      'unregister',
      tag: 'call',
      subTag: 'internal instance',
    );

    _pageManager = null;
    _callInvitationData = null;
  }
}
