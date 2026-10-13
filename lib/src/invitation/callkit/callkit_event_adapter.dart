import 'package:flutter_callkit_incoming/entities/entities.dart';

/// The CallKit Incoming event actions consumed by Prebuilt Call.
enum CallKitIncomingAction {
  incoming,
  accept,
  decline,
  timeout,
  ended,
  toggleAudioSession,
  toggleMute,
}

/// The normalized action and optional state carried by a CallKit event.
final class CallKitIncomingEventInfo {
  /// Creates normalized information for a CallKit event.
  const CallKitIncomingEventInfo({
    required this.action,
    this.isActive,
    this.isMuted,
  });

  /// The event action used by Prebuilt Call.
  final CallKitIncomingAction action;

  /// The audio-session state for a toggle-audio-session event.
  final bool? isActive;

  /// The mute state for a toggle-mute event.
  final bool? isMuted;
}

/// Converts the upstream typed CallKit events into actions used by Prebuilt Call.
CallKitIncomingEventInfo? adaptCallKitIncomingEvent(CallEvent? event) {
  switch (event) {
    case CallEventActionCallIncoming():
      return const CallKitIncomingEventInfo(
        action: CallKitIncomingAction.incoming,
      );
    case CallEventActionCallAccept():
      return const CallKitIncomingEventInfo(
        action: CallKitIncomingAction.accept,
      );
    case CallEventActionCallDecline():
      return const CallKitIncomingEventInfo(
        action: CallKitIncomingAction.decline,
      );
    case CallEventActionCallTimeout():
      return const CallKitIncomingEventInfo(
        action: CallKitIncomingAction.timeout,
      );
    case CallEventActionCallEnded():
      return const CallKitIncomingEventInfo(
        action: CallKitIncomingAction.ended,
      );
    case CallEventActionCallToggleAudioSession(:final isActive):
      return CallKitIncomingEventInfo(
        action: CallKitIncomingAction.toggleAudioSession,
        isActive: isActive,
      );
    case CallEventActionCallToggleMute(:final isMuted):
      return CallKitIncomingEventInfo(
        action: CallKitIncomingAction.toggleMute,
        isMuted: isMuted,
      );
    case null:
    default:
      return null;
  }
}
