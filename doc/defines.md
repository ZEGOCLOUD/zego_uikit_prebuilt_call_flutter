# Defines

- [ZegoCallEndReason](#zegocallendreason)
- [ZegoCallEndEvent](#zegocallendevent)
- [ZegoCallHangUpConfirmationEvent](#zegocallhangupconfirmationevent)
- [ZegoCallInvitationData](#zegocallinvitationdata)
- [ZegoUIKitPrebuiltCallInvitationData](#zegouikitprebuiltcallinvitationdata)
- [ZegoCallInvitationType](#zegocallinvitationtype)
- [ZegoCallUser](#zegocalluser)
- [ZegoCallUserEvents](#zegocalluserevents)
- [ZegoCallRoomEvents](#zegocallroomevents)
- [ZegoCallAudioVideoEvents](#zegocallaudiovideoevents)
- [ZegoCallBeautyEvents](#zegocallbeautyevents)
- [ZegoCallPrebuiltConfigQuery](#zegocallprebuiltconfigquery)
- [ZegoCallInvitationPermission](#zegocallinvitationpermission)
- [ZegoCallMiniOverlayPageState](#zegocallminioverlaypagestate)
- [ZegoCallMenuBarButtonName](#zegocallmenubarbuttonname)
- [ZegoMinimizeType](#zegominimizetype)
- [ZegoInCallMinimizeData](#zegoincallminimizedata)
- [ZegoInvitingMinimizeData](#zegoinvitingminimizedata)
- [ZegoCallMinimizeData](#zegocallminimizedata)
- [ZegoCallConfirmDialogInfo](#zegocallconfirmdialoginfo)
- [ZegoCallHangUpConfirmDialogInfo](#zegocallhangupconfirmdialoginfo)
- [ZegoCallAudioVideoContainerBuilder](#zegocallaudiovideocontainerbuilder)
- [ZegoCallingBuilderInfo](#zegocallingbuilderinfo)
- [ZegoCallingBackgroundBuilder](#zegocallingbackgroundbuilder)
- [ZegoCallingForegroundBuilder](#zegocallingforegroundbuilder)
- [ZegoCallingPageBuilder](#zegocallingpagebuilder)
- [ZegoCallInvitationNotifyDialogBuilder](#zegocallinvitationnotifydialogbuilder)
- [ZegoCallInvitationPermissions](#zegocallinvitationpermissions)
- [ZegoCallSystemConfirmDialogInfo](#zegocallsystemconfirmdialoginfo)

---

## ZegoCallMenuBarButtonName

Enum for buttons that can be added to the top or bottom toolbar.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **toggleCameraButton** | Button for controlling the camera switch. |
| **toggleMicrophoneButton** | Button for controlling the microphone switch. |
| **hangUpButton** | Button for hanging up the current call. |
| **switchCameraButton** | Button for switching between front and rear cameras. |
| **switchAudioOutputButton** | Button for switching audio output. |
| **showMemberListButton** | Button for controlling the visibility of the member list. |
| **toggleScreenSharingButton** | Button for toggling screen sharing. |
| **minimizingButton** | Button for minimizing the current call widget. |
| **pipButton** | Button for PIP the current call widget. |
| **beautyEffectButton** | Button for controlling the display of the beauty effect adjustment panel. |
| **chatButton** | Button to open/hide the chat UI. |
| **soundEffectButton** | Button for controlling the display of the sound effect adjustment panel. |

---

## ZegoCallInvitationType

Enum for call invitation type.

| Name | Description | Value |
- **Enum Values**
| :--- | :--- | :--- |
| **voiceCall** | Voice call. | `0` |
| **videoCall** | Video call. | `1` |

---

## ZegoCallMiniOverlayPageState

Enum for overlay window state.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **idle** | Idle state. |
| **inCall** | In prebuilt call page. |
| **inCallMinimized** | In-call minimized. |
| **invitingMinimized** | Inviting minimized. |

---

## ZegoCallEndReason

Enum for call end reason.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **localHangUp** | The call ended due to a local hang-up. |
| **remoteHangUp** | The call ended when the remote user hung up, leaving only one local user in the call. |
| **kickOut** | The call ended due to being kicked out. |
| **abandoned** | The call is automatically hung up by local. |

---

## ZegoCallEndEvent

Event for call end.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **callID** | Current call id. | `String` |
| **kickerUserID** | The user ID of who kick you out. | `String?` |
| **reason** | End reason. | `ZegoCallEndReason` |
| **isFromMinimizing** | Whether it means that the user left the call while it was in a minimized state. | `bool` |
| **invitationData** | Invitation data if current call is from invitation. | `ZegoCallInvitationData?` |

---

## ZegoCallHangUpConfirmationEvent

Event for hang up confirmation.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **context** | Build context. | `BuildContext` |

---

## ZegoCallInvitationData

Data for call invitation.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **callID** | Call ID. | `String` |
| **invitationID** | Invitation ID. | `String` |
| **type** | Invitation type. | `ZegoCallInvitationType` |
| **invitees** | List of invitees. | `List<ZegoUIKitUser>` |
| **inviter** | Inviter user. | `ZegoUIKitUser?` |
| **timeoutSeconds** | Timeout in seconds. | `int` |
| **customData** | Custom data. | `String` |

---

## ZegoCallUser

User in call.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **id** | User ID. | `String` |
| **name** | User name. | `String` |

---

## ZegoCallUserEvents

Events about user.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **onEnter** | This callback is triggered when user enter. | `void Function(ZegoUIKitUser)?` |
| **onLeave** | This callback is triggered when user leave. | `void Function(ZegoUIKitUser)?` |

---

## ZegoCallRoomEvents

Events about room.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **onStateChanged** | This callback is triggered when room state changed. | `void Function(ZegoUIKitRoomState)?` |
| **onTokenExpired** | The room Token authentication is about to expire. | `String? Function(int remainSeconds)?` |

---

## ZegoCallAudioVideoEvents

Events about audio-video.

| Name | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **onCameraStateChanged** | This callback is triggered when camera state changed. | `void Function(bool)?` |
| **onFrontFacingCameraStateChanged** | This callback is triggered when front camera state changed. | `void Function(bool)?` |
| **onMicrophoneStateChanged** | This callback is triggered when microphone state changed. | `void Function(bool)?` |
| **onAudioOutputChanged** | This callback is triggered when audio output device changed. | `void Function(ZegoUIKitAudioRoute)?` |
| **onLocalCameraExceptionOccurred** | Local camera device exceptions. | `void Function(ZegoUIKitDeviceExceptionType?)?` |
| **onLocalMicrophoneExceptionOccurred** | Local microphone device exceptions. | `void Function(ZegoUIKitDeviceExceptionType?)?` |
| **onRemoteCameraExceptionOccurred** | Remote camera device exceptions. | `void Function(ZegoUIKitUser, ZegoUIKitDeviceException?)?` |
| **onRemoteMicrophoneExceptionOccurred** | Remote microphone device exceptions. | `void Function(ZegoUIKitUser, ZegoUIKitDeviceException?)?` |

---

## ZegoCallBeautyEvents

Events about beauty.

- **Properties**

| Name | Description | Type |
| :--- | :--- | :--- |
| **onError** | Error callback for beauty effect-related errors. | `Function(ZegoBeautyError)?` |
| **onFaceDetection** | Callback triggered when face detection data is available. | `Function(ZegoBeautyPluginFaceDetectionData)?` |

---

## ZegoCallPrebuiltConfigQuery

Typedef for config query.

- **Prototype**

```dart
typedef ZegoCallPrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
  ZegoCallInvitationData,
);
```

---

## ZegoCallInvitationPermission

Enum for call invitation permissions.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **camera** | Camera permission. |
| **microphone** | Microphone permission. |
| **systemAlertWindow** | System alert window permission. Not using it will cause full-screen pop-ups to fail to appear on the lock screen. |
| **manuallyByUser** | Some permissions cannot be obtained directly and must be set manually by the user. |

---

## ZegoMinimizeType

Enum for minimize type.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **none** | Not minimized. |
| **inCall** | In-call minimized. |
| **inviting** | Inviting minimized. |

---

## ZegoInCallMinimizeData

Data for in-call minimized state.

| Property | Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **config** | `ZegoUIKitPrebuiltCallConfig` | Call configuration. |
| **events** | `ZegoUIKitPrebuiltCallEvents` | Call events. |
| **isPrebuiltFromMinimizing** | `bool` | Whether prebuilt is from minimizing. |
| **plugins** | `List<IZegoUIKitPlugin>?` | Plugins list. |
| **durationStartTime** | `DateTime` | Call duration start time. |

---

## ZegoInvitingMinimizeData

Data for inviting minimized state.

| Property | Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **invitationType** | `ZegoCallInvitationType` | Invitation type. |
| **inviter** | `ZegoUIKitUser` | Inviter user. |
| **invitees** | `List<ZegoUIKitUser>` | List of invitees. |
| **isInviter** | `bool` | Whether current user is inviter. |
| **pageManager** | `ZegoCallInvitationPageManager` | Invitation page manager. |
| **callInvitationData** | `ZegoUIKitPrebuiltCallInvitationData` | Invitation data. |
| **customData** | `String?` | Custom data. |

---

## ZegoCallMinimizeData

Minimized data container using union type pattern.

### Factory Constructors

#### ZegoCallMinimizeData.inCall

```dart
const ZegoCallMinimizeData.inCall({
  required int appID,
  required String appSign,
  required String token,
  required String userID,
  required String userName,
  required String callID,
  required VoidCallback? onDispose,
  required ZegoInCallMinimizeData inCallData,
})
```

#### ZegoCallMinimizeData.inviting

```dart
const ZegoCallMinimizeData.inviting({
  required int appID,
  required String appSign,
  required String token,
  required String userID,
  required String userName,
  required String callID,
  required VoidCallback? onDispose,
  required ZegoInvitingMinimizeData invitingData,
})
```

### Properties

| Property | Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **appID** | `int` | Application ID. |
| **appSign** | `String` | Application sign. |
| **token** | `String` | Token. |
| **userID** | `String` | User ID. |
| **userName** | `String` | User name. |
| **callID** | `String` | Call ID. |
| **onDispose** | `VoidCallback?` | Dispose callback. |
| **inCallData** | `ZegoInCallMinimizeData?` | In-call data (union type). |
| **invitingData** | `ZegoInvitingMinimizeData?` | Inviting data (union type). |

### Methods

| Method | Return Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **get type** | `ZegoMinimizeType` | Get minimization type. |
| **get isInCall** | `bool` | Check if in-call minimized. |
| **get isInviting** | `bool` | Check if inviting minimized. |
| **get inCall** | `ZegoInCallMinimizeData?` | Get in-call data. |
| **get inviting** | `ZegoInvitingMinimizeData?` | Get inviting data. |

---

## ZegoCallConfirmDialogInfo

Base class for confirmation dialog info.

| Property | Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **title** | `String` | Dialog title. |
| **message** | `String` | Dialog message content. |
| **cancelButtonName** | `String` | Cancel button text. Default is 'Cancel'. |
| **confirmButtonName** | `String` | Confirm button text. Default is 'OK'. |

---

## ZegoCallHangUpConfirmDialogInfo

Dialog info for hang up confirmation.

| Property | Type | Description |
- **Properties**
| :--- | :--- | :--- |
| **title** | `String` | Dialog title. Default is 'Hangup Confirmation'. |
| **message** | `String` | Dialog message content. Default is 'Do you want to hangup?'. |
| **cancelButtonName** | `String` | Cancel button text. |
| **confirmButtonName** | `String` | Confirm button text. |

---

## ZegoCallAudioVideoContainerBuilder

Typedef for custom audio/video container builder.

- **Prototype**

```dart
typedef ZegoCallAudioVideoContainerBuilder = Widget? Function(
  BuildContext context,
  List<ZegoUIKitUser> allUsers,
  List<ZegoUIKitUser> audioVideoUsers,
  ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator,
);
```

---

## ZegoCallingBuilderInfo

Builder info class for invitation calling UI.

| Property | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **inviter** | The user who initiated the call. | `ZegoUIKitUser` |
| **invitees** | List of users being invited. | `List<ZegoUIKitUser>` |
| **callType** | Type of the call invitation. | `ZegoCallInvitationType` |
| **customData** | Custom data passed with the invitation. | `String` |

---

## ZegoCallingBackgroundBuilder

Typedef for custom background builder in invitation calling UI.

- **Prototype**

```dart
typedef ZegoCallingBackgroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);
```

---

## ZegoCallingForegroundBuilder

Typedef for custom foreground builder in invitation calling UI.

- **Prototype**

```dart
typedef ZegoCallingForegroundBuilder = Widget? Function(
  BuildContext context,
  Size size,
  ZegoCallingBuilderInfo info,
);
```

---

## ZegoCallingPageBuilder

Typedef for custom page builder in invitation calling UI.

- **Prototype**

```dart
typedef ZegoCallingPageBuilder = Widget? Function(
  BuildContext context,
  ZegoCallingBuilderInfo info,
);
```

---

## ZegoCallInvitationNotifyDialogBuilder

Typedef for custom dialog builder in invitation notification popup.

- **Prototype**

```dart
typedef ZegoCallInvitationNotifyDialogBuilder = Widget Function(
  ZegoCallInvitationData invitationData,
);
```

---

## ZegoCallInvitationPermissions

Helper class for common invitation permission configurations.

| Property | Description | Type |
- **Properties**
| :--- | :--- | :--- |
| **withoutSystemAlertWindow** | Pre-configured list without system alert window permission. | `List<ZegoCallInvitationPermission>` |
| **audio** | Pre-configured list with only microphone permission. | `List<ZegoCallInvitationPermission>` |

---

## ZegoCallSystemConfirmDialogInfo

System confirm dialog info class for permission requests.

| Property | Description | Type | Default Value |
- **Properties**
| :--- | :--- | :--- | :--- |
| **title** | Dialog title. | `String` | - |
| **message** | Dialog message content. | `String` | '' |
| **cancelButtonName** | Cancel button text. | `String` | 'Deny' |
| **confirmButtonName** | Confirm button text. | `String` | 'Allow' |

