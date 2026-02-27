# ZEGO UIKit Prebuilt Call Flutter - In-App Minimization Feature Documentation

## Overview

The in-app minimization feature allows users to minimize the call interface to a draggable floating window within the app. This feature supports two scenarios: **in-call minimization** and **invitation minimization**, providing users with a seamless calling experience.

## Architecture Overview

### Core Components

```
lib/src/minimizing/
├── data.dart              # Minimization data structures
├── defines.dart           # State definitions and enums
├── overlay_machine.dart   # Floating window state machine
├── overlay_page.dart      # Main floating window component
└── mini_button.dart       # Minimization button component

lib/src/controller/
├── minimize.dart          # Main minimization controller
└── private/
    └── minimize.dart      # Private implementation details

lib/src/invitation/
└── pages/
    ├── page_manager.dart  # Invitation page management
    └── calling/
        └── machine.dart   # Invitation state machine
```

## Data Structures

### ZegoCallMinimizeData

The main data container for minimization, using a union type pattern:

```dart
class ZegoCallMinimizeData {
  final int appID;
  final String appSign;
  final String token;
  final String userID;
  final String userName;
  final String callID;
  final VoidCallback? onDispose;

  // Union type, using named constructors
  final ZegoInCallMinimizeData? inCall;
  final ZegoInvitingMinimizeData? inviting;

  // Named constructors
  const ZegoCallMinimizeData.inCall({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    this.onDispose,
    required ZegoInCallMinimizeData inCallData,
  }) : inCall = inCallData, inviting = null;

  const ZegoCallMinimizeData.inviting({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    this.onDispose,
    required ZegoInvitingMinimizeData invitingData,
  }) : inviting = invitingData, inCall = null;
}
```

### ZegoInCallMinimizeData

Minimization data during a call:

```dart
class ZegoInCallMinimizeData {
  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final bool isPrebuiltFromMinimizing;
  final List<IZegoUIKitPlugin>? plugins;
  final DateTime durationStartTime;
}
```

### ZegoInvitingMinimizeData

Minimization data during invitation:

```dart
class ZegoInvitingMinimizeData {
  final ZegoUIKitPrebuiltCallingConfig callingConfig;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  final ZegoCallInvitationPageManager pageManager;
}
```

## State Management

### ZegoCallMiniOverlayPageState

```dart
enum ZegoCallMiniOverlayPageState {
  idle,               // No floating window displayed
  inCallMinimized,    // Call interface minimized
  invitingMinimized,  // Invitation interface minimized
}
```

### ZegoCallMiniOverlayMachine

A state machine that manages floating window visibility and state transitions:

```dart
class ZegoCallMiniOverlayMachine {
  static final ZegoCallMiniOverlayMachine _instance = ZegoCallMiniOverlayMachine._internal();
  factory ZegoCallMiniOverlayMachine() => _instance;

  ZegoCallMiniOverlayPageState _state = ZegoCallMiniOverlayPageState.idle;
  final List<Function(ZegoCallMiniOverlayPageState)> _listeners = [];

  ZegoCallMiniOverlayPageState state() => _state;

  void changeState(ZegoCallMiniOverlayPageState newState) {
    if (_state != newState) {
      final oldState = _state;
      _state = newState;
      _notifyListeners(oldState, newState);
    }
  }
}
```

## Key Workflows

### 1. In-Call Minimization

**Trigger**: User clicks the minimize button during a call

**Flow**:

```
1. User clicks minimize button
2. ZegoCallMinimizingButton.onPressed() is called
3. ZegoUIKitPrebuiltCallController().minimize.minimize() is called
4. Floating window state changes to inCallMinimized
5. ZegoCallMiniOverlayPage displays the minimized call interface
6. Full call interface is popped from navigation stack
```

**Code Path**:

```dart
// lib/src/minimizing/mini_button.dart
onPressed: () {
  ZegoUIKitPrebuiltCallController().minimize.minimize();
}

// lib/src/controller/minimize.dart
void minimize() {
  final minimizeData = private.minimizeData;
  if (minimizeData?.inCall != null) {
    // Create floating window with call data
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.inCallMinimized
    );
    // Pop full interface
    Navigator.of(context).pop();
  }
}
```

### 2. Invitation Minimization

**Trigger**: User clicks the minimize button during invitation

**Flow**:

```
1. User clicks minimize button on invitation screen
2. ZegoCallMinimizingButton.onPressed() is called
3. ZegoUIKitPrebuiltCallController().minimize.minimizeInviting() is called
4. Floating window state changes to invitingMinimized
5. ZegoCallMiniOverlayPage displays the minimized invitation interface
6. Full invitation interface is popped from navigation stack
```

**Code Path**:

```dart
// lib/src/controller/minimize.dart
void minimizeInviting() {
  final minimizeData = private.minimizeData;
  if (minimizeData?.inviting != null) {
    // Create floating window with invitation data
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.invitingMinimized
    );
    // Pop full interface
    Navigator.of(context).pop();
  }
}
```

### 3. State Transition

**Trigger**: Remote user accepts invitation while invitation is minimized

**Flow**:

```
1. Remote user accepts invitation
2. page_manager.dart calls onInvitationAccepted()
3. Check if current state is invitingMinimized
4. Immediately transition floating window state to idle
5. Clear minimization data
6. Call page initializes with correct idle state
7. Audio/video connection successfully established
```

**Code Path**:

