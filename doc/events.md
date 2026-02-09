# Events

- [ZegoUIKitPrebuiltCallEvents](#zegouikitprebuiltcallevents)
  - [onCallEnd](#oncallend)
  - [onHangUpConfirmation](#onhangupconfirmation)
  - [onError](#onerror)
- [ZegoCallUserEvents](#zegocalluserevents)
  - [onEnter](#onenter)
  - [onLeave](#onleave)
- [ZegoCallRoomEvents](#zegocallroomevents)
  - [onStateChanged](#onstatechanged)
  - [onTokenExpired](#ontokenexpired)
- [ZegoCallAudioVideoEvents](#zegocallaudiovideoevents)
  - [onCameraStateChanged](#oncamerastatechanged)
  - [onFrontFacingCameraStateChanged](#onfrontfacingcamerastatechanged)
  - [onMicrophoneStateChanged](#onmicrophonestatechanged)
  - [onAudioOutputChanged](#onaudiooutputchanged)
  - [onLocalCameraExceptionOccurred](#onlocalcameraexceptionoccurred)
  - [onLocalMicrophoneExceptionOccurred](#onlocalmicrophoneexceptionoccurred)
  - [onRemoteCameraExceptionOccurred](#onremotecameraexceptionoccurred)
  - [onRemoteMicrophoneExceptionOccurred](#onremotemicrophoneexceptionoccurred)
- [ZegoCallBeautyEvents](#zegocallbeautyevents)
  - [onError](#onerror-1)
  - [onFaceDetection](#onfacedetection)

---

## ZegoUIKitPrebuiltCallEvents

Events for the Call. This class is used as the `events` parameter for the constructor of `ZegoUIKitPrebuiltCall`.

### onCallEnd

- **Description**
  - This callback is triggered when call end, you can differentiate the reasons for call end by using the `event.reason`.
- **Prototype**
  - `void Function(ZegoCallEndEvent event, VoidCallback defaultAction)?`
- **Example**
  ```dart
  onCallEnd: (ZegoCallEndEvent event, VoidCallback defaultAction) {
    debugPrint('onCallEnd, do something...');
    defaultAction.call();
  }
  ```

### onHangUpConfirmation

- **Description**
  - Confirmation callback method before hang up the call.
- **Prototype**
  - `Future<bool> Function(ZegoCallHangUpConfirmationEvent event, Future<bool> Function() defaultAction)?`
- **Example**
  ```dart
  onHangUpConfirmation: (ZegoCallHangUpConfirmationEvent event, Future<bool> Function() defaultAction) async {
    debugPrint('onHangUpConfirmation, do something...');
    return await defaultAction.call();
  }
  ```

### onError

- **Description**
  - Error stream.
- **Prototype**
  - `Function(ZegoUIKitError)?`
- **Example**
  ```dart
  onError: (ZegoUIKitError error) {
    debugPrint('onError: $error');
  }
  ```

## ZegoCallUserEvents

Events about user.

### onEnter

- **Description**
  - This callback is triggered when user enter.
- **Prototype**
  - `void Function(ZegoUIKitUser user)?`
- **Example**
  ```dart
  onEnter: (ZegoUIKitUser user) {
    debugPrint('onEnter: ${user.id}, ${user.name}');
  }
  ```

### onLeave

- **Description**
  - This callback is triggered when user leave.
- **Prototype**
  - `void Function(ZegoUIKitUser user)?`
- **Example**
  ```dart
  onLeave: (ZegoUIKitUser user) {
    debugPrint('onLeave: ${user.id}, ${user.name}');
  }
  ```

## ZegoCallRoomEvents

Events about room.

### onStateChanged

- **Description**
  - This callback is triggered when room state changed.
- **Prototype**
  - `void Function(ZegoUIKitRoomState state)?`
- **Example**
  ```dart
  onStateChanged: (ZegoUIKitRoomState state) {
    debugPrint('onStateChanged: ${state.reason}');
  }
  ```

### onTokenExpired

- **Description**
  - The room Token authentication is about to expire.
- **Prototype**
  - `String? Function(int remainSeconds)?`
- **Example**
  ```dart
  onTokenExpired: (int remainSeconds) {
    debugPrint('onTokenExpired: $remainSeconds');
    return 'token';
  }
  ```

## ZegoCallAudioVideoEvents

Events about audio video.

### onCameraStateChanged

- **Description**
  - This callback is triggered when camera state changed.
- **Prototype**
  - `void Function(bool)?`
- **Example**
  ```dart
  onCameraStateChanged: (bool isOpened) {
    debugPrint('onCameraStateChanged: $isOpened');
  }
  ```

### onFrontFacingCameraStateChanged

- **Description**
  - This callback is triggered when front camera state changed.
- **Prototype**
  - `void Function(bool)?`
- **Example**
  ```dart
  onFrontFacingCameraStateChanged: (bool isFrontFacing) {
    debugPrint('onFrontFacingCameraStateChanged: $isFrontFacing');
  }
  ```

### onMicrophoneStateChanged

- **Description**
  - This callback is triggered when microphone state changed.
- **Prototype**
  - `void Function(bool)?`
- **Example**
  ```dart
  onMicrophoneStateChanged: (bool isOpened) {
    debugPrint('onMicrophoneStateChanged: $isOpened');
  }
  ```

### onAudioOutputChanged

- **Description**
  - This callback is triggered when audio output device changed.
- **Prototype**
  - `void Function(ZegoUIKitAudioRoute)?`
- **Example**
  ```dart
  onAudioOutputChanged: (ZegoUIKitAudioRoute route) {
    debugPrint('onAudioOutputChanged: $route');
  }
  ```

### onLocalCameraExceptionOccurred

- **Description**
  - Local camera device exceptions.
- **Prototype**
  - `void Function(ZegoUIKitDeviceExceptionType?)?`
- **Example**
  ```dart
  onLocalCameraExceptionOccurred: (ZegoUIKitDeviceExceptionType? exception) {
    debugPrint('onLocalCameraExceptionOccurred: $exception');
  }
  ```

### onLocalMicrophoneExceptionOccurred

- **Description**
  - Local microphone device exceptions.
- **Prototype**
  - `void Function(ZegoUIKitDeviceExceptionType?)?`
- **Example**
  ```dart
  onLocalMicrophoneExceptionOccurred: (ZegoUIKitDeviceExceptionType? exception) {
    debugPrint('onLocalMicrophoneExceptionOccurred: $exception');
  }
  ```

### onRemoteCameraExceptionOccurred

- **Description**
  - Remote camera device exceptions.
- **Prototype**
  - `void Function(ZegoUIKitUser, ZegoUIKitDeviceException?)?`
- **Example**
  ```dart
  onRemoteCameraExceptionOccurred: (ZegoUIKitUser user, ZegoUIKitDeviceException? exception) {
    debugPrint('onRemoteCameraExceptionOccurred: ${user.id}, $exception');
  }
  ```

### onRemoteMicrophoneExceptionOccurred

- **Description**
  - Remote microphone device exceptions.
- **Prototype**
  - `void Function(ZegoUIKitUser, ZegoUIKitDeviceException?)?`
- **Example**
  ```dart
  onRemoteMicrophoneExceptionOccurred: (ZegoUIKitUser user, ZegoUIKitDeviceException? exception) {
    debugPrint('onRemoteMicrophoneExceptionOccurred: ${user.id}, $exception');
  }
  ```

## ZegoCallBeautyEvents

Events about beauty.

### onError

- **Description**
  - Error stream.
- **Prototype**
  - `Function(ZegoBeautyError)?`
- **Example**
  ```dart
  onError: (ZegoBeautyError error) {
    debugPrint('onError: $error');
  }
  ```

### onFaceDetection

- **Description**
  - Face detection result callback.
- **Prototype**
  - `Function(ZegoBeautyPluginFaceDetectionData)?`
- **Example**
  ```dart
  onFaceDetection: (ZegoBeautyPluginFaceDetectionData data) {
    debugPrint('onFaceDetection: $data');
  }
  ```
