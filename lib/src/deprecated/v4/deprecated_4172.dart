// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV4172 = ', '
    'deprecated since 4.17.2, '
    'will be removed after 4.20.0';

@Deprecated('use enableDialBack instead$deprecatedTipsV4172')
typedef ZegoCallPermissionConfirmDialogInfo = ZegoCallSystemConfirmDialogInfo;

@Deprecated('use enableDialBack instead$deprecatedTipsV4172')
typedef ZegoCallPermissionConfirmDialogConfig
    = ZegoCallSystemConfirmDialogConfig;

extension ZegoCallInvitationConfigDeprecated4172 on ZegoCallInvitationConfig {
  @Deprecated('use inCalling.canInvitingInCalling instead$deprecatedTipsV4172')
  ZegoCallSystemConfirmDialogConfig? get systemAlertWindowConfirmDialog =>
      systemWindowConfirmDialog;

  @Deprecated('use inCalling.canInvitingInCalling instead$deprecatedTipsV4172')
  set systemAlertWindowConfirmDialog(
          ZegoCallSystemConfirmDialogConfig? value) =>
      systemWindowConfirmDialog = value;
}
