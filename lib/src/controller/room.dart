part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerRoom {
  final _roomImpl = ZegoCallControllerRoomImpl();

  ZegoCallControllerRoomImpl get room => _roomImpl;
}

/// Here are the APIs related to screen sharing.
class ZegoCallControllerRoomImpl {
  /// when receives [ZegoCallRoomEvents.onTokenExpired], you need use this API to update the token
  Future<void> renewToken(String token) async {
    await ZegoUIKit().renewRoomToken(token);

    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) != null) {
      ZegoUIKit().getSignalingPlugin().renewToken(token);
    }
  }
}
