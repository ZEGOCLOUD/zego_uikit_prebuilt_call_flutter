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

- **Function Action**
  - End the current call.

- **Function Prototype**
  ```dart
  Future<bool> hangUp(
    BuildContext context, {
    bool showConfirmation = false,
    ZegoCallEndReason reason = ZegoCallEndReason.localHangUp,
  })
  ```

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

- **Function Action**
  - Turn on/off microphone.

- **Function Prototype**
  ```dart
  Future<void> turnOn(bool isOn, {String? userID})
  ```

- **Example**
  ```dart
  // Turn on local microphone
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.turnOn(true);

  // Turn off remote user's microphone
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.turnOn(false, userID: 'remote_user_id');
  ```

#### switchState

- **Function Action**
  - Switch microphone state (toggle).

- **Function Prototype**
  ```dart
  void switchState({String? userID})
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.microphone.switchState();
  ```

#### localState

- **Function Action**
  - Get microphone state of local user.

- **Function Prototype**
  ```dart
  bool get localState
  ```

#### state

- **Function Action**
  - Get microphone state of a specific user.

- **Function Prototype**
  ```dart
  bool state(String userID)
  ```

### camera

Camera controller - control camera switch, front/back switching, mirroring, etc.

#### turnOn

- **Function Action**
  - Turn on/off camera.

- **Function Prototype**
  ```dart
  Future<void> turnOn(bool isOn, {String? userID})
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.turnOn(true);
  ```

#### switchState

- **Function Action**
  - Switch camera state (toggle).

- **Function Prototype**
  ```dart
  void switchState({String? userID})
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchState();
  ```

#### switchFrontFacing

- **Function Action**
  - Switch local camera between front and back.

- **Function Prototype**
  ```dart
  void switchFrontFacing(bool isFrontFacing)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchFrontFacing(true);
  ```

#### switchVideoMirroring

- **Function Action**
  - Switch video mirror mode.

- **Function Prototype**
  ```dart
  void switchVideoMirroring(bool isVideoMirror)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.camera.switchVideoMirroring(true);
  ```

### audioOutput

Audio output controller.

#### switchToSpeaker

- **Function Action**
  - Set audio output to speaker or earpiece.

- **Function Prototype**
  ```dart
  void switchToSpeaker(bool isSpeaker)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().audioVideo.audioOutput.switchToSpeaker(true);
  ```

---

## minimize

Minimization controller providing call interface minimization and restoration functionality.

### minimize

- **Function Action**
  - Minimize the ZegoUIKitPrebuiltCall.

- **Function Prototype**
  ```dart
  bool minimize(
    BuildContext context, {
    bool rootNavigator = true,
  })
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().minimize.minimize(context);
  ```

### state

- **Function Action**
  - Get current minimization state.

- **Function Prototype**
  ```dart
  ZegoCallMiniOverlayPageState get state
  ```

### isMinimizing

- **Function Action**
  - Check if it is currently in the minimized state.

- **Function Prototype**
  ```dart
  bool get isMinimizing
  ```

### restore

- **Function Action**
  - Restore the ZegoUIKitPrebuiltCall from minimize.

- **Function Prototype**
  ```dart
  bool restore(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  })
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().minimize.restore(context);
  ```

### hide

- **Function Action**
  - Hide the minimize widget (if call ended in minimizing state).

- **Function Prototype**
  ```dart
  void hide()
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().minimize.hide();
  ```

### minimizeInviting

- **Function Action**
  - Minimize the inviting interface.

- **Function Prototype**
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

### restoreInviting

- **Function Action**
  - Restore the inviting interface.

- **Function Prototype**
  ```dart
  bool restoreInviting(
    BuildContext context, {
    bool rootNavigator = true,
    bool withSafeArea = false,
  })
  ```

---

## pip

Picture-in-Picture (PIP) controller for enabling and disabling PIP functionality.

### status

- **Function Action**
  - Get current PIP status.

- **Function Prototype**
  ```dart
  Future<ZegoPiPStatus> get status
  ```

### available

- **Function Action**
  - Check if PIP is available.

- **Function Prototype**
  ```dart
  Future<bool> get available
  ```

### enable

- **Function Action**
  - Enable PIP mode.

- **Function Prototype**
  ```dart
  Future<ZegoPiPStatus> enable({
    int aspectWidth = 9,
    int aspectHeight = 16,
  })
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().pip.enable();
  ```

### enableWhenBackground

- **Function Action**
  - Enable PIP mode when app goes to background.

- **Function Prototype**
  ```dart
  Future<ZegoPiPStatus> enableWhenBackground({
    int aspectWidth = 9,
    int aspectHeight = 16,
  })
  ```

### cancelBackground

- **Function Action**
  - Cancel background PIP mode.

- **Function Prototype**
  ```dart
  Future<void> cancelBackground()
  ```

---

## room

Room controller managing room-related operations.

### renewToken

- **Function Action**
  - Renew the token. Call when receiving the onTokenExpired callback.

- **Function Prototype**
  ```dart
  Future<void> renewToken(String token)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().room.renewToken('new_token');
  ```

---

## screenSharing

Screen sharing controller.

### showViewInFullscreenMode

- **Function Action**
  - Set fullscreen display mode for screen sharing.

- **Function Prototype**
  ```dart
  void showViewInFullscreenMode(String userID, bool isFullscreen)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().screenSharing.showViewInFullscreenMode('user_id', true);
  ```

### viewController

- **Function Action**
  - Get screen sharing view controller.

- **Function Prototype**
  ```dart
  ZegoScreenSharingViewController get viewController
  ```

---

## user

User controller.

### remove

- **Function Action**
  - Remove user from call (kick out).

- **Function Prototype**
  ```dart
  Future<bool> remove(List<String> userIDs)
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().user.remove(['user_id_1']);
  ```

### stream

- **Function Action**
  - Get user list stream notifier.

- **Function Prototype**
  ```dart
  Stream<List<ZegoUIKitUser>> get stream
  ```

---

## log

Log controller for exporting and collecting call-related logs.

### exportLogs

- **Function Action**
  - Export log files.

- **Function Prototype**
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

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallController().log.exportLogs();
  ```
