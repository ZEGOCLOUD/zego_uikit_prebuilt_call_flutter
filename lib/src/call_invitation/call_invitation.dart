// Dart imports:

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/page_manager.dart';

class ZegoUIKitPrebuiltCallInvitationService extends StatefulWidget {
  const ZegoUIKitPrebuiltCallInvitationService({
    Key? key,
    required this.appID,
    required this.appSign,
    required this.userID,
    required this.userName,
    this.tokenServerUrl = '',
    required this.requireConfig,
    required this.child,
    ZegoRingtoneConfig? ringtoneConfig,
    required this.plugins,
  })  : ringtoneConfig = ringtoneConfig ?? const ZegoRingtoneConfig(),
        super(key: key);

  /// you need to fill in the appID you obtained from console.zegocloud.com
  final int appID;

  /// for Android/iOS
  /// you need to fill in the appSign you obtained from console.zegocloud.com
  final String appSign;

  /// tokenServerUrl is only for web.
  /// If you have to support Web and Android, iOS, then you can use it like this
  /// ```
  ///   ZegoUIKitPrebuiltCallInvitationServiceConfig(
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

  /// you can customize your ringing bell
  final ZegoRingtoneConfig ringtoneConfig;

  final Widget child;

  final List<IZegoUIKitPlugin> plugins;

  @override
  State<ZegoUIKitPrebuiltCallInvitationService> createState() =>
      _ZegoUIKitPrebuiltCallInvitationServiceState();
}

class _ZegoUIKitPrebuiltCallInvitationServiceState
    extends State<ZegoUIKitPrebuiltCallInvitationService> {
  @override
  void initState() {
    super.initState();

    ZegoUIKit().installPlugins(widget.plugins);

    ZegoUIKit().getZegoUIKitVersion().then((uikitVersion) {
      debugPrint("versions: zego_uikit_prebuilt_call:1.2.0; $uikitVersion");
    });

    for (var pluginType in ZegoUIKitPluginType.values) {
      ZegoUIKit().getPlugin(pluginType)?.getVersion().then((version) {
        debugPrint("plugin-$pluginType:$version");
      });
    }

    Permission.camera.status.then((PermissionStatus status) {
      if (status != PermissionStatus.granted &&
          status != PermissionStatus.permanentlyDenied) {
        Permission.camera.request();
      }
    });

    initContext();
  }

  @override
  void didUpdateWidget(ZegoUIKitPrebuiltCallInvitationService oldWidget) {
    super.didUpdateWidget(oldWidget);

    reLoginContext(widget.userID, widget.userName);
  }

  @override
  void dispose() async {
    super.dispose();

    uninitContext();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void initContext() async {
    await ZegoUIKitInvitationService()
        .init(widget.appID, appSign: widget.appSign);
    await ZegoUIKitInvitationService().login(widget.userID, widget.userName);

    ZegoUIKit().login(widget.userID, widget.userName).then((value) {
      ZegoUIKit().init(appID: widget.appID, appSign: widget.appSign);

      ZegoUIKit.instance.turnCameraOn(false);
    });

    ZegoInvitationPageManager.instance.init(
      appID: widget.appID,
      appSign: widget.appSign,
      tokenServerUrl: widget.tokenServerUrl,
      userID: widget.userID,
      userName: widget.userName,
      configQuery: widget.requireConfig,
      contextQuery: () {
        return context;
      },
      ringtoneConfig: widget.ringtoneConfig,
    );
  }

  void uninitContext() async {
    ZegoInvitationPageManager.instance.uninit();

    // TODO: 这里的生命周期看下是否合理
    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().uninit();
  }

  Future<void> reLoginContext(String userID, String userName) async {
    var localUser = ZegoUIKit().getLocalUser();
    if (localUser.id == userID && localUser.name == userName) {
      debugPrint("same user, cancel this reLogin");
      return;
    }

    await ZegoUIKitInvitationService().logout();
    await ZegoUIKitInvitationService().login(userID, userName);
  }
}
