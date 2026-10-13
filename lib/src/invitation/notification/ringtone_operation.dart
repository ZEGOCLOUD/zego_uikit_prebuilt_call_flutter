/// Runs a ringtone operation and reports failures without leaking async errors.
Future<bool> runRingtoneOperation({
  required Future<void> Function() operation,
  required void Function(Object error, StackTrace stackTrace) onError,
}) async {
  try {
    await operation();
    return true;
  } catch (error, stackTrace) {
    onError(error, stackTrace);
    return false;
  }
}

/// Runs asynchronous setup and cleans up if the request was canceled midway.
Future<bool> runCancellableRingtonePreparation({
  required Future<void> Function() operation,
  required bool Function() shouldContinue,
  required Future<void> Function() onCancelled,
}) async {
  await operation();
  if (shouldContinue()) {
    return true;
  }

  await onCancelled();
  return false;
}

/// Tracks native ringtone startup and stopping as a single lifecycle.
class RingtoneOperationController {
  int _generation = 0;
  bool _isStarting = false;
  bool isRunning = false;
  Future<bool>? _startOperation;
  Future<bool?>? _stopOperation;

  /// Reserves a start request before any asynchronous preparation begins.
  int? reserveStart() {
    if (_isStarting || isRunning) {
      return null;
    }

    _isStarting = true;
    return ++_generation;
  }

  /// Whether [request] still owns the reserved start slot.
  bool isCurrentStart(int request) => _isStarting && request == _generation;

  /// Whether [request] has not been canceled by a stop request.
  bool isCurrentRequest(int request) => request == _generation;

  /// Releases a reserved start if preparation fails or uses another player.
  void cancelStart(int request) {
    if (isCurrentStart(request)) {
      _isStarting = false;
    }
  }

  /// Starts playback if [request] was not canceled by a stop request.
  Future<bool> start({
    required int request,
    required Future<void> Function() operation,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) async {
    if (!isCurrentStart(request)) {
      return false;
    }

    _isStarting = false;
    isRunning = true;
    final startOperation = runRingtoneOperation(
      operation: operation,
      onError: onError,
    );
    _startOperation = startOperation;

    final started = await startOperation;
    if (identical(_startOperation, startOperation)) {
      _startOperation = null;
    }
    if (request == _generation) {
      isRunning = started;
    }
    return started;
  }

  /// Cancels a reserved start, waits for any active start, then stops playback.
  ///
  /// Returns null when there was no active or pending playback. A failed stop
  /// leaves [isRunning] true so a later call can retry it.
  Future<bool?> stop({
    required Future<void> Function() operation,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) {
    final activeStop = _stopOperation;
    if (activeStop != null) {
      return activeStop;
    }

    final request = ++_generation;
    _isStarting = false;

    late final Future<bool?> stopOperation;
    stopOperation =
        _stopAfterPendingStart(
          request: request,
          operation: operation,
          onError: onError,
        ).whenComplete(() {
          if (identical(_stopOperation, stopOperation)) {
            _stopOperation = null;
          }
        });
    _stopOperation = stopOperation;
    return stopOperation;
  }

  Future<bool?> _stopAfterPendingStart({
    required int request,
    required Future<void> Function() operation,
    required void Function(Object error, StackTrace stackTrace) onError,
  }) async {
    final startOperation = _startOperation;
    final started = startOperation == null ? isRunning : await startOperation;
    if (!started && !isRunning) {
      return null;
    }

    final stopped = await runRingtoneOperation(
      operation: operation,
      onError: onError,
    );
    if (request == _generation && stopped) {
      isRunning = false;
    }
    return stopped;
  }
}
