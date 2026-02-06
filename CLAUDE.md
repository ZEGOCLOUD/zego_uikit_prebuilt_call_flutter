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

- **`lib/src/call.dart`** - Main `ZegoUIKitPrebuiltCall` widget, the primary entry point for call functionality
- **`lib/src/invitation/service.dart`** - `ZegoUIKitPrebuiltCallInvitationService` singleton managing invitation lifecycle
- **`lib/src/controller.dart`** - `ZegoUIKitPrebuiltCallController` for programmatic call control

### Configuration

- **`lib/src/config.dart`** - `ZegoUIKitPrebuiltCallConfig` for call configuration
- **`lib/src/invitation/config.dart`** - `ZegoCallInvitationConfig` for invitation configuration

### Key Subdirectories

- **`lib/src/components/`** - UI components (member list, messages, effects)
- **`lib/src/invitation/`** - Call invitation feature implementation
- **`lib/src/minimizing/`** - Minimize/PiP functionality
- **`lib/src/controller/`** - Private controller implementations
- **`lib/src/internal/`** - Internal utilities

### Native Code

- **`android/src/`** - Android plugin implementation
- **`ios/Classes/`** - iOS plugin implementation

### Dependencies

The SDK depends on:
- `zego_uikit: ^3.0.0` - Core SDK
- `zego_plugin_adapter: ^2.14.2` - Plugin adapter
- `zego_uikit_signaling_plugin: ^2.8.20` - Signaling for call invitations

## Design Patterns

- **Service Singleton**: `ZegoUIKitPrebuiltCallInvitationService` manages invitation state globally
- **Controller Pattern**: `ZegoUIKitPrebuiltCallController` exposes programmatic APIs
- **Builder Pattern**: Customizable UI via `foregroundBuilder`, `backgroundBuilder`, etc.
- **Event Callbacks**: Rich event system through `ZegoUIKitPrebuiltCallEvents` and `ZegoCallInvitationEvents`
- **State Management**: Uses `ValueNotifier` for state propagation

## Documentation

- `doc/apis.md` - API reference
- `doc/configs.md` - Configuration options
- `doc/events.md` - Event callbacks
- `doc/components.md` - UI components
- `doc/MigrateGuide_v4.x.md` - Migration guides from v4.x
