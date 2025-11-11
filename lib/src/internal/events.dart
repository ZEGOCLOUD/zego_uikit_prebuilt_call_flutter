// Dart imports:
import 'dart:async';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/events.dart';

class ZegoCallEventListener {
  final String roomID;
  final ZegoUIKitPrebuiltCallEvents? events;
  final List<StreamSubscription<dynamic>?> _subscriptions = [];

  ZegoCallEventListener(
    this.events, {
    required this.roomID,
  });

  void init() {
    _subscriptions
      ..add(ZegoUIKit()
          .getUserJoinStream(targetRoomID: roomID)
          .listen(_onUserJoin))
      ..add(ZegoUIKit()
          .getUserLeaveStream(targetRoomID: roomID)
          .listen(_onUserLeave));

    ZegoUIKit()
        .getCameraStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .addListener(_onAudioOutputChanged);

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: roomID)
        .addListener(_onRoomStateChanged);
  }

  void uninit() {
    ZegoUIKit()
        .getCameraStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onCameraStateChanged);
    ZegoUIKit()
        .getMicrophoneStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onMicrophoneStateChanged);
    ZegoUIKit()
        .getUseFrontFacingCameraStateNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onFrontFacingCameraStateChanged);
    ZegoUIKit()
        .getAudioOutputDeviceNotifier(
          targetRoomID: roomID,
          ZegoUIKit().getLocalUser().id,
        )
        .removeListener(_onAudioOutputChanged);

    ZegoUIKit()
        .getRoomStateStream(targetRoomID: roomID)
        .removeListener(_onRoomStateChanged);

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
    events?.room?.onStateChanged
        ?.call(ZegoUIKit().getRoomStateStream(targetRoomID: roomID).value);
  }

  void _onCameraStateChanged() {
    events?.audioVideo?.onCameraStateChanged?.call(
      ZegoUIKit()
          .getCameraStateNotifier(
            targetRoomID: roomID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onMicrophoneStateChanged() {
    events?.audioVideo?.onMicrophoneStateChanged?.call(
      ZegoUIKit()
          .getMicrophoneStateNotifier(
            targetRoomID: roomID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onFrontFacingCameraStateChanged() {
    events?.audioVideo?.onFrontFacingCameraStateChanged?.call(
      ZegoUIKit()
          .getUseFrontFacingCameraStateNotifier(
            targetRoomID: roomID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }

  void _onAudioOutputChanged() {
    events?.audioVideo?.onAudioOutputChanged?.call(
      ZegoUIKit()
          .getAudioOutputDeviceNotifier(
            targetRoomID: roomID,
            ZegoUIKit().getLocalUser().id,
          )
          .value,
    );
  }
}
