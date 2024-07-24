// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';

const deprecatedTipsV4_11_0 = ', '
    'deprecated since 4.11.0, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4110';

extension ZegoCallInvitationUIConfigDeprecated4110
    on ZegoCallInvitationUIConfig {
  @Deprecated('use inviter.cancelButton instead$deprecatedTipsV4_11_0')
  ZegoCallButtonUIConfig get cancelButton => inviter.cancelButton;

  @Deprecated('use inviter.cancelButton instead$deprecatedTipsV4_11_0')
  set cancelButton(ZegoCallButtonUIConfig value) =>
      inviter.cancelButton = value;

  @Deprecated('use invitee.declineButton instead$deprecatedTipsV4_11_0')
  ZegoCallButtonUIConfig get declineButton => invitee.declineButton;

  @Deprecated('use invitee.declineButton instead$deprecatedTipsV4_11_0')
  set declineButton(ZegoCallButtonUIConfig value) =>
      invitee.declineButton = value;

  @Deprecated('use invitee.acceptButton instead$deprecatedTipsV4_11_0')
  ZegoCallButtonUIConfig get acceptButton => invitee.acceptButton;

  @Deprecated('use invitee.acceptButton instead$deprecatedTipsV4_11_0')
  set acceptButton(ZegoCallButtonUIConfig value) =>
      invitee.acceptButton = value;

  @Deprecated('use invitee.popUp instead$deprecatedTipsV4_11_0')
  ZegoCallInvitationNotifyPopUpUIConfig get popUp => invitee.popUp;

  @Deprecated('use invitee.popUp instead$deprecatedTipsV4_11_0')
  set popUp(ZegoCallInvitationNotifyPopUpUIConfig value) =>
      invitee.popUp = popUp;
}
