part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerUser {
  final _userImpl = ZegoCallControllerUserImpl();

  ZegoCallControllerUserImpl get user => _userImpl;
}

/// Here are the APIs related to audio video.
class ZegoCallControllerUserImpl with ZegoCallControllerUserImplPrivate {
  /// user list stream notifier
  Stream<List<ZegoUIKitUser>> get stream => ZegoUIKit().getUserListStream();

  /// remove user from live, kick out
  ///
  /// @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
  ///
  /// @return A `Future` that representing whether the request was successful.
  Future<bool> remove(List<String> userIDs) async {
    ZegoLoggerService.logInfo(
      'remove user:$userIDs',
      tag: 'call',
      subTag: 'controller.user',
    );

    return ZegoUIKit().removeUserFromRoom(userIDs);
  }
}
