import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit/zego_uikit.dart' show ZegoUIKitAudioRoute;
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/background_service.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/calling/machine.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';

void main() {
  group('iOS CallKit page transition frame', () {
    testWidgets('schedules a frame for the page transition callback', (
      tester,
    ) async {
      await tester.pump();
      var callbackExecuted = false;

      scheduleNextFrameCallback((_) => callbackExecuted = true);

      expect(tester.binding.hasScheduledFrame, isTrue);
      expect(callbackExecuted, isFalse);

      await tester.pump();

      expect(callbackExecuted, isTrue);
    });
  });

  group('shouldEnterIOSCallPageAfterCallKitAnswer', () {
    test('allows the still active accepted call to enter', () {
      expect(
        shouldEnterIOSCallPageAfterCallKitAnswer(
          isAppInBackground: false,
          isIOSCallKitHangupBlockingCallPageEntry: false,
          callPageIsIdle: true,
          acceptedCallID: 'accepted-call',
          activeCallID: 'accepted-call',
          acceptedInvitationID: 'accepted-invitation',
          activeInvitationID: 'accepted-invitation',
        ),
        isTrue,
      );
    });

    test('rejects a call that was cleared before the next frame', () {
      expect(
        shouldEnterIOSCallPageAfterCallKitAnswer(
          isAppInBackground: false,
          isIOSCallKitHangupBlockingCallPageEntry: false,
          callPageIsIdle: true,
          acceptedCallID: 'accepted-call',
          activeCallID: '',
          acceptedInvitationID: 'accepted-invitation',
          activeInvitationID: '',
        ),
        isFalse,
      );
    });

    test('rejects a different call that replaced the accepted call', () {
      expect(
        shouldEnterIOSCallPageAfterCallKitAnswer(
          isAppInBackground: false,
          isIOSCallKitHangupBlockingCallPageEntry: false,
          callPageIsIdle: true,
          acceptedCallID: 'accepted-call',
          activeCallID: 'next-call',
          acceptedInvitationID: 'accepted-invitation',
          activeInvitationID: 'next-invitation',
        ),
        isFalse,
      );
    });

    test('rejects the call while CallKit hangup state blocks page entry', () {
      expect(
        shouldEnterIOSCallPageAfterCallKitAnswer(
          isAppInBackground: false,
          isIOSCallKitHangupBlockingCallPageEntry: true,
          callPageIsIdle: true,
          acceptedCallID: 'accepted-call',
          activeCallID: 'accepted-call',
          acceptedInvitationID: 'accepted-invitation',
          activeInvitationID: 'accepted-invitation',
        ),
        isFalse,
      );
    });
  });

  group('resolveIOSCallKitAudioRoute', () {
    test('uses the receiver when speaker is disabled', () {
      expect(
        resolveIOSCallKitAudioRoute(useSpeakerWhenJoining: false),
        ZegoUIKitAudioRoute.receiver,
      );
    });

    test('uses the speaker when speaker is enabled', () {
      expect(
        resolveIOSCallKitAudioRoute(useSpeakerWhenJoining: true),
        ZegoUIKitAudioRoute.speaker,
      );
    });
  });

  group('ZegoUIKitPrebuiltCallingConfig.sync speaker precedence', () {
    test('invitee default overrides a speaker-enabled call config', () {
      final callConfig = ZegoUIKitPrebuiltCallConfig(
        useSpeakerWhenJoining: true,
      );
      ZegoUIKitPrebuiltCallingConfig().sync(
        ZegoCallInvitationType.videoCall,
        callConfig,
        ZegoCallInvitationInviterUIConfig(),
        ZegoCallInvitationInviteeUIConfig(defaultSpeakerOn: false),
        localUserIsInviter: false,
      );
      expect(callConfig.useSpeakerWhenJoining, isFalse);
    });

    test('explicit receiver selection overrides the invitee default', () {
      final callConfig = ZegoUIKitPrebuiltCallConfig(
        useSpeakerWhenJoining: true,
      );
      ZegoUIKitPrebuiltCallingConfig()
        ..useSpeakerWhenJoining = false
        ..sync(
          ZegoCallInvitationType.videoCall,
          callConfig,
          ZegoCallInvitationInviterUIConfig(),
          ZegoCallInvitationInviteeUIConfig(defaultSpeakerOn: true),
          localUserIsInviter: false,
        );
      expect(callConfig.useSpeakerWhenJoining, isFalse);
    });

    test('explicit speaker selection overrides the invitee default', () {
      final callConfig = ZegoUIKitPrebuiltCallConfig(
        useSpeakerWhenJoining: false,
      );
      ZegoUIKitPrebuiltCallingConfig()
        ..useSpeakerWhenJoining = true
        ..sync(
          ZegoCallInvitationType.videoCall,
          callConfig,
          ZegoCallInvitationInviterUIConfig(),
          ZegoCallInvitationInviteeUIConfig(defaultSpeakerOn: false),
          localUserIsInviter: false,
        );
      expect(callConfig.useSpeakerWhenJoining, isTrue);
    });

    test('falls back to call config when invitation config is unset', () {
      final callConfig = ZegoUIKitPrebuiltCallConfig(
        useSpeakerWhenJoining: true,
      );
      ZegoUIKitPrebuiltCallingConfig().sync(
        ZegoCallInvitationType.videoCall,
        callConfig,
        null,
        null,
        localUserIsInviter: false,
      );
      expect(callConfig.useSpeakerWhenJoining, isTrue);
    });
  });

  group('ensureCallKitRoomLeaveSucceeded', () {
    test('accepts the success result code', () {
      expect(() => ensureCallKitRoomLeaveSucceeded(0, '{}'), returnsNormally);
    });

    test('treats a nonzero result code as cleanup failure', () {
      expect(
        () => ensureCallKitRoomLeaveSucceeded(123, '{"reason":"failed"}'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('123'),
          ),
        ),
      );
    });
  });

  group('IOSCallKitHangupOperation', () {
    test(
      'shares an in-flight cleanup between overlapping end events',
      () async {
        final operation = IOSCallKitHangupOperation();
        final cleanupGate = Completer<void>();
        var cleanupCount = 0;

        final first = operation.run(() async {
          cleanupCount++;
          await cleanupGate.future;
        });
        final second = operation.run(() async {
          cleanupCount++;
        });

        expect(cleanupCount, 1);
        cleanupGate.complete();
        await Future.wait([first, second]);

        await operation.run(() async {
          cleanupCount++;
        });
        expect(cleanupCount, 2);
      },
    );

    test('allows a new cleanup after an earlier cleanup fails', () async {
      final operation = IOSCallKitHangupOperation();
      var cleanupCount = 0;

      await expectLater(
        operation.run(() async {
          cleanupCount++;
          throw StateError('cleanup failed');
        }),
        throwsStateError,
      );

      await operation.run(() async {
        cleanupCount++;
      });
      expect(cleanupCount, 2);
    });
  });

  group('runIOSCallKitHangupWithPageDisposeWait', () {
    test(
      'holds the flag during cleanup and releases stale waiters afterward',
      () async {
        final guard = IOSCallKitHangupWaitFlagGuard();
        final cleanupGate = Completer<void>();
        var waitFlag = true;
        var listenerReleased = false;

        void setWaitFlag(bool value) {
          if (guard.shouldApplyWaitFlag(value)) {
            waitFlag = value;
            if (!value) {
              listenerReleased = true;
            }
          }
        }

        final cleanup = runIOSCallKitHangupWithPageDisposeWait(
          cleanup: () async {
            expect(waitFlag, isTrue);
            await cleanupGate.future;
          },
          hasCallPageToDispose: () => false,
          setWaitFlag: setWaitFlag,
          beginCleanup: guard.beginCleanup,
          endCleanup: guard.endCleanup,
        );

        expect(waitFlag, isTrue);

        // A CallPage dispose callback can fire before leaveRoom completes.
        setWaitFlag(false);
        expect(waitFlag, isTrue);
        expect(listenerReleased, isFalse);

        cleanupGate.complete();
        await cleanup;

        expect(waitFlag, isFalse);
        expect(listenerReleased, isTrue);
      },
    );

    test('keeps waiting when a call page push is still pending', () async {
      final guard = IOSCallKitHangupWaitFlagGuard();
      var callPagePushPending = true;
      var waitFlag = false;

      void setWaitFlag(bool value) {
        if (guard.shouldApplyWaitFlag(value)) {
          waitFlag = value;
        }
      }

      await runIOSCallKitHangupWithPageDisposeWait(
        cleanup: () async {},
        hasCallPageToDispose: () => callPagePushPending,
        setWaitFlag: setWaitFlag,
        beginCleanup: guard.beginCleanup,
        endCleanup: guard.endCleanup,
      );

      expect(waitFlag, isTrue);

      callPagePushPending = false;
      setWaitFlag(false);
      expect(waitFlag, isFalse);
    });

    test(
      'keeps waiting while an existing call page still needs dispose',
      () async {
        final guard = IOSCallKitHangupWaitFlagGuard();
        var waitFlag = false;

        await runIOSCallKitHangupWithPageDisposeWait(
          cleanup: () async {},
          hasCallPageToDispose: () => true,
          setWaitFlag: (value) {
            if (guard.shouldApplyWaitFlag(value)) {
              waitFlag = value;
            }
          },
          beginCleanup: guard.beginCleanup,
          endCleanup: guard.endCleanup,
        );

        expect(waitFlag, isTrue);
      },
    );

    test(
      'keeps the flag set until every overlapping cleanup completes',
      () async {
        final guard = IOSCallKitHangupWaitFlagGuard();
        final firstCleanupGate = Completer<void>();
        final secondCleanupGate = Completer<void>();
        var waitFlag = false;

        void setWaitFlag(bool value) {
          if (guard.shouldApplyWaitFlag(value)) {
            waitFlag = value;
          }
        }

        final firstCleanup = runIOSCallKitHangupWithPageDisposeWait(
          cleanup: () => firstCleanupGate.future,
          hasCallPageToDispose: () => false,
          setWaitFlag: setWaitFlag,
          beginCleanup: guard.beginCleanup,
          endCleanup: guard.endCleanup,
        );
        final secondCleanup = runIOSCallKitHangupWithPageDisposeWait(
          cleanup: () => secondCleanupGate.future,
          hasCallPageToDispose: () => false,
          setWaitFlag: setWaitFlag,
          beginCleanup: guard.beginCleanup,
          endCleanup: guard.endCleanup,
        );

        firstCleanupGate.complete();
        await firstCleanup;
        setWaitFlag(false);
        expect(waitFlag, isTrue);

        secondCleanupGate.complete();
        await secondCleanup;
        expect(waitFlag, isFalse);
      },
    );

    test(
      'keeps the wait flag on cleanup failure and allows a successful retry',
      () async {
        final guard = IOSCallKitHangupWaitFlagGuard();
        var waitFlag = false;

        void setWaitFlag(bool value) {
          if (guard.shouldApplyWaitFlag(value)) {
            waitFlag = value;
          }
        }

        await expectLater(
          runIOSCallKitHangupWithPageDisposeWait(
            cleanup: () async => throw StateError('leave room failed'),
            hasCallPageToDispose: () => false,
            setWaitFlag: setWaitFlag,
            beginCleanup: guard.beginCleanup,
            endCleanup: guard.endCleanup,
          ),
          throwsStateError,
        );

        expect(waitFlag, isTrue);
        expect(guard.isCleanupInProgress, isFalse);
        final hangupBlocksPageEntry = guard.blocksCallPageEntry(waitFlag);
        expect(hangupBlocksPageEntry, isTrue);
        expect(
          shouldEnterIOSCallPageAfterCallKitAnswer(
            isAppInBackground: false,
            isIOSCallKitHangupBlockingCallPageEntry: hangupBlocksPageEntry,
            callPageIsIdle: true,
            acceptedCallID: 'accepted-call',
            activeCallID: 'accepted-call',
            acceptedInvitationID: 'accepted-invitation',
            activeInvitationID: 'accepted-invitation',
          ),
          isFalse,
        );

        await runIOSCallKitHangupWithPageDisposeWait(
          cleanup: () async {},
          hasCallPageToDispose: () => false,
          setWaitFlag: setWaitFlag,
          beginCleanup: guard.beginCleanup,
          endCleanup: guard.endCleanup,
        );

        expect(waitFlag, isFalse);
      },
    );
  });

  group('pushCallPageWithPendingState', () {
    test('marks the route pending before Navigator push runs', () {
      var isPagePushed = false;
      var wasMarkedBeforePush = false;

      pushCallPageWithPendingState(
        setPagePushed: (value) => isPagePushed = value,
        push: () => wasMarkedBeforePush = isPagePushed,
      );

      expect(wasMarkedBeforePush, isTrue);
      expect(isPagePushed, isTrue);
    });

    test('rolls back pending state when Navigator push throws', () {
      var isPagePushed = false;
      var waitFlag = true;

      expect(
        () => pushCallPageWithPendingState(
          setPagePushed: (value) => isPagePushed = value,
          onPushFailure: () => waitFlag = false,
          push: () => throw StateError('push failed'),
        ),
        throwsStateError,
      );

      expect(isPagePushed, isFalse);
      expect(waitFlag, isFalse);
    });
  });
}
