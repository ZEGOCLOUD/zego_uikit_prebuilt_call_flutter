# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZegoUIKitPrebuiltCall is a Flutter SDK by ZEGOCLOUD for integrating 1-on-1 and group voice/video calls with call invitation support (online and offline). Current version: 5.0.0.

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run the example app
cd example && flutter run

# Analyze code (strict linting with public_member_api_docs: true)
flutter analyze

# Run tests
flutter test

# Format code
flutter format .

# Sort imports
flutter pub run import_sorter:main
```

## Architecture

### Core APIs

| File | Purpose |
|------|---------|
| `lib/src/call.dart` | Main `ZegoUIKitPrebuiltCall` widget - primary entry point for calls |
| `lib/src/controller.dart` | `ZegoUIKitPrebuiltCallController` singleton for programmatic control |
| `lib/src/invitation/service.dart` | `ZegoUIKitPrebuiltCallInvitationService` singleton for invitation lifecycle |

### Configuration Classes

**`ZegoUIKitPrebuiltCallConfig`** (`lib/src/config.dart`):
- Video/audio settings (`video`, `audioVideoView`)
- UI layouts (`topMenuBar`, `bottomMenuBar`, `memberList`, `chatView`)
- Feature flags (`turnOnCameraWhenJoining`, `enableAccidentalTouchPrevention`)
- Factory constructors: `groupVideoCall()`, `groupVoiceCall()`, `oneOnOneVideoCall()`, `oneOnOneVoiceCall()`

**`ZegoCallInvitationConfig`** (`lib/src/invitation/config.dart`):
- Offline invitations (`offline` config)
- In-call invites (`inCalling` config)
- Missed calls (`missedCall` config)
- CallKit integration (`pip`, `systemWindowConfirmDialog`)

### Controller Pattern (Mixin-Based)

The controller uses **mixin composition** to separate public APIs from private implementations:

```dart
// Public API (lib/src/controller.dart)
mixin ZegoCallControllerMinimizing {
  final _minimizing = ZegoCallControllerMinimizingImpl();
  ZegoCallControllerMinimizingImpl get minimize;
}

// Private impl (lib/src/controller/minimize.dart)
class ZegoCallControllerMinimizingImpl
    with ZegoCallControllerMinimizePrivate {
  bool get isMinimizing;
  bool minimize(BuildContext context);
  bool restore(BuildContext context);
}
```

Available controller mixins in `lib/src/controller/`:
- `audio_video.dart` - mic/camera/output control
- `minimize.dart` - minimize/restore
- `pip.dart` - picture-in-picture
- `invitation.dart` - call invitations
- `screen_sharing.dart` - screen sharing
- `room.dart` - room management
- `user.dart` - user operations
- `permission.dart` - permission handling
- `log.dart` - logging utilities

### Invitation Service Lifecycle

`ZegoUIKitPrebuiltCallInvitationService` manages global invitation state:

```dart
// Initialization
await ZegoUIKitPrebuiltCallInvitationService().init(
  appID: appID,
  appSign: appSign,
  userID: userID,
  userName: userName,
  config: ZegoCallInvitationConfig(...),
);

// Sending calls
await ZegoUIKitPrebuiltCallInvitationService().send(
  invitees: ['userID1', 'userID2'],
  type: ZegoCallType.videoCall,
);

// Key properties
bool isInit;        // Service initialized
bool isInCalling;   // Currently in a call
bool isInCall;      // In active call state
```

### Key Subdirectories

| Directory | Purpose |
|-----------|---------|
| `lib/src/components/` | UI widgets (top/bottom menu bars, member list, effects) |
| `lib/src/invitation/` | Invitation feature, CallKit, push notifications |
| `lib/src/minimizing/` | Overlay/PiP functionality |
| `lib/src/internal/` | Internal utilities, analytics reporter |
| `lib/src/channel/` | Native platform channel implementation |
| `android/src/` | Android plugin (Kotlin) |
| `ios/Classes/` | iOS plugin (Objective-C) |

### Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `zego_uikit` | ^3.0.0 | Core SDK |
| `zego_plugin_adapter` | ^2.14.2 | Plugin adapter |
| `zego_uikit_signaling_plugin` | ^2.8.20 | Signaling for invitations |
| `statemachine` | ^3.4.0 | State machine for calling flow |
| `permission_handler` | ^12.0.1 | Runtime permissions |
| `flutter_callkit_incoming` | ^2.5.5 | Native CallKit integration |
| `flutter_volume_controller` | ^1.3.3 | Volume control |
| `proximity_sensor` | ^1.3.9 | Proximity detection |
| `screen_brightness` | ^0.2.2+1 | Screen brightness control |
| `floating` | ^6.0.0 | Android PiP |

## Design Patterns

- **Service Singleton**: `ZegoUIKitPrebuiltCallInvitationService` manages invitation state globally
- **Mixin Composition**: Controller exposes public APIs via mixins, private impl in `*Impl` classes
- **Builder Pattern**: Customizable UI via `foregroundBuilder`, `backgroundBuilder`, `avatarBuilder`
- **Event Callbacks**: `ZegoUIKitPrebuiltCallEvents` and `ZegoCallInvitationEvents` for lifecycle hooks
- **ValueNotifier**: Reactive state propagation throughout the SDK
- **State Machine**: `statemachine` package manages invitation/calling flow states

## Documentation

- `doc/apis.md` - API reference
- `doc/configs.md` - Configuration options
- `doc/events.md` - Event callbacks
- `doc/components.md` - UI components
- `doc/MigrateGuide_v4.x.md` - Migration guides from v4.x
- `doc/invitation.md` - Invitation feature documentation
- `doc/defines.md` - Shared definitions
