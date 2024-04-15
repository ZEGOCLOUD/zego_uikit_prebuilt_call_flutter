part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerPermission {
  final _permissionImpl = ZegoCallControllerPermissionImpl();

  ZegoCallControllerPermissionImpl get permission => _permissionImpl;
}

/// Here are the APIs related to audio video.
class ZegoCallControllerPermissionImpl
    with ZegoCallControllerPermissionImplPrivate {}
