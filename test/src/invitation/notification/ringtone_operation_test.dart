import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/ringtone_operation.dart';

void main() {
  group('runRingtoneOperation', () {
    test('returns true when the operation succeeds', () async {
      var operationCalls = 0;
      var errorCalls = 0;

      final succeeded = await runRingtoneOperation(
        operation: () async {
          operationCalls++;
        },
        onError: (error, stackTrace) {
          errorCalls++;
        },
      );

      expect(succeeded, isTrue);
      expect(operationCalls, 1);
      expect(errorCalls, 0);
    });

    test('returns false and reports an operation error', () async {
      final error = StateError('playback failed');
      Object? reportedError;
      StackTrace? reportedStackTrace;

      final succeeded = await runRingtoneOperation(
        operation: () async => throw error,
        onError: (caughtError, stackTrace) {
          reportedError = caughtError;
          reportedStackTrace = stackTrace;
        },
      );

      expect(succeeded, isFalse);
      expect(reportedError, same(error));
      expect(reportedStackTrace, isNotNull);
    });
  });

  group('runCancellableRingtonePreparation', () {
    test('cleans up after preparation completes after cancellation', () async {
      final preparation = Completer<void>();
      var shouldContinue = true;
      var cleanupCalls = 0;

      final result = runCancellableRingtonePreparation(
        operation: () => preparation.future,
        shouldContinue: () => shouldContinue,
        onCancelled: () async {
          cleanupCalls++;
        },
      );

      shouldContinue = false;
      expect(cleanupCalls, 0);
      preparation.complete();

      expect(await result, isFalse);
      expect(cleanupCalls, 1);
    });

    test('keeps resources when preparation is still current', () async {
      var cleanupCalls = 0;

      final result = await runCancellableRingtonePreparation(
        operation: () async {},
        shouldContinue: () => true,
        onCancelled: () async {
          cleanupCalls++;
        },
      );

      expect(result, isTrue);
      expect(cleanupCalls, 0);
    });
  });

  group('RingtoneOperationController', () {
    test('stop waits for a pending start, then stops the ringtone', () async {
      final controller = RingtoneOperationController();
      final playCompleter = Completer<void>();
      final request = controller.reserveStart()!;
      var stopCalls = 0;

      final start = controller.start(
        request: request,
        operation: () => playCompleter.future,
        onError: (error, stackTrace) {},
      );
      final stop = controller.stop(
        operation: () async {
          stopCalls++;
        },
        onError: (error, stackTrace) {},
      );

      expect(controller.isRunning, isTrue);
      expect(stopCalls, 0);
      playCompleter.complete();

      expect(await start, isTrue);
      expect(await stop, isTrue);
      expect(stopCalls, 1);
      expect(controller.isRunning, isFalse);
    });

    test('failed stop keeps running state so the caller can retry', () async {
      final controller = RingtoneOperationController();
      final request = controller.reserveStart()!;

      expect(
        await controller.start(
          request: request,
          operation: () async {},
          onError: (error, stackTrace) {},
        ),
        isTrue,
      );

      expect(
        await controller.stop(
          operation: () async => throw StateError('stop failed'),
          onError: (error, stackTrace) {},
        ),
        isFalse,
      );
      expect(controller.isRunning, isTrue);

      expect(
        await controller.stop(
          operation: () async {},
          onError: (error, stackTrace) {},
        ),
        isTrue,
      );
      expect(controller.isRunning, isFalse);
    });

    test('concurrent stop requests share one native stop operation', () async {
      final controller = RingtoneOperationController();
      final request = controller.reserveStart()!;
      final stopCompleter = Completer<void>();
      var stopCalls = 0;

      await controller.start(
        request: request,
        operation: () async {},
        onError: (error, stackTrace) {},
      );

      final firstStop = controller.stop(
        operation: () {
          stopCalls++;
          return stopCompleter.future;
        },
        onError: (error, stackTrace) {},
      );
      final secondStop = controller.stop(
        operation: () async {
          stopCalls++;
          throw StateError('duplicate stop should not run');
        },
        onError: (error, stackTrace) {},
      );

      expect(stopCalls, 1);
      stopCompleter.complete();

      expect(await firstStop, isTrue);
      expect(await secondStop, isTrue);
      expect(stopCalls, 1);
      expect(controller.isRunning, isFalse);
    });

    test('stop cancels a reserved start before play is called', () async {
      final controller = RingtoneOperationController();
      final request = controller.reserveStart()!;
      var playCalls = 0;

      expect(
        await controller.stop(
          operation: () async => fail('stop should not run without a start'),
          onError: (error, stackTrace) {},
        ),
        isNull,
      );
      expect(
        await controller.start(
          request: request,
          operation: () async {
            playCalls++;
          },
          onError: (error, stackTrace) {},
        ),
        isFalse,
      );
      expect(playCalls, 0);
      expect(controller.isRunning, isFalse);
    });
  });
}
