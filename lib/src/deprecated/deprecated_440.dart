// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV440 = ', '
    'deprecated since 4.4.0, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#440';

extension ZegoCallInvitationUIConfigDeprecated440
    on ZegoUIKitPrebuiltCallConfig {
  @Deprecated('use hangUpConfirmDialog?.dialogInfo instead$deprecatedTipsV440')
  ZegoCallHangUpConfirmDialogInfo? get hangUpConfirmDialogInfo =>
      hangUpConfirmDialog.info;

  @Deprecated('use hangUpConfirmDialog?.dialogInfo instead$deprecatedTipsV440')
  set hangUpConfirmDialogInfo(ZegoCallHangUpConfirmDialogInfo? value) =>
      hangUpConfirmDialog.info = value;
}
