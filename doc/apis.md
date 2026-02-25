# APIs

- [ZegoUIKitPrebuiltCallController](#zegouikitprebuiltcallcontroller)
  - [hangUp](#hangup)
- [audioVideo](#audiovideo)
  - [microphone](#microphone)
    - [turnOn](#turnon)
    - [switchState](#switchstate)
    - [localState](#localstate)
    - [state](#state)
  - [camera](#camera)
    - [turnOn](#turnon-1)
    - [switchState](#switchstate-1)
    - [switchFrontFacing](#switchfrontfacing)
    - [switchVideoMirroring](#switchvideomirroring)
  - [audioOutput](#audiooutput)
    - [switchToSpeaker](#switchtospeaker)
- [minimize](#minimize)
  - [minimize](#minimize-1)
  - [state](#state-1)
  - [isMinimizing](#isminimizing)
  - [restore](#restore)
  - [hide](#hide)
  - [minimizeInviting](#minimizeinviting)
  - [restoreInviting](#restoreinviting)
- [pip](#pip)
  - [status](#status)
  - [available](#available)
  - [enable](#enable)
  - [enableWhenBackground](#enablewhenbackground)
  - [cancelBackground](#cancelbackground)
- [room](#room)
  - [renewToken](#renewtoken)
- [screenSharing](#screensharing)
  - [showViewInFullscreenMode](#showviewinfullscreenmode)
  - [viewController](#viewcontroller)
- [user](#user)
  - [remove](#remove)
  - [stream](#stream)
- [log](#log)
  - [exportLogs](#exportlogs)

---

## ZegoUIKitPrebuiltCallController

Used to control the call functionality. `ZegoUIKitPrebuiltCallController` is a **singleton instance** class.

### hangUp

- **Description**

  End the current call. If you want hangUp in minimize state, please call `minimize.hangUp`

- **Prototype**

  ```dart
    Future<bool> hangUp(
      BuildContext context, {
      bool showConfirmation = false,
      ZegoCallEndReason reason = ZegoCallEndReason.localHangUp,
    })
  ```

- **Parameters**
  | Name             | Description                                                                                     | Type                  | Default Value                     |
  | :--------------- | :---------------------------------------------------------------------------------------------- | :-------------------- | :-------------------------------- |
  | context          | The context for any necessary pop-ups or page transitions.                                                  | `BuildContext`      | `Optional`                      |
  | showConfirmation | parameter, you can control whether to display a confirmation dialog to confirm ending the call. | `bool`              | `false`                         |
  | reason           | The reason for ending the call.                                                                 | `ZegoCallEndReason` | `ZegoCallEndReason.localHangUp` |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().hangUp(context);
```

---

## audioVideo

APIs related to audio and video.

### microphone

Microphone controller - control microphone switch and state query.

#### turnOn

- **Description**

  Turn on/off microphone.

- **Prototype**

```dart
  Future<void> turnOn(bool isOn, {String? userID})
```

- **Parameters**
  | Name   | Description                                                                   | Type        | Default Value |
  | :----- | :---------------------------------------------------------------------------- | :---------- | :------------ |
  | isOn   | Whether to turn the camera on or off.                                         | `bool`    | `Optional`  |
  | userID | The ID of the user whose camera to control. If null, controls the local user. | `String?` | `Optional`  |
- **Example**

```dart
  // Turn on local microphone
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.turnOn(true);

  // Turn off remote user's microphone
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.turnOn(false, userID: 'remote_user_id');
```

#### switchState

- **Description**

  Switch microphone state (toggle).

- **Prototype**

```dart
  void switchState({String? userID})
```

- **Parameters**
  | Name   | Description                                                                           | Type        | Default Value |
  | :----- | :------------------------------------------------------------------------------------ | :---------- | :------------ |
  | userID | The ID of the user whose camera to switch. If null, switches the local user's camera. | `String?` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.switchState();
```

#### localState

- **Description**

  Get microphone state of local user.

- **Prototype**

```dart
  bool get localState
```

#### state

- **Description**

  Get microphone state of a specific user.

- **Prototype**

```dart
  bool state(String userID)
```

- **Parameters**
  | Name   | Description                                       | Type       | Default Value |
  | :----- | :------------------------------------------------ | :--------- | :------------ |
  | userID | The ID of the user whose camera state to retrieve | `String` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.state('remote_user_id');
```

- **Parameters**
  | Name   | Description                                       | Type       | Default Value |
  | :----- | :------------------------------------------------ | :--------- | :------------ |
  | userID | The ID of the user whose camera state to retrieve | `String` | `Optional`  |

### camera

Camera controller - control camera switch, front/back switching, mirroring, etc.

#### turnOn

- **Description**

  Turn on/off camera.

- **Prototype**

```dart
  Future<void> turnOn(bool isOn, {String? userID})
```

- **Parameters**
  | Name   | Description                                                                   | Type        | Default Value |
  | :----- | :---------------------------------------------------------------------------- | :---------- | :------------ |
  | isOn   | Whether to turn the camera on or off.                                         | `bool`    | `Optional`  |
  | userID | The ID of the user whose camera to control. If null, controls the local user. | `String?` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.turnOn(true);
```

#### switchState

- **Description**

  Switch camera state (toggle).

- **Prototype**

```dart
  void switchState({String? userID})
```

- **Parameters**
  | Name   | Description                                                                           | Type        | Default Value |
  | :----- | :------------------------------------------------------------------------------------ | :---------- | :------------ |
  | userID | The ID of the user whose camera to switch. If null, switches the local user's camera. | `String?` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchState();
```

#### switchFrontFacing

- **Description**

  Switch local camera between front and back.

- **Prototype**

```dart
  void switchFrontFacing(bool isFrontFacing)
```

- **Parameters**
  | Name          | Description                             | Type     | Default Value |
  | :------------ | :-------------------------------------- | :------- | :------------ |
  | isFrontFacing | Whether to use the front-facing camera. | `bool` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchFrontFacing(true);
```

#### switchVideoMirroring

- **Description**

  Switch video mirror mode.

- **Prototype**

```dart
  void switchVideoMirroring(bool isVideoMirror)
```

- **Parameters**
  | Name          | Description                        | Type     | Default Value |
  | :------------ | :--------------------------------- | :------- | :------------ |
  | isVideoMirror | Whether to enable video mirroring. | `bool` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchVideoMirroring(true);
```

### audioOutput

Audio output controller.

#### switchToSpeaker

- **Description**

  Set audio output to speaker or earpiece.

- **Prototype**

```dart
  void switchToSpeaker(bool isSpeaker)
```

- **Parameters**
  | Name      | Description                                              | Type     | Default Value |
  | :-------- | :------------------------------------------------------- | :------- | :------------ |
  | isSpeaker | Whether to switch to speaker (true) or earpiece (false). | `bool` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().audioVideo.audioOutput.switchToSpeaker(true);
```

---

## minimize

Minimization controller providing call interface minimization and restoration functionality.

### minimize

- **Description**

  Minimize the ZegoUIKitPrebuiltCall.

- **Prototype**

```dart
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  })
```

- **Parameters**
  | Name          | Description                        | Type             | Default Value |
  | :------------ | :--------------------------------- | :--------------- | :------------ |
  | context       | The build context.                 | `BuildContext` | `Optional`  |
  | rootNavigator | Whether to use the root navigator. | `bool`         | `true`      |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().minimize.minimize(context);
```

### state

- **Description**

  Get current minimization state.

- **Prototype**

```dart
  ZegoCallMiniOverlayPageState get state
```

- **Example**

```dart
  ZegoUIKitPrebuiltCallController().minimize.state;
```

### isMinimizing

- **Description**

  Check if it is currently in the minimized state.

- **Prototype**

```dart
  bool get isMinimizing
```

- **Example**

```dart
  ZegoUIKitPrebuiltCallController().minimize.isMinimizing;
```

### restore

- **Description**

  Restore the ZegoUIKitPrebuiltCall from minimize.

- **Prototype**

```dart
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  })
```

- **Parameters**
  | Name          | Description                        | Type             | Default Value |
  | :------------ | :--------------------------------- | :--------------- | :------------ |
  | context       | The build context.                 | `BuildContext` | `Optional`  |
  | rootNavigator | Whether to use the root navigator. | `bool`         | `true`      |
  | withSafeArea  | Whether to wrap with SafeArea.     | `bool`         | `false`     |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().minimize.restore(context);
```

### hide

- **Description**

  Hide the minimize widget (if call ended in minimizing state).

- **Prototype**

```dart
  void hide()
```

- **Example**

```dart
  ZegoUIKitPrebuiltCallController().minimize.hide();
```

### minimizeInviting

- **Description**

  Minimize the inviting interface.

- **Prototype**

```dart
  bool minimizeInviting(
    BuildContext context, {
    bool rootNavigator = true,
    required ZegoCallInvitationType invitationType,
    required ZegoUIKitUser inviter,
    required List<ZegoUIKitUser> invitees,
    required bool isInviter,
    required ZegoCallInvitationPageManager pageManager,
    required ZegoUIKitPrebuiltCallInvitationData callInvitationData,
    String? customData,
  })
```

- **Parameters**
  | Name               | Description                                   | Type                                    | Default Value |
  | :----------------- | :-------------------------------------------- | :-------------------------------------- | :------------ |
  | context            | The build context.                            | `BuildContext`                        | `Optional`  |
  | rootNavigator      | Whether to use the root navigator.            | `bool`                                | `true`      |
  | invitationType     | The type of invitation (video or voice).      | `ZegoCallInvitationType`              | `Required`  |
  | inviter            | The user who initiated the invitation.        | `ZegoUIKitUser`                       | `Required`  |
  | invitees           | The list of users being invited.              | `List<ZegoUIKitUser>`                 | `Required`  |
  | isInviter          | Whether the current user is the inviter.      | `bool`                                | `Required`  |
  | pageManager        | The invitation page manager.                  | `ZegoCallInvitationPageManager`       | `Required`  |
  | callInvitationData | The call invitation data.                     | `ZegoUIKitPrebuiltCallInvitationData` | `Required`  |
  | customData         | Custom data to be passed with the invitation. | `String?`                             | `Optional`  |
- **Example**

```dart
  // Example usage in invitation callback
  ZegoUIKitPrebuiltCallController().minimize.minimizeInviting(
    context,
    invitationType: ZegoCallInvitationType.videoCall,
    inviter: caller,
    invitees: callees,
    isInviter: true,
    pageManager: pageManager,
    callInvitationData: invitationData,
  );
```

### restoreInviting

- **Description**

  Restore the inviting interface.

- **Prototype**

```dart
  bool restoreInviting(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  })
```

- **Parameters**
  | Name          | Description                       | Type             | Default Value |
  | :------------ | :-------------------------------- | :--------------- | :------------ |
  | context       | The build context                 | `BuildContext` | `Optional`  |
  | rootNavigator | Whether to use the root navigator | `bool`         | `true`      |
  | withSafeArea  | Whether to wrap with SafeArea     | `bool`         | `false`     |

---

## pip

Picture-in-Picture (PIP) controller for enabling and disabling PIP functionality.

### status

- **Description**

  Get current PIP status.

- **Prototype**

```dart
  Future<ZegoPiPStatus> get status
```

- **Example**

```dart
  final status = await ZegoUIKitPrebuiltCallController().pip.status;
```

### available

- **Description**

  Check if PIP is available.

- **Prototype**

```dart
  Future<bool> get available
```

- **Example**

```dart
  final isAvailable = await ZegoUIKitPrebuiltCallController().pip.available;
```

### enable

- **Description**

  Enable PIP mode.

- **Prototype**

```dart
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  })
```

- **Parameters**
  | Name         | Description                                          | Type    | Default Value |
  | :----------- | :--------------------------------------------------- | :------ | :------------ |
  | aspectWidth  | The width of the aspect ratio for PIP (default 9).   | `int` | `9`         |
  | aspectHeight | The height of the aspect ratio for PIP (default 16). | `int` | `16`        |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().pip.enable();
```

### enableWhenBackground

- **Description**

  Enable PIP mode when app goes to background.

- **Prototype**

```dart
  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  })
```

- **Parameters**
  | Name         | Description                                          | Type    | Default Value |
  | :----------- | :--------------------------------------------------- | :------ | :------------ |
  | aspectWidth  | The width of the aspect ratio for PIP (default 9).   | `int` | `9`         |
  | aspectHeight | The height of the aspect ratio for PIP (default 16). | `int` | `16`        |
- **Example**

```dart
  await ZegoUIKitPrebuiltCallController().pip.enableWhenBackground();
```

### cancelBackground

- **Description**

  Cancel background PIP mode.

- **Prototype**

```dart
  Future<void> cancelBackground()
```

---

## room

Room controller managing room-related operations.

### renewToken

- **Description**

  Renew the token. Call when receiving the onTokenExpired callback.

- **Prototype**

```dart
  Future<void> renewToken(String token)
```

- **Parameters**
  | Name  | Description                             | Type       | Default Value |
  | :---- | :-------------------------------------- | :--------- | :------------ |
  | token | The new token to use for authentication | `String` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().room.renewToken('new_token');
```

- **Parameters**
  | Name  | Description                             | Type       | Default Value |
  | :---- | :-------------------------------------- | :--------- | :------------ |
  | token | The new token to use for authentication | `String` | `Optional`  |

---

## screenSharing

Screen sharing controller.

### showViewInFullscreenMode

- **Description**

  Set fullscreen display mode for screen sharing.

- **Prototype**

```dart
  void showViewInFullscreenMode(String userID, bool isFullscreen)
```

- **Parameters**
  | Name         | Description                                               | Type       | Default Value |
  | :----------- | :-------------------------------------------------------- | :--------- | :------------ |
  | userID       | The ID of the user whose view to show in fullscreen mode. | `String` | `Optional`  |
  | isFullscreen | Whether to show the view in fullscreen mode.              | `bool`   | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().screenSharing.showViewInFullscreenMode('user_id', true);
```

### viewController

- **Description**

  Get screen sharing view controller.

- **Prototype**

```dart
  ZegoScreenSharingViewController get viewController
```

---

## user

User controller.

### remove

- **Description**

  Remove user from call (kick out).

- **Prototype**

```dart
  Future<bool> remove(List<String> userIDs)
```

- **Parameters**
  | Name    | Description                                  | Type             | Default Value |
  | :------ | :------------------------------------------- | :--------------- | :------------ |
  | userIDs | The list of user IDs to remove from the call | `List<String>` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().user.remove(['user_id_1']);
```

- **Parameters**
  | Name    | Description                                  | Type             | Default Value |
  | :------ | :------------------------------------------- | :--------------- | :------------ |
  | userIDs | The list of user IDs to remove from the call | `List<String>` | `Optional`  |

### stream

- **Description**

  Get user list stream notifier.

- **Prototype**

```dart
  Stream<List<ZegoUIKitUser>> get stream
```

---

## log

Log controller for exporting and collecting call-related logs.

### exportLogs

- **Description**

  Export log files.

- **Prototype**

```dart
  Future<bool> exportLogs({
    String? title,
    String? content,
    String? fileName,
    List<ZegoLogExporterFileType> fileTypes = const [
      ZegoLogExporterFileType.txt,
      ZegoLogExporterFileType.log,
      ZegoLogExporterFileType.zip
    ],
    List<ZegoLogExporterDirectoryType> directories = const [
      ZegoLogExporterDirectoryType.zegoUIKits,
      ZegoLogExporterDirectoryType.zimAudioLog,
      ZegoLogExporterDirectoryType.zimLogs,
      ZegoLogExporterDirectoryType.zefLogs,
      ZegoLogExporterDirectoryType.zegoLogs,
    ],
    void Function(double progress)? onProgress,
  })
```

- **Parameters**
  | Name        | Description                                                       | Type                                   | Default Value |
  | :---------- | :---------------------------------------------------------------- | :------------------------------------- | :------------ |
  | title       | export title, defaults to current timestamp                       | `String?`                            | `Optional`  |
  | content     | export content description                                        | `String?`                            | `Optional`  |
  | fileName    | Zip file name (without extension), defaults to current timestamp  | `String?`                            | `Optional`  |
  | fileTypes   | List of file types to collect, defaults to                        | `List<ZegoLogExporterFileType>`      | `const [`   |
  | directories | List of directory types to collect, defaults to 5 log directories | `List<ZegoLogExporterDirectoryType>` | `const [`   |
  | Function    | Callback function to report export progress (0.0 to 1.0).           | `void Function(double progress)?` | `Optional`  |
- **Example**

```dart
  ZegoUIKitPrebuiltCallController().log.exportLogs();
```
