// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';

class ZegoNotificationManager {
  factory ZegoNotificationManager() => instance;
  static final ZegoNotificationManager instance =
      ZegoNotificationManager._internal();

  ZegoNotificationManager._internal();

  ZegoUIKitPrebuiltCallInvitationEvents? events;

  void init({
    required ZegoUIKitPrebuiltCallInvitationEvents? events,
  }) {
    this.events = events;
  }

  void uninit() {
    events = null;
  }
}
