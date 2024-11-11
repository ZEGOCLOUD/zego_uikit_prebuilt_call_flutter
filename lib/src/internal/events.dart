// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/events.dart';

class ZegoCallEventListener {
  final ZegoUIKitPrebuiltCallEvents? events;
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  ZegoCallEventListener(this.events);

  void init() {
    _subscriptions
      ..add(ZegoUIKit().getUserJoinStream().listen(_onUserJoin))
      ..add(ZegoUIKit().getUserLeaveStream().listen(_onUserLeave));

    ZegoUIKit()
        .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
        .addListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
        .addListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(ZegoUIKit().getLocalUser().id)
        .addListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id)
        .addListener(_onAudioOutputChanged);

    ZegoUIKit().getRoomStateStream().addListener(_onRoomStateChanged);
  }

  void uninit() {
    ZegoUIKit()
        .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
        .removeListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
        .removeListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(ZegoUIKit().getLocalUser().id)
        .removeListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id)
        .removeListener(_onAudioOutputChanged);

    for (final subscription in _subscriptions) {
      subscription?.cancel();
    }
  }

  void _onUserJoin(List<ZegoUIKitUser> users) {
    for (var user in users) {
      events?.user?.onEnter?.call(user);
    }
  }

  void _onUserLeave(List<ZegoUIKitUser> users) {
    for (var user in users) {
      events?.user?.onLeave?.call(user);
    }
  }

  void _onRoomStateChanged() {
    events?.room?.onStateChanged?.call(ZegoUIKit().getRoomStateStream().value);
  }

  void _onCameraStateChanged() {
    events?.audioVideo?.onCameraStateChanged?.call(
      ZegoUIKit().getCameraStateNotifier(ZegoUIKit().getLocalUser().id).value,
    );
  }

  void _onMicrophoneStateChanged() {
    events?.audioVideo?.onMicrophoneStateChanged?.call(
      ZegoUIKit()
          .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
          .value,
    );
  }

  void _onFrontFacingCameraStateChanged() {
    events?.audioVideo?.onFrontFacingCameraStateChanged?.call(
      ZegoUIKit()
          .getUseFrontFacingCameraStateNotifier(ZegoUIKit().getLocalUser().id)
          .value,
    );
  }

  void _onAudioOutputChanged() {
    events?.audioVideo?.onAudioOutputChanged?.call(
      ZegoUIKit()
          .getAudioOutputDeviceNotifier(ZegoUIKit().getLocalUser().id)
          .value,
    );
  }
}
