// Project imports:
import 'package:zego_uikit_prebuilt_call/src/deprecated/v4/deprecated_4_11_0.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';

const deprecatedTipsV420 = ', '
    'deprecated since 4.2.0, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4111';

extension ZegoCallInvitationUIConfigDeprecated420
    on ZegoCallInvitationUIConfig {
  @Deprecated('use declineButton.visible instead$deprecatedTipsV420')
  bool get showDeclineButton => declineButton.visible;

  @Deprecated('use declineButton.visible instead$deprecatedTipsV420')
  set showDeclineButton(bool value) => declineButton.visible = value;

  @Deprecated('use cancelButton.visible instead$deprecatedTipsV420')
  bool get showCancelInvitationButton => cancelButton.visible;

  @Deprecated('use cancelButton.visible instead$deprecatedTipsV420')
  set showCancelInvitationButton(bool value) => cancelButton.visible = value;
}

extension ZegoCallRingtoneConfigDeprecated on ZegoCallRingtoneConfig {
  @Deprecated(deprecatedTipsV420)
  String? get packageName => '';

  @Deprecated(deprecatedTipsV420)
  set packageName(String? value) => () {};
}
