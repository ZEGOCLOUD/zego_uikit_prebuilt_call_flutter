import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

class ZegoCallReporter {
  static String eventInit = "call/init";
  static String eventUninit = "call/unInit";
  static String eventSendInvitation = 'call/invite';
  static String eventReceivedInvitation = 'call/invitationReceived';
  static String eventDisplayInvitationNotification = 'call/displayNotification';
  static String eventRespondInvitation = 'call/respondInvitation';

  static String eventKeyInvitationSource = "source";
  static String eventKeyInvitationSourceAPI = "api";
  static String eventKeyInvitationSourceButton = "button";

  static String eventKeyExtendedData = "extended_data";

  static String eventKeyAction = "action";
  static String eventKeyActionAccept = "accept";
  static String eventKeyActionRefuse = "refuse";
  static String eventKeyActionBusy = "busy";
  static String eventKeyActionCancel = "inviterCancel";
  static String eventKeyActionTimeout = "timeout";

  /// Version number of each kit, usually in three segments
  static String eventKeyKitVersion = "call_version";

  Future<void> report({
    required String event,
    Map<String, Object> params = const {},
  }) async {
    ZegoUIKit().reporter().report(event: event, params: params);
  }

  factory ZegoCallReporter() {
    return instance;
  }

  ZegoCallReporter._internal();

  static final ZegoCallReporter instance = ZegoCallReporter._internal();
}
