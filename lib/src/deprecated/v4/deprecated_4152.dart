// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV4152 = ', '
    'deprecated since 4.15.2, '
    'will be removed after 4.20.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4152';

extension ZegoUIKitPrebuiltCallInvitationEventsDeprecated4152
    on ZegoUIKitPrebuiltCallInvitationEvents {
  @Deprecated(
      'use onIncomingMissedCallDialBackFailed instead$deprecatedTipsV4152')
  Function()? get onIncomingMissedCallReCallFailed =>
      onIncomingMissedCallDialBackFailed;
  @Deprecated(
      'use onIncomingMissedCallDialBackFailed instead$deprecatedTipsV4152')
  set onIncomingMissedCallReCallFailed(Function()? value) =>
      onIncomingMissedCallDialBackFailed = value;
}

extension ZegoCallInvitationMissedCallConfigDeprecated4152
    on ZegoCallInvitationMissedCallConfig {
  @Deprecated('use enableDialBack instead$deprecatedTipsV4152')
  bool get enableReCall => enableDialBack;
}
