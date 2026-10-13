import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_event_adapter.dart';

void main() {
  const callKitParams = CallKitParams(id: 'call-1');

  group('adaptCallKitIncomingEvent', () {
    final mappedEvents = <({CallEvent event, CallKitIncomingAction action})>[
      (
        event: const CallEventActionCallIncoming(callKitParams),
        action: CallKitIncomingAction.incoming,
      ),
      (
        event: const CallEventActionCallAccept(callKitParams),
        action: CallKitIncomingAction.accept,
      ),
      (
        event: const CallEventActionCallDecline(callKitParams),
        action: CallKitIncomingAction.decline,
      ),
      (
        event: const CallEventActionCallTimeout('call-1'),
        action: CallKitIncomingAction.timeout,
      ),
      (
        event: const CallEventActionCallEnded(callKitParams),
        action: CallKitIncomingAction.ended,
      ),
      (
        event: const CallEventActionCallToggleAudioSession(true),
        action: CallKitIncomingAction.toggleAudioSession,
      ),
      (
        event: const CallEventActionCallToggleMute('call-1', true),
        action: CallKitIncomingAction.toggleMute,
      ),
    ];

    for (final testCase in mappedEvents) {
      test('${testCase.event.runtimeType} maps to ${testCase.action}', () {
        final info = adaptCallKitIncomingEvent(testCase.event);

        expect(info, isNotNull);
        expect(info!.action, testCase.action);
      });
    }

    test('audio session event preserves isActive', () {
      final active = adaptCallKitIncomingEvent(
        const CallEventActionCallToggleAudioSession(true),
      );
      final inactive = adaptCallKitIncomingEvent(
        const CallEventActionCallToggleAudioSession(false),
      );

      expect(active?.isActive, isTrue);
      expect(inactive?.isActive, isFalse);
    });

    test('mute event preserves isMuted', () {
      final muted = adaptCallKitIncomingEvent(
        const CallEventActionCallToggleMute('call-1', true),
      );
      final unmuted = adaptCallKitIncomingEvent(
        const CallEventActionCallToggleMute('call-1', false),
      );

      expect(muted?.isMuted, isTrue);
      expect(unmuted?.isMuted, isFalse);
    });

    test('unhandled and null events return null', () {
      final unhandledEvents = <CallEvent>[
        const CallEventActionCallStart(callKitParams),
        const CallEventActionCallCallback('call-1'),
        const CallEventActionCallCustom({}),
        const CallEventActionCallConnected('call-1'),
      ];

      for (final event in unhandledEvents) {
        expect(adaptCallKitIncomingEvent(event), isNull, reason: '$event');
      }
      expect(adaptCallKitIncomingEvent(null), isNull);
    });
  });
}
