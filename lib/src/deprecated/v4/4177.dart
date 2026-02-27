// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV4177 = ', '
    'deprecated since 4.17.7, '
    'will be removed after 4.20.0';

extension ZegoCallInvitationConfigDeprecated4177 on ZegoCallInvitationUIConfig {
  @Deprecated('use withSafeArea instead$deprecatedTipsV4177')
  bool get prebuiltWithSafeArea => withSafeArea;

  @Deprecated('use withSafeArea instead$deprecatedTipsV4177')
  set prebuiltWithSafeArea(bool value) => withSafeArea = value;
}
