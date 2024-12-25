// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

/// @nodoc
class ZegoInviterCallingBottomToolBar extends StatelessWidget {
  final ZegoCallInvitationPageManager pageManager;
  final ZegoNetworkLoadingConfig? networkLoadingConfig;
  final ZegoCallButtonUIConfig cancelButtonConfig;

  final List<ZegoUIKitUser> invitees;

  const ZegoInviterCallingBottomToolBar({
    Key? key,
    required this.pageManager,
    required this.cancelButtonConfig,
    required this.invitees,
    this.networkLoadingConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.zH,
      child: Center(
        child: (cancelButtonConfig.visible)
            ? ZegoNetworkLoading(
                config: networkLoadingConfig ??
                    ZegoNetworkLoadingConfig(
                      enabled: true,
                      progressColor: Colors.white,
                    ),
                child: ZegoCancelInvitationButton(
                  isAdvancedMode: true,
                  invitees: invitees.map((e) => e.id).toList(),
                  targetInvitationID: pageManager.invitationData.invitationID,
                  data: ZegoCallInvitationCancelRequestProtocol(
                    callID: pageManager.currentCallID,
                  ).toJson(),
                  textStyle: cancelButtonConfig.textStyle,
                  icon: ButtonIcon(
                    icon: cancelButtonConfig.icon ??
                        Image(
                          image: ZegoCallImage.asset(
                            InvitationStyleIconUrls.toolbarBottomCancel,
                          ).image,
                          fit: BoxFit.fill,
                        ),
                  ),
                  buttonSize: cancelButtonConfig.size ?? Size(120.zR, 120.zR),
                  iconSize: cancelButtonConfig.iconSize ?? Size(120.zR, 120.zR),
                  onPressed: (ZegoCancelInvitationButtonResult result) {
                    pageManager.onLocalCancelInvitation(
                      pageManager.invitationData.invitationID,
                      result.code,
                      result.message,
                      result.errorInvitees,
                    );
                  },
                ),
              )
            : Container(),
      ),
    );
  }
}
