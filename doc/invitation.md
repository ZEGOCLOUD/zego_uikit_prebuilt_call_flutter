# Invitation

- [ZegoUIKitPrebuiltCallInvitationService](#zegouikitprebuiltcallinvitationservice)
  - [init](#init)
  - [uninit](#uninit)
  - [send](#send)
  - [cancel](#cancel)
  - [reject](#reject)
  - [accept](#accept)
  - [enterAcceptedOfflineCall](#enteracceptedofflinecall)
  - [setNavigatorKey](#setnavigatorkey)
  - [useSystemCallingUI](#usesystemcallingui)
- [Configs](#configs)
  - [ZegoCallInvitationConfig](#zegocallinvitationconfig)
  - [ZegoCallInvitationUIConfig](#zegocallinvitationuiconfig)
  - [ZegoCallInvitationInviterUIConfig](#zegocallinvitationinviteruiconfig)
  - [ZegoCallInvitationInviteeUIConfig](#zegocallinvitationinviteeuiconfig)
  - [ZegoCallInvitationNotificationConfig](#zegocallinvitationnotificationconfig)
  - [ZegoCallRingtoneConfig](#zegocallringtoneconfig)
  - [ZegoCallButtonUIConfig](#zegocallbuttonuiconfig)
  - [ZegoCallInvitationNotifyPopUpUIConfig](#zegocallinvitationnotifypopupuiconfig)
  - [ZegoCallSystemConfirmDialogConfig](#zegocallsystemconfirmdialogconfig)
  - [ZegoCallInvitationPermissions](#zegocallinvitationpermissions)
  - [ZegoCallInvitationInnerText](#zegocallinvitationinnertext)
- [Defines](#defines)
  - [ZegoCallInvitationType](#zegocallinvitationtype)
  - [ZegoCallInvitationData](#zegocallinvitationdata)
  - [ZegoCallUser](#zegocalluser)
  - [ZegoCallInvitationPermission](#zegocallinvitationpermission)
  - [ZegoCallInvitationPermissions](#zegocallinvitationpermissions-1)
  - [ZegoCallingBuilderInfo](#zegocallingbuilderinfo)
- [ZegoUIKitPrebuiltCallInvitationEvents](#zegouikitprebuiltcallinvitationevents)
  - [onError](#onerror)
  - [onInvitationUserStateChanged](#oninvitationuserstatechanged)
  - [onIncomingCallDeclineButtonPressed](#onincomingcalldeclinebuttonpressed)
  - [onIncomingCallAcceptButtonPressed](#onincomingcallacceptbuttonpressed)
  - [onIncomingCallReceived](#onincomingcallreceived)
  - [onIncomingCallCanceled](#onincomingcallcanceled)
  - [onIncomingCallTimeout](#onincomingcalltimeout)
  - [onIncomingMissedCallClicked](#onincomingmissedcallclicked)
  - [onIncomingMissedCallDialBackFailed](#onincomingmissedcalldialbackfailed)
  - [onOutgoingCallSent](#onoutgoingcallsent)
  - [onOutgoingCallCancelButtonPressed](#onoutgoingcallcancelbuttonpressed)
  - [onOutgoingCallAccepted](#onoutgoingcallaccepted)
  - [onOutgoingCallRejectedCauseBusy](#onoutgoingcallrejectedcausebusy)
  - [onOutgoingCallDeclined](#onoutgoingcalldeclined)
  - [onOutgoingCallTimeout](#onoutgoingcalltimeout)

---

## ZegoUIKitPrebuiltCallInvitationService

Call invitation service singleton class that manages core features including sending, receiving, accepting, and rejecting call invitations.

### init

- **description**
Initialize the service when the user logs in.
Calls can be received and invitations can be sent after this method is called.
- **prototype**

```dart
  Future<void> init({
    required int appID,
    required String userID,
    required String userName,
    required List<IZegoUIKitPlugin> plugins,
    String appSign = '',
    String token = '',
    ZegoCallPrebuiltConfigQuery requireConfig,
    ZegoUIKitPrebuiltCallEvents? events,
    ZegoCallInvitationConfig? config,
    ZegoCallRingtoneConfig? ringtoneConfig,
    ZegoCallInvitationUIConfig? uiConfig,
    ZegoCallInvitationNotificationConfig? notificationConfig,
    ZegoCallInvitationInnerText? innerText,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
  })
```

- **parameters**

  | Name               | Description                                       | Type                                       | Default Value |
  | :----------------- | :------------------------------------------------ | :----------------------------------------- | :------------ |
  | appID              | The App ID of your Zego project                   | `int`                                    | `Required`  |
  | userID             | The ID of the user                                | `String`                                 | `Required`  |
  | userName           | The name of the user                              | `String`                                 | `Required`  |
  | plugins            | The list of plugins to be used. You must include [ZegoUIKitSignalingPlugin] to support the invitation feature.  | `List<IZegoUIKitPlugin>`                 | `Required`  |
  | appSign            | The app sign key for authentication. If [token] is not provided, this sign key will be used for authentication.                          | `String`                                 | ``            |
  | token              | Token for authentication. This is used when [appSign] is not provided or empty.       | `String`                                 | ``            |
  | requireConfig      | Callback to obtain the call config                | `ZegoCallPrebuiltConfigQuery`            | `Optional`  |
  | events             | The events of the call                            | `ZegoUIKitPrebuiltCallEvents?`           | `Optional`  |
  | config             | The configuration of the invitation               | `ZegoCallInvitationConfig?`              | `Optional`  |
  | ringtoneConfig     | The ringtone configuration for call notifications | `ZegoCallRingtoneConfig?`                | `Optional`  |
  | uiConfig           | The UI configuration of the invitation            | `ZegoCallInvitationUIConfig?`            | `Optional`  |
  | notificationConfig | The notification configuration                    | `ZegoCallInvitationNotificationConfig?`  | `Optional`  |
  | innerText          | The inner text configuration for invitation UI    | `ZegoCallInvitationInnerText?`           | `Optional`  |
  | invitationEvents   | The events of the invitation                      | `ZegoUIKitPrebuiltCallInvitationEvents?` | `Optional`  |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: yourAppID,
    appSign: yourAppSign,
    userID: 'userID',
    userName: 'userName',
    plugins: [ZegoUIKitSignalingPlugin()],
  );
  ```

### uninit

- **description**
  Deinitialize the service. Must be called when the user logs out. 
  You must call this method as soon as the user logout from your app
- **prototype**

```dart
  Future<void> uninit()
```

- **example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().uninit();
  ```

### send

- **description**
 Send a call invitation to specified users for an audio or video call.
- **prototype**

```dart
  Future<bool> send({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  })
```

- **parameters**

  | Name                | Description                                                                                                                           | Type                   | Default Value |
  | :------------------ | :------------------------------------------------------------------------------------------------------------------------------------ | :--------------------- | :------------ |
  | invitees            | List of users to send the call invitation to                                                                                          | `List<ZegoCallUser>` | `Required`  |
  | isVideoCall         | Determines whether the call is a video call. If false, it defaults to an audio call                                                   | `bool`               | `Required`  |
  | customData          | Custom data to be passed to the invitees                                                                                              | `String`             | ``            |
  | callID              | The ID of the call. If not provided, the system will generate one automatically                                                       | `String?`            | `Optional`  |
  | resourceID          | The resource ID for offline call notifications. This should match the push resource ID configured in the ZEGOCLOUD management console | `String?`            | `Optional`  |
  | notificationTitle   | The title for the call notification                                                                                                   | `String?`            | `Optional`  |
  | notificationMessage | The message for the call notification                                                                                                 | `String?`            | `Optional`  |
  | timeoutSeconds      | The timeout duration in seconds for the call invitation. Default is 60 seconds                                                        | `int`                | `60`        |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().send(
    invitees: [ZegoCallUser(id: '123', name: 'user')],
    isVideoCall: true,
  );
  ```

### cancel

- **description**
  Cancel a sent call invitation.
- **prototype**

```dart
  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  })
```

- **parameters**

  | Name       | Description                                          | Type                   | Default Value |
  | :--------- | :--------------------------------------------------- | :--------------------- | :------------ |
  | callees    | List of callees whose invitation should be cancelled | `List<ZegoCallUser>` | `Required`  |
  | customData | Custom data to be included with the cancellation     | `String`             | ``            |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().cancel(
    callees: [ZegoCallUser(id: '123', name: 'user')],
  );
  ```


### reject

- **description**
  Reject the received call invitation.
- **prototype**

```dart
  Future<bool> reject({
    String customData = '',
    bool causeByPopScope = false,
  })
```

- **parameters**

  | Name                       | Description                                                          | Type       | Default Value |
  | :------------------------- | :------------------------------------------------------------------- | :--------- | :------------ |
  | customData                 | Custom data to be passed to the caller when rejecting the invitation | `String` | ``            |
  | causeByPopScope | Indicates whether the rejection was caused by a pop scope (e.g., back navigation). When true, the invitation top sheet will not be manually hidden.                                                              | `bool`   | `false`      |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().reject();
  ```

### accept

- **description**
  Accept the received call invitation and enter the call.
- **prototype**

```dart
  Future<bool> accept({
    String customData = '',
  })
```

- **parameters**

  | Name       | Description                                                          | Type       | Default Value |
  | :--------- | :------------------------------------------------------------------- | :--------- | :------------ |
  | customData | Custom data to be passed to the caller when accepting the invitation | `String` | ``            |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().accept();
  ```

### enterAcceptedOfflineCall

- **description**
  Enter an accepted offline call. Suitable for scenarios requiring navigation after data loading completes.

  Due to some time-consuming and waiting operations, such as data loading or user login in the App.
  So in certain situations, it may not be appropriate to navigate to [ZegoUIKitPrebuiltCall] directly when [ZegoUIKitPrebuiltCallInvitationService.init].
  
  This is because the behavior of jumping to ZegoUIKitPrebuiltCall may be **overwritten by some subsequent jump behaviors of the App**.
  Therefore, manually navigate to [ZegoUIKitPrebuiltCall] using the API in App will be a better choice.
  
  SO! please
  1. set [ZegoCallInvitationOfflineConfig.autoEnterAcceptedOfflineCall] to false in  [ZegoUIKitPrebuiltCallInvitationService.init]
  
  2. call [ZegoUIKitPrebuiltCallInvitationService.enterAcceptedOfflineCall] after [ZegoUIKitPrebuiltCallInvitationService.init] done when your app finish loading(data or user login)
- **prototype**

```dart
  void enterAcceptedOfflineCall()
```

- **example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
  ```

### setNavigatorKey

- **description**
  Set the navigation key for necessary configuration when navigating pages upon receiving invitations.
- **prototype**

```dart
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey)
```

- **parameters**

  | Name         | Description                                                                        | Type                          | Default Value |
  | :----------- | :--------------------------------------------------------------------------------- | :---------------------------- | :------------ |
  | navigatorKey | The navigator key to get context for push/pop page when receive invitation request | `GlobalKey<NavigatorState>` | `Optional`  |
- **example**

  ```dart
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ```

### useSystemCallingUI

- **description**
  Enable offline system calling UI to support receiving invitations in the background, answering on lock screen, etc.
 
  Note: If you use CallKit with ZIMKit, this must be called AFTER ZIMKit().init!!!
  Otherwise the offline handler will be caught by zimkit, resulting in callkit unable to receive the offline handler
- **prototype**

```dart
  Future<void> useSystemCallingUI(List<IZegoUIKitPlugin> plugins)
```

- **parameters**

  | Name    | Description                                               | Type                       | Default Value |
  | :------ | :-------------------------------------------------------- | :------------------------- | :------------ |
  | plugins | The list of plugins to be used with the system calling UI | `List<IZegoUIKitPlugin>` | `Optional`  |
- **example**

  ```dart
  await ZIMKit().init(..)
  ...
  ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    [ZegoUIKitSignalingPlugin()],
  );
  ```

## Configs

Configuration classes for call invitation.

### ZegoCallInvitationConfig

Configuration for call invitation (permissions, offline call, in-calling, missed call, pip, etc.).

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **permissions** | Permissions required for call invitation. | `List<ZegoCallInvitationPermission>` | camera, microphone |
| **endCallWhenInitiatorLeave** | Whether to end call when initiator leaves. | `bool` | false |
| **offline** | Offline call configuration. | `ZegoCallInvitationOfflineConfig` | - |
| **inCalling** | In-calling configuration. | `ZegoCallInvitationInCallingConfig` | - |
| **missedCall** | Missed call configuration. | `ZegoCallInvitationMissedCallConfig` | - |
| **systemWindowConfirmDialog** | System window confirmation dialog config. | `ZegoCallSystemConfirmDialogConfig?` | - |
| **pip** | PIP configuration. | `ZegoCallInvitationPIPConfig` | - |
| **networkLoading** | Network loading configuration. | `ZegoNetworkLoadingConfig?` | - |

---

### ZegoCallInvitationUIConfig

Configuration for call invitation UI (caller/callee UI customization).

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **withSafeArea** | Whether to display with SafeArea. | `bool` | true |
| **inviter** | Caller (inviter) UI configuration. | `ZegoCallInvitationInviterUIConfig` | - |
| **invitee** | Callee (invitee) UI configuration. | `ZegoCallInvitationInviteeUIConfig` | - |

---

### ZegoCallInvitationInviterUIConfig

Configuration for caller (inviter) UI in call invitation.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **foregroundBuilder** | Foreground builder function. | `ZegoCallingForegroundBuilder?` | - |
| **pageBuilder** | Custom page builder function. | `ZegoCallingPageBuilder?` | - |
| **backgroundBuilder** | Background builder function. | `ZegoCallingBackgroundBuilder?` | - |
| **cancelButton** | Cancel button configuration. | `ZegoCallButtonUIConfig` | - |
| **cameraButton** | Camera button configuration. | `ZegoCallButtonUIConfig?` | - |
| **cameraSwitchButton** | Camera switch button configuration. | `ZegoCallButtonUIConfig?` | - |
| **microphoneButton** | Microphone button configuration. | `ZegoCallButtonUIConfig?` | - |
| **speakerButton** | Speaker button configuration. | `ZegoCallButtonUIConfig?` | - |
| **defaultCameraOn** | Default camera state when calling. | `bool` | true |
| **defaultMicrophoneOn** | Default microphone state when calling. | `bool` | true |
| **defaultSpeakerOn** | Default speaker state when calling. | `bool` | false |
| **showAvatar** | Whether to show avatar. | `bool` | true |
| **showCentralName** | Whether to show central name. | `bool` | true |
| **showCallingText** | Whether to show calling text. | `bool` | true |
| **useVideoViewAspectFill** | Video view aspect fill mode. | `bool` | false |
| **showMainButtonsText** | Whether to show main buttons text. | `bool` | false |
| **showSubButtonsText** | Whether to show sub buttons text. | `bool` | true |
| **minimized** | Minimized UI configuration. | `ZegoCallInvitationInviterMinimizedUIConfig?` | - |

---

### ZegoCallInvitationInviteeUIConfig

Configuration for callee (invitee) UI in call invitation.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **foregroundBuilder** | Foreground builder function. | `ZegoCallingForegroundBuilder?` | - |
| **pageBuilder** | Custom page builder function. | `ZegoCallingPageBuilder?` | - |
| **backgroundBuilder** | Background builder function. | `ZegoCallingBackgroundBuilder?` | - |
| **declineButton** | Decline button configuration. | `ZegoCallButtonUIConfig` | - |
| **acceptButton** | Accept button configuration. | `ZegoCallButtonUIConfig` | - |
| **cameraButton** | Camera button configuration. | `ZegoCallButtonUIConfig?` | - |
| **cameraSwitchButton** | Camera switch button configuration. | `ZegoCallButtonUIConfig?` | - |
| **microphoneButton** | Microphone button configuration. | `ZegoCallButtonUIConfig?` | - |
| **speakerButton** | Speaker button configuration. | `ZegoCallButtonUIConfig?` | - |
| **popUp** | Popup dialog configuration. | `ZegoCallInvitationNotifyPopUpUIConfig` | - |
| **defaultCameraOn** | Default camera state when called. | `bool` | true |
| **defaultMicrophoneOn** | Default microphone state when called. | `bool` | true |
| **defaultSpeakerOn** | Default speaker state when called. | `bool` | false |
| **showAvatar** | Whether to show avatar. | `bool` | true |
| **showCentralName** | Whether to show central name. | `bool` | true |
| **showCallingText** | Whether to show calling text. | `bool` | true |
| **showVideoOnCalling** | Whether to show video on calling. | `bool` | true |
| **useVideoViewAspectFill** | Video view aspect fill mode. | `bool` | false |
| **showMainButtonsText** | Whether to show main buttons text. | `bool` | false |
| **showSubButtonsText** | Whether to show sub buttons text. | `bool` | true |
| **minimized** | Minimized UI configuration. | `ZegoCallInvitationInviteeMinimizedUIConfig?` | - |

---

### ZegoCallInvitationNotificationConfig

Configuration for call invitation notification (iOS/Android).

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **iOSNotificationConfig** | iOS notification configuration. | `ZegoCallIOSNotificationConfig?` | - |
| **androidNotificationConfig** | Android notification configuration. | `ZegoCallAndroidNotificationConfig?` | - |

---

### ZegoCallRingtoneConfig

Configuration for call ringtone.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **incomingCallPath** | Incoming call ringtone path. | `String?` | - |
| **outgoingCallPath** | Outgoing call ringtone path. | `String?` | - |

---

### ZegoCallButtonUIConfig

Button UI configuration (visibility, size, icons, styling).

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **visible** | Whether the button is visible. | `bool` | true |
| **size** | Button size. | `Size?` | - |
| **icon** | Custom icon. | `Widget?` | - |
| **iconSize** | Icon size. | `Size?` | - |
| **textStyle** | Text style. | `TextStyle?` | - |

---

### ZegoCallInvitationNotifyPopUpUIConfig

Invitation popup UI configuration.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **padding** | Padding around the popup. | `EdgeInsetsGeometry?` | - |
| **width** | Popup width. | `double?` | - |
| **height** | Popup height. | `double?` | - |
| **decoration** | Popup decoration. | `Decoration?` | - |
| **visible** | Whether to show popup. | `bool` | true |
| **builder** | Custom popup builder. | `ZegoCallInvitationNotifyDialogBuilder?` | - |

---

### ZegoCallSystemConfirmDialogConfig

System confirmation dialog configuration.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **title** | Dialog title. | `String?` | - |
| **titleStyle** | Title text style. | `TextStyle?` | - |
| **contentStyle** | Content text style. | `TextStyle?` | - |
| **actionTextStyle** | Action button text style. | `TextStyle?` | - |
| **backgroundBrightness** | Background brightness. | `Brightness?` | - |

---

### ZegoCallInvitationPermissions

Predefined permission configurations.

| Name | Description | Type |
| :--- | :--- | :--- |
| **withoutSystemAlertWindow** | Permissions without system alert window (camera and microphone). | `List<ZegoCallInvitationPermission>` |
| **audio** | Audio-only permissions (microphone only). | `List<ZegoCallInvitationPermission>` |

---

## ZegoCallInvitationInnerText

Configuration options for modifying invitation page's text content on the UI.

| Property                                          | Description                                            | Type       | Default Value                  |
| :------------------------------------------------ | :----------------------------------------------------- | :--------- | :----------------------------- |
| **incomingVideoCallDialogTitle**            | Title of the incoming video call dialog.               | `String` | Inviter's name                 |
| **incomingVideoCallDialogMessage**          | Message of the incoming video call dialog.             | `String` | "Incoming video call..."       |
| **incomingVoiceCallDialogTitle**            | Title of the incoming voice call dialog.               | `String` | Inviter's name                 |
| **incomingVoiceCallDialogMessage**          | Message of the incoming voice call dialog.             | `String` | "Incoming voice call..."       |
| **incomingVideoCallPageTitle**              | Title of the incoming video call page.                 | `String` | Inviter's name                 |
| **incomingVideoCallPageMessage**            | Message of the incoming video call page.               | `String` | "Incoming video call..."       |
| **incomingVoiceCallPageTitle**              | Title of the incoming voice call page.                 | `String` | Inviter's name                 |
| **incomingVoiceCallPageMessage**            | Message of the incoming voice call page.               | `String` | "Incoming voice call..."       |
| **outgoingVideoCallPageTitle**              | Title of the outgoing video call page.                 | `String` | First invitee's name           |
| **outgoingVideoCallPageMessage**            | Message of the outgoing video call page.               | `String` | "Calling..."                   |
| **outgoingVoiceCallPageTitle**              | Title of the outgoing voice call page.                 | `String` | First invitee's name           |
| **outgoingVoiceCallPageMessage**            | Message of the outgoing voice call page.               | `String` | "Calling..."                   |
| **incomingGroupVideoCallDialogTitle**       | Title of the incoming group video call dialog.         | `String` | Inviter's name                 |
| **incomingGroupVideoCallDialogMessage**     | Message of the incoming group video call dialog.       | `String` | "Incoming group video call..." |
| **incomingGroupVoiceCallDialogTitle**       | Title of the incoming group voice call dialog.         | `String` | Inviter's name                 |
| **incomingGroupVoiceCallDialogMessage**     | Message of the incoming group voice call dialog.       | `String` | "Incoming group voice call..." |
| **incomingGroupVideoCallPageTitle**         | Title of the incoming group video call page.           | `String` | Inviter's name                 |
| **incomingGroupVideoCallPageMessage**       | Message of the incoming group video call page.         | `String` | "Incoming group video call..." |
| **incomingGroupVoiceCallPageTitle**         | Title of the incoming group voice call page.           | `String` | Inviter's name                 |
| **incomingGroupVoiceCallPageMessage**       | Message of the incoming group voice call page.         | `String` | "Incoming group voice call..." |
| **outgoingGroupVideoCallPageTitle**         | Title of the outgoing group video call page.           | `String` | First invitee's name           |
| **outgoingGroupVideoCallPageMessage**       | Message of the outgoing group video call page.         | `String` | "Calling..."                   |
| **outgoingGroupVoiceCallPageTitle**         | Title of the outgoing group voice call page.           | `String` | First invitee's name           |
| **outgoingGroupVoiceCallPageMessage**       | Message of the outgoing group voice call page.         | `String` | "Calling..."                   |
| **incomingCallPageDeclineButton**           | Decline button text on the call bottom bar.            | `String` | "Decline"                      |
| **incomingCallPageAcceptButton**            | Accept button text on the call bottom bar.             | `String` | "Accept"                       |
| **outgoingCallPageACancelButton**           | Cancel button text on the call bottom bar.             | `String` | "Cancel"                       |
| **missedCallNotificationTitle**             | Title of the missed call notification.                 | `String` | "Missed Call"                  |
| **missedGroupVideoCallNotificationContent** | Content of the group video missed call notification.   | `String` | "Group Video Call"             |
| **missedGroupAudioCallNotificationContent** | Content of the group audio missed call notification.   | `String` | "Group Audio Call"             |
| **missedVideoCallNotificationContent**      | Content of the video missed call notification.         | `String` | "Video Call"                   |
| **missedAudioCallNotificationContent**      | Content of the audio missed call notification.         | `String` | "Audio Call"                   |
| **systemAlertWindowConfirmDialogSubTitle**  | Subtitle of the system alert window permission dialog. | `String` | "Display over other apps"      |
| **permissionManuallyConfirmDialogTitle**    | Title of the permission manual confirmation dialog.    | `String` | Permissions instruction text   |
| **permissionManuallyConfirmDialogSubTitle** | Subtitle of the permission manual confirmation dialog. | `String` | Permission list text           |
| **permissionConfirmDialogTitle**            | Title of the permission request dialog.                | `String` | "Allow $appName to"            |
| **permissionConfirmDialogAllowButton**      | Allow button text of the permission request.           | `String` | "Allow"                        |
| **permissionConfirmDialogDenyButton**       | Deny button text of the permission request.            | `String` | "Deny"                         |
| **permissionConfirmDialogCancelButton**     | Cancel button text of the permission request.          | `String` | "Cancel"                       |
| **permissionConfirmDialogOKButton**         | OK button text of the permission request.              | `String` | "OK"                           |
| **callingToolbarMicrophoneButtonText**      | Microphone button text in the calling toolbar.         | `String` | "Microphone"                   |
| **callingToolbarMicrophoneOnButtonText**    | Microphone ON button text.                             | `String` | "Microphone ON"                |
| **callingToolbarMicrophoneOffButtonText**   | Microphone OFF button text.                            | `String` | "Microphone OFF"               |
| **callingToolbarSpeakerButtonText**         | Speaker button text in the calling toolbar.            | `String` | "Speaker"                      |
| **callingToolbarSpeakerOnButtonText**       | Speaker ON button text.                                | `String` | "Speaker ON"                   |
| **callingToolbarSpeakerOffButtonText**      | Speaker OFF button text.                               | `String` | "Speaker OFF"                  |
| **callingToolbarCameraButtonText**          | Camera button text in the calling toolbar.             | `String` | "Camera"                       |
| **callingToolbarCameraOnButtonText**        | Camera ON button text.                                 | `String` | "Camera ON"                    |
| **callingToolbarCameraOffButtonText**       | Camera OFF button text.                                | `String` | "Camera OFF"                   |
| **minimizedCallingPageWaitingText**         | Waiting text shown in minimized calling page.          | `String` | "Waiting for answer"           |

---

### Defines

Core type definitions for call invitation.

### ZegoCallInvitationType

Enum for call invitation type.

| Name | Description | Value |
- **Enum Values**
| :--- | :--- | :--- |
| **voiceCall** | Voice call. | `0` |
| **videoCall** | Video call. | `1` |

---

### ZegoCallInvitationData

Data class containing information about a call invitation.

| Property | Description | Type |
| :--- | :--- | :--- |
| **callID** | The unique identifier for the call. | `String` |
| **invitationID** | The unique identifier for the invitation. | `String` |
| **type** | The type of call (voice or video). | `ZegoCallInvitationType` |
| **invitees** | List of users being invited. | `List<ZegoUIKitUser>` |
| **inviter** | The user who sent the invitation. | `ZegoUIKitUser?` |
| **timeoutSeconds** | Timeout in seconds for the invitation. | `int` |
| **customData** | Custom data to send with the invitation. | `String` |

---

### ZegoCallUser

User class representing a participant in a call invitation.

| Property | Description | Type |
| :--- | :--- | :--- |
| **id** | The unique identifier for the user. | `String` |
| **name** | The display name of the user. | `String` |

---

### ZegoCallInvitationPermission

Enum for call invitation permissions.

| Name | Description |
- **Enum Values**
| :--- | :--- |
| **camera** | Camera permission. |
| **microphone** | Microphone permission. |
| **systemAlertWindow** | System alert window permission (Android). |
| **manuallyByUser** | Permissions that must be set manually by the user. |

---

### ZegoCallInvitationPermissions

Predefined permission configurations for call invitations.

| Name | Description | Type |
| :--- | :--- | :--- |
| **withoutSystemAlertWindow** | Permissions without system alert window (camera and microphone). | `List<ZegoCallInvitationPermission>` |
| **audio** | Audio-only permissions (microphone only). | `List<ZegoCallInvitationPermission>` |

---

### ZegoCallingBuilderInfo

Builder information for the calling page. Contains information about the inviter, invitees, call type, and custom data.

| Property | Description | Type |
| :--- | :--- | :--- |
| **inviter** | The user who initiated the call invitation. | `ZegoUIKitUser` |
| **invitees** | The list of users being invited. | `List<ZegoUIKitUser>` |
| **callType** | The type of call (voice or video). | `ZegoCallInvitationType` |
| **customData** | Custom data passed with the invitation. | `String` |

---

## ZegoUIKitPrebuiltCallInvitationEvents

Invitation-related event notifications and callbacks.

### onError

  - **prototype**: 

  `Function(ZegoUIKitError)?`

  - **prototype**: 

  Error stream callback.

### onInvitationUserStateChanged

  - **prototype**: 

  `Function(List<ZegoSignalingPluginInvitationUserInfo>)?`

  - **prototype**: 

  Triggered to **caller** or **callee** when the other calling member accepts, rejects, or exits, or the response times out.

### onIncomingCallDeclineButtonPressed

  - **prototype**: 

  `Function()?`

  - **prototype**: 

  Triggered to **callee** when callee clicks the decline button in incoming call.

### onIncomingCallAcceptButtonPressed

  - **prototype**: 

  `Function()?`

  - **prototype**: 

  Triggered to **callee** when callee clicks the accept button in incoming call.

### onIncomingCallReceived

  - **prototype**: 

  `Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData)?`

  - **prototype**: 

  Triggered to **callee** when a call is received.

### onIncomingCallCanceled

  - **prototype**: 

  `Function(String callID, ZegoCallUser caller, String customData)?`

  - **prototype**: 

  Triggered to **callee** when the caller cancels the invitation.

### onIncomingCallTimeout

  - **prototype**: 

  `Function(String callID, ZegoCallUser caller)?`

  - **prototype**: 

  Triggered to **callee** when the invitation times out.
  
### onIncomingMissedCallClicked

  - **prototype**: 

  `Future<void> Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData, Future<void> Function() defaultAction)?`

  - **prototype**: 

  Triggered to **callee** when a missed call notification is clicked.

### onIncomingMissedCallDialBackFailed

  - **prototype**: 

  `Function()?`

  - **prototype**: 

  Triggered when missed call dial back failed.

### onOutgoingCallSent

  - **prototype**: 

  `Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData)?`

  - **prototype**: 

  Triggered to **caller** when a call invitation is sent.

### onOutgoingCallCancelButtonPressed

  - **prototype**: 

  `Function()?`

  - **prototype**: 

  Triggered to **caller** when caller clicks the cancel button.

### onOutgoingCallAccepted

  - **prototype**: 

  `Function(String callID, ZegoCallUser callee)?`

  - **prototype**: 

  Triggered to **caller** when the callee accepts the invitation.

### onOutgoingCallRejectedCauseBusy

  - **prototype**: 

  `Function(String callID, ZegoCallUser callee, String customData)?`

  - **prototype**: 

  Triggered to **caller** when the callee rejects the invitation because they are busy.

### onOutgoingCallDeclined

  - **prototype**: 

  `Function(String callID, ZegoCallUser callee, String customData)?`

  - **prototype**: 

  Triggered to **caller** when the callee actively declines the invitation.
  
### onOutgoingCallTimeout

  - **prototype**: 

  `Function(String callID, List<ZegoCallUser> callees, bool isVideoCall)?`

  - **prototype**: 

  Triggered to **caller** when the invitation times out.

---