```dart
// lib/src/invitation/pages/page_manager.dart
void onInvitationAccepted(Map<String, dynamic> params) {
  // ... existing logic ...

  // Key fix: If invitation screen is currently minimized,
  // immediately transition floating window state to ensure
  // call page can initialize correctly
  if (ZegoCallMiniOverlayPageState.invitingMinimized ==
      ZegoUIKitPrebuiltCallController().minimize.state) {

    // Immediately hide floating window, set state to idle
    ZegoCallMiniOverlayMachine()
        .changeState(ZegoCallMiniOverlayPageState.idle);

    // Clear minimization data to prevent call page from detecting
    // non-idle floating window state during initialization
    ZegoUIKitPrebuiltCallController().minimize.private.clearMinimizeData();
  }

  // Continue normal flow
  if (isInCalling) {
    callingMachine?.stateOnlineAudioVideo.enter();
  }
}
```

## Controller Implementation

### ZegoUIKitPrebuiltCallController.minimize

Main public interface for minimization operations:

```dart
class ZegoUIKitPrebuiltCallController {
  ZegoCallControllerMinimizingImpl get minimize =>
    ZegoCallControllerMinimizingImpl();
}

class ZegoCallControllerMinimizingImpl {
  /// Minimize current call interface
  void minimize();

  /// Minimize current invitation interface
  void minimizeInviting();

  /// Restore minimized call interface
  void restore();

  /// Restore minimized invitation interface
  void restoreInviting();

  /// Hide floating window (used when call ends)
  void hide();
}
```

### Private Implementation

```dart
class ZegoCallControllerMinimizingImpl {
  ZegoCallControllerMinimizePrivate get private =>
    ZegoCallControllerMinimizePrivateImpl();

  /// Listen for invitation state changes
  void _listenInvitationStateChanged(ZegoCallInvitationPageManager pageManager);

  /// Auto-transition minimization state when invitation is accepted
  void _autoConvertToInCallMinimized();

  /// Convert invitation config to prebuilt call config
  ZegoUIKitPrebuiltCallConfig _convertCallingConfigToPrebuiltConfig(
    ZegoUIKitPrebuiltCallingConfig callingConfig
  );
}
```

## Floating Window Component Implementation

### ZegoUIKitPrebuiltCallMiniOverlayPage

Main floating window component that displays different content based on state:

```dart
class ZegoUIKitPrebuiltCallMiniOverlayPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return OverlayEntry(
      builder: (context) => _buildOverlayContent(),
    );
  }

  Widget _buildOverlayContent() {
    switch (ZegoCallMiniOverlayMachine().state()) {
      case ZegoCallMiniOverlayPageState.inCallMinimized:
        return _buildInCallMinimizedWidget();
      case ZegoCallMiniOverlayPageState.invitingMinimized:
        return _buildInvitingMinimizedWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
```

### Component Types

#### ZegoMinimizingCallPage

Displays minimized call interface, containing:

- User avatar and name
- Call duration
- Minimize/restore button
- Hang up button

#### ZegoMinimizingCallingPage

Displays minimized invitation interface, containing:

- Inviter information
- Call type indicator
- Minimize/restore button
- Answer/reject buttons

## Key Technical Points

### 1. State Synchronization

Floating window state must be synchronized with actual call state to prevent initialization issues:

```dart
// Before fix: Call page sees invitingMinimized state
{call} {prebuilt} {mini machine state is not idle, context will not be init}

// After fix: Immediate state transition
ZegoCallMiniOverlayMachine().changeState(ZegoCallMiniOverlayPageState.idle);
private.clearMinimizeData();
```

### 2. Navigation Stack Management

Minimization involves popping the full interface and managing the navigation stack:

```dart
// Pop full interface on minimize
Navigator.of(context).pop();

// Push interface on restore
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ZegoUIKitPrebuiltCall(...),
  ),
);
```

### 3. Data Persistence

Minimization data must persist between state transitions and be cleaned up at the appropriate time:

```dart
// Update data when transitioning state
private.updateMinimizeData(newMinimizeData);

// Clear data when no longer needed
private.clearMinimizeData();
```

### 4. Event Handling

The system must handle various invitation events while minimized:

```dart
// Listen for invitation state changes
pageManager.callingMachine?.onStateChanged = (CallingState state) {
  if (state == CallingState.kOnlineAudioVideo) {
    _autoConvertToInCallMinimized();
  }
};
```

## Performance Considerations

1. **State Machine Efficiency**: Floating window machine uses singleton pattern
2. **Memory Management**: Properly clean up minimization data
3. **Navigation Optimization**: Minimize navigation stack operations
4. **Event Listener Management**: Properly register and clean up

## Test Scenarios

### 1. Basic Minimization

- Minimize during a call
- Minimize during invitation
- Restore from minimized state

### 2. State Transitions

- Invitation accepted while minimized
- Invitation rejected while minimized
- Call ended while minimized

### 3. Edge Cases

- Multiple minimize/restore operations
- App backgrounded while minimized
- Network state changes while minimized

## Future Enhancements

1. **Animation Support**: Smooth transitions between states
2. **Custom Floating Window Style**: User-configurable appearance
3. **Gesture Control**: Swipe to restore, drag to reposition

## Summary

The in-app minimization feature provides a powerful and user-friendly way to handle minimization states for calls and invitations. The recent fix for invitation acceptance while minimized ensures reliable state transitions and correct call initialization. The architecture is designed to be extensible and maintainable, with clear separation of concerns between data, state management, and UI components.
