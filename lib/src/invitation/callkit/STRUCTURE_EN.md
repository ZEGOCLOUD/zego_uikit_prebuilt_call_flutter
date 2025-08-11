# CallKit File Structure Overview

## Overview

The CallKit module adopts a platform-separated architecture: Android and iOS each have independent implementations while maintaining the same file structure and processing logic.

## File Structure Comparison

### Android Structure

```
android/
├── defines.dart              # Android configuration definitions and message handling classes
├── entry_point.dart          # Android background message entry point
├── handler.dart              # Main message handler
├── handler.call.dart         # Call invitation handler
└── handler.im.dart           # IM message handler
```

### iOS Structure

```
ios/
├── defines.dart              # iOS configuration definitions and message handling classes
├── entry_point.dart          # iOS VoIP push entry point
├── handler.dart              # Main message handler
├── handler.call.dart         # Call invitation handler
├── handler.im.dart           # IM message handler
```

## Core Files

### 1. entry_point.dart

- Android: Handles background silent notifications, marked with `@pragma('vm:entry-point')`
- iOS: Handles VoIP push notifications, implements the `onIncomingPushReceived` callback

### 2. handler.dart

- Function: Main message handler responsible for determining and dispatching message types
- Logic:
  - Parse the message type
  - Dispatch to the IM handler or the call handler based on the type
  - Unified error handling and logging

### 3. handler.call.dart

- Function: Handles call invitation related messages
- Features:
  - Supports both basic and advanced invitation modes
  - Handles invitation cancellation
  - Displays the CallKit UI
  - Preserves the original iOS offline call logic

### 4. handler.im.dart

- Function: Handles IM messages
- Features:
  - Shows notifications
  - Handles tap actions
  - Caches conversation information
  - Launches the app and navigates

### 5. defines.dart

- Function: Defines data structures and configuration related to message processing
- Includes:
  - HandlerPrivateInfo: Platform-specific configuration
  - BackgroundMessageHandlerMessage: Message processing class
  - Message type enums and extensions

## Message Processing Flow

### Android Flow

1. Background silent notification triggers `onBackgroundMessageReceived`
2. Check whether the app is running to decide whether to use an isolate
3. Parse the message type
4. Dispatch to the corresponding handler

### iOS Flow

1. VoIP push triggers `onIncomingPushReceived`
2. Check the message type (IM message vs. call invitation)
3. Dispatch to the corresponding handler
4. Preserve the original CallKit logic

## Supported Message Types

| Type              | Android | iOS | Description                                           |
| ----------------- | ------- | --- | ----------------------------------------------------- |
| invitation        | ✅      | ✅  | Call invitation                                       |
| text_message      | ✅      | ✅  | Text message (Android: text_message, iOS: text_msg)   |
| media_message     | ✅      | ✅  | Media message (Android: media_message, iOS: media_msg) |
| cancel_invitation | ✅      | ✅  | Cancel invitation                                     |

## Configuration Management

### Android Configuration

- `androidCallChannelID`: Call notification channel ID
- `androidMessageChannelID`: IM message notification channel ID
- `androidCallIcon/Sound/Vibrate`: Call notification settings
- `androidMessageIcon/Sound/Vibrate`: IM message notification settings

### iOS Configuration

- `iosCallChannelID`: Call notification channel ID
- `iosMessageChannelID`: IM message notification channel ID
- `iosCallIcon/Sound/Vibrate`: Call notification settings
- `iosMessageIcon/Sound/Vibrate`: IM message notification settings

## Design Principles

1. Consistency: Android and iOS share the same file structure and processing logic
2. Separation: Platform-specific code is fully isolated for maintainability
3. Extensibility: Easy to add new message types and handlers
4. Compatibility: Fully compatible with existing functionality

## Message Structure Differences

### Android Message Structure

```dart
extras: {
  'body': 'Message content',
  'title': 'Message title',
  'payload': '{"operation_type":"text_message",...}',
  'zego': {...}
}
```

### iOS Message Structure

```dart
extras: {
  'aps': {
    'alert': {
      'title': 'Message title',
      'body': 'Message content'
    }
  },
  'payload': '{"operation_type":"text_msg",...}',
  'zego': {...}
}
```

### Key Differences

1. Message content location: On Android directly under `extras`; on iOS under `extras['aps']['alert']` 