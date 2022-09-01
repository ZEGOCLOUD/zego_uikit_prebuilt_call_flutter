// Flutter imports:
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'defines.dart';
import 'internal/call_invitation_service.dart';

typedef ConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

class ZegoUIKitPrebuiltCallWithInvitation extends StatefulWidget {
  const ZegoUIKitPrebuiltCallWithInvitation({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.serverSecret,
    required this.userID,
    required this.userName,
    this.tokenServerUrl = '',
    required this.requireConfig,
    required this.child,
  }) : super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appID you obtained from console.zegocloud.com
  final String appSign;
  final String serverSecret;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltCallWithInvitationConfig(
  ///     appID: appID,
  ///     userID: userID,
  ///     userName: userName,
  ///     appSign: kIsWeb ? '' : appSign,
  ///     tokenServerUrl: kIsWeb ? tokenServerUrl：'',
  ///   );
  /// ```
  final String tokenServerUrl;

  /// local user info
  final String userID;
  final String userName;

  ///
  final ConfigQuery requireConfig;

  final Widget child;

  @override
  State<ZegoUIKitPrebuiltCallWithInvitation> createState() =>
      _ZegoUIKitPrebuiltCallWithInvitationState();
}

class _ZegoUIKitPrebuiltCallWithInvitationState
    extends State<ZegoUIKitPrebuiltCallWithInvitation> {
  @override
  void initState() {
    super.initState();

    initService();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallWithInvitation oldWidget) {
    super.didUpdateWidget(oldWidget);

    ZegoCallInvitationService.instance.reLogin(widget.userID, widget.userName);
  }

  @override
  void dispose() async {
    super.dispose();

    ZegoCallInvitationService.instance.uninit();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void initService() {
    ZegoCallInvitationService.instance.init(
      appID: widget.appID,
      appSign: widget.appSign,
      serverSecret: widget.serverSecret,
      tokenServerUrl: widget.tokenServerUrl,
      userID: widget.userID,
      userName: widget.userName,
      configQuery: widget.requireConfig,
      contextQuery: () {
        return context;
      },
    );
  }
}
