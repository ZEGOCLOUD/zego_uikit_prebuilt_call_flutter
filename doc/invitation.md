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
  - [ZegoCallInvitationNotificationConfig](#zegocallinvitationnotificationconfig)
  - [ZegoCallRingtoneConfig](#zegocallringtoneconfig)
  - [ZegoCallInvitationInnerText](#zegocallinvitationinnertext)
- [ZegoUIKitPrebuiltCallInvitationEvents](#zegouikitprebuiltcallinvitationevents)


---

## ZegoUIKitPrebuiltCallInvitationService

Call invitation service singleton class that manages core features including sending, receiving, accepting, and rejecting call invitations.

### init

  - **Description**


  - Initialize the service. Call when the user logs in.

  - **Prototype**
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

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | appID | The App ID of your Zego project | `int` | `Required` |
    | userID | The ID of the user | `String` | `Required` |
    | userName | The name of the user | `String` | `Required` |
    | plugins | The list of plugins to be used. You must include | `List<IZegoUIKitPlugin>` | `Required` |
    | appSign | is not provided or empty | `String` | `` |
    | token | Token for authentication. This is used when | `String` | `` |
    | requireConfig | Callback to obtain the call config | `ZegoCallPrebuiltConfigQuery` | `Optional` |
    | events | The events of the call | `ZegoUIKitPrebuiltCallEvents?` | `Optional` |
    | config | The configuration of the invitation | `ZegoCallInvitationConfig?` | `Optional` |
    | ringtoneConfig | The ringtone configuration for call notifications | `ZegoCallRingtoneConfig?` | `Optional` |
    | uiConfig | The UI configuration of the invitation | `ZegoCallInvitationUIConfig?` | `Optional` |
    | notificationConfig | The notification configuration | `ZegoCallInvitationNotificationConfig?` | `Optional` |
    | innerText | The inner text configuration for invitation UI | `ZegoCallInvitationInnerText?` | `Optional` |
    | invitationEvents | The events of the invitation | `ZegoUIKitPrebuiltCallInvitationEvents?` | `Optional` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: yourAppID,
    appSign: yourAppSign,
    userID: 'userID',
    userName: 'userName',
    plugins: [ZegoUIKitSignalingPlugin()],
  );
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | appID | The App ID of your Zego project | `int` | `Required` |
    | userID | The ID of the user | `String` | `Required` |
    | userName | The name of the user | `String` | `Required` |
    | plugins | The list of plugins to be used. You must include | `List<IZegoUIKitPlugin>` | `Required` |
    | appSign | is not provided or empty | `String` | `` |
    | token | Token for authentication. This is used when | `String` | `` |
    | requireConfig | Callback to obtain the call config | `ZegoCallPrebuiltConfigQuery` | `Optional` |
    | events | The events of the call | `ZegoUIKitPrebuiltCallEvents?` | `Optional` |
    | config | The configuration of the invitation | `ZegoCallInvitationConfig?` | `Optional` |
    | ringtoneConfig | The ringtone configuration for call notifications | `ZegoCallRingtoneConfig?` | `Optional` |
    | uiConfig | The UI configuration of the invitation | `ZegoCallInvitationUIConfig?` | `Optional` |
    | notificationConfig | The notification configuration | `ZegoCallInvitationNotificationConfig?` | `Optional` |
    | innerText | The inner text configuration for invitation UI | `ZegoCallInvitationInnerText?` | `Optional` |
    | invitationEvents | The events of the invitation | `ZegoUIKitPrebuiltCallInvitationEvents?` | `Optional` |


### uninit

  - **Description**


  - Deinitialize the service. Must be called when the user logs out.

  - **Prototype**
  ```dart
  Future<void> uninit()
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().uninit();
  ```

### send

  - **Description**


  - Send a call invitation to specified users.

  - **Prototype**
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

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | invitees | List of users to send the call invitation to | `List<ZegoCallUser>` | `Required` |
    | isVideoCall | Determines whether the call is a video call. If false, it defaults to an audio call | `bool` | `Required` |
    | customData | Custom data to be passed to the invitees | `String` | `` |
    | callID | The ID of the call. If not provided, the system will generate one automatically | `String?` | `Optional` |
    | resourceID | The resource ID for offline call notifications. This should match the push resource ID configured in the ZEGOCLOUD management console | `String?` | `Optional` |
    | notificationTitle | The title for the call notification | `String?` | `Optional` |
    | notificationMessage | The message for the call notification | `String?` | `Optional` |
    | timeoutSeconds | The timeout duration in seconds for the call invitation. Default is 60 seconds | `int` | `60` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().send(
    invitees: [ZegoCallUser(id: '123', name: 'user')],
    isVideoCall: true,
  );
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | invitees | List of users to send the call invitation to | `List<ZegoCallUser>` | `Required` |
    | isVideoCall | Determines whether the call is a video call. If false, it defaults to an audio call | `bool` | `Required` |
    | customData | Custom data to be passed to the invitees | `String` | `` |
    | callID | The ID of the call. If not provided, the system will generate one automatically | `String?` | `Optional` |
    | resourceID | The resource ID for offline call notifications. This should match the push resource ID configured in the ZEGOCLOUD management console | `String?` | `Optional` |
    | notificationTitle | The title for the call notification | `String?` | `Optional` |
    | notificationMessage | The message for the call notification | `String?` | `Optional` |
    | timeoutSeconds | The timeout duration in seconds for the call invitation. Default is 60 seconds | `int` | `60` |


### cancel

  - **Description**


  - Cancel a sent call invitation.

  - **Prototype**
  ```dart
  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | callees | List of callees whose invitation should be cancelled | `List<ZegoCallUser>` | `Required` |
    | customData | Custom data to be included with the cancellation | `String` | `` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().cancel(
    callees: [ZegoCallUser(id: '123', name: 'user')],
  );
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | callees | List of callees whose invitation should be cancelled | `List<ZegoCallUser>` | `Required` |
    | customData | Custom data to be included with the cancellation | `String` | `` |


### reject

  - **Description**


  - Reject the received call invitation.

  - **Prototype**
  ```dart
  Future<bool> reject({
    String customData = '',
    bool needHideInvitationTopSheet = true,
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | customData | Custom data to be passed to the caller when rejecting the invitation | `String` | `` |
    | needHideInvitationTopSheet | Unknown | `bool` | `true` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().reject();
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | customData | Custom data to be passed to the caller when rejecting the invitation | `String` | `` |
    | needHideInvitationTopSheet | Unknown | `bool` | `true` |


### accept

  - **Description**


  - Accept the received call invitation and enter the call.

  - **Prototype**
  ```dart
  Future<bool> accept({
    String customData = '',
  })
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | customData | Custom data to be passed to the caller when accepting the invitation | `String` | `` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().accept();
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | customData | Custom data to be passed to the caller when accepting the invitation | `String` | `` |


### enterAcceptedOfflineCall

  - **Description**


  - Enter an accepted offline call. Suitable for scenarios requiring navigation after data loading completes.

  - **Prototype**
  ```dart
  void enterAcceptedOfflineCall()
  ```

- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().enterAcceptedOfflineCall();
  ```

### setNavigatorKey

  - **Description**


  - Set the navigation key for necessary configuration when navigating pages upon receiving invitations.

  - **Prototype**
  ```dart
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey)
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | navigatorKey | The navigator key to get context for push/pop page when receive invitation request | `GlobalKey<NavigatorState>` | `Optional` |


- **Example**
  ```dart
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | navigatorKey | The navigator key to get context for push/pop page when receive invitation request | `GlobalKey<NavigatorState>` | `Optional` |


### useSystemCallingUI

  - **Description**


  - Enable offline system calling UI to support receiving invitations in the background, answering on lock screen, etc.
  - Note: If you use CallKit with ZIMKit, this must be called AFTER ZIMKit().init!!!

  - **Prototype**
  ```dart
  Future<void> useSystemCallingUI(List<IZegoUIKitPlugin> plugins)
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | plugins | The list of plugins to be used with the system calling UI | `List<IZegoUIKitPlugin>` | `Optional` |


- **Example**
  ```dart
  await ZIMKit().init(..)
  ...
  ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    [ZegoUIKitSignalingPlugin()],
  );
  ```

  - **Parameters**

    | Name | Description | Type | Default Value |
    | :--- | :--- | :--- | :--- |
    | plugins | The list of plugins to be used with the system calling UI | `List<IZegoUIKitPlugin>` | `Optional` |


---

## Configs

- [ZegoCallInvitationConfig](defines.md#zegocallinvitationconfig)
  - Configuration for call invitation.
- [ZegoCallInvitationUIConfig](defines.md#zegocallinvitationuiconfig)
  - Configuration for call invitation UI.
- [ZegoCallInvitationNotificationConfig](defines.md#zegocallinvitationnotificationconfig)
  - Configuration for call invitation notification.
- [ZegoCallRingtoneConfig](defines.md#zegocallringtoneconfig)
  - Configuration for call ringtone.
- [ZegoCallInvitationInnerText](#zegocallinvitationinnertext)
  - Configuration for invitation UI text content.

---

## ZegoCallInvitationInnerText

Configuration options for modifying invitation page's text content on the UI.

| Property | Description | Type | Default Value |
| :--- | :--- | :--- | :--- |
| **incomingVideoCallDialogTitle** | Title of the incoming video call dialog. | `String` | Inviter's name |
| **incomingVideoCallDialogMessage** | Message of the incoming video call dialog. | `String` | "Incoming video call..." |
| **incomingVoiceCallDialogTitle** | Title of the incoming voice call dialog. | `String` | Inviter's name |
| **incomingVoiceCallDialogMessage** | Message of the incoming voice call dialog. | `String` | "Incoming voice call..." |
| **incomingVideoCallPageTitle** | Title of the incoming video call page. | `String` | Inviter's name |
| **incomingVideoCallPageMessage** | Message of the incoming video call page. | `String` | "Incoming video call..." |
| **incomingVoiceCallPageTitle** | Title of the incoming voice call page. | `String` | Inviter's name |
| **incomingVoiceCallPageMessage** | Message of the incoming voice call page. | `String` | "Incoming voice call..." |
| **outgoingVideoCallPageTitle** | Title of the outgoing video call page. | `String` | First invitee's name |
| **outgoingVideoCallPageMessage** | Message of the outgoing video call page. | `String` | "Calling..." |
| **outgoingVoiceCallPageTitle** | Title of the outgoing voice call page. | `String` | First invitee's name |
| **outgoingVoiceCallPageMessage** | Message of the outgoing voice call page. | `String` | "Calling..." |
| **incomingGroupVideoCallDialogTitle** | Title of the incoming group video call dialog. | `String` | Inviter's name |
| **incomingGroupVideoCallDialogMessage** | Message of the incoming group video call dialog. | `String` | "Incoming group video call..." |
| **incomingGroupVoiceCallDialogTitle** | Title of the incoming group voice call dialog. | `String` | Inviter's name |
| **incomingGroupVoiceCallDialogMessage** | Message of the incoming group voice call dialog. | `String` | "Incoming group voice call..." |
| **incomingGroupVideoCallPageTitle** | Title of the incoming group video call page. | `String` | Inviter's name |
| **incomingGroupVideoCallPageMessage** | Message of the incoming group video call page. | `String` | "Incoming group video call..." |
| **incomingGroupVoiceCallPageTitle** | Title of the incoming group voice call page. | `String` | Inviter's name |
| **incomingGroupVoiceCallPageMessage** | Message of the incoming group voice call page. | `String` | "Incoming group voice call..." |
| **outgoingGroupVideoCallPageTitle** | Title of the outgoing group video call page. | `String` | First invitee's name |
| **outgoingGroupVideoCallPageMessage** | Message of the outgoing group video call page. | `String` | "Calling..." |
| **outgoingGroupVoiceCallPageTitle** | Title of the outgoing group voice call page. | `String` | First invitee's name |
| **outgoingGroupVoiceCallPageMessage** | Message of the outgoing group voice call page. | `String` | "Calling..." |
| **incomingCallPageDeclineButton** | Decline button text on the call bottom bar. | `String` | "Decline" |
| **incomingCallPageAcceptButton** | Accept button text on the call bottom bar. | `String` | "Accept" |
| **outgoingCallPageACancelButton** | Cancel button text on the call bottom bar. | `String` | "Cancel" |
| **missedCallNotificationTitle** | Title of the missed call notification. | `String` | "Missed Call" |
| **missedGroupVideoCallNotificationContent** | Content of the group video missed call notification. | `String` | "Group Video Call" |
| **missedGroupAudioCallNotificationContent** | Content of the group audio missed call notification. | `String` | "Group Audio Call" |
| **missedVideoCallNotificationContent** | Content of the video missed call notification. | `String` | "Video Call" |
| **missedAudioCallNotificationContent** | Content of the audio missed call notification. | `String` | "Audio Call" |
| **systemAlertWindowConfirmDialogSubTitle** | Subtitle of the system alert window permission dialog. | `String` | "Display over other apps" |
| **permissionManuallyConfirmDialogTitle** | Title of the permission manual confirmation dialog. | `String` | Permissions instruction text |
| **permissionManuallyConfirmDialogSubTitle** | Subtitle of the permission manual confirmation dialog. | `String` | Permission list text |
| **permissionConfirmDialogTitle** | Title of the permission request dialog. | `String` | "Allow $appName to" |
| **permissionConfirmDialogAllowButton** | Allow button text of the permission request. | `String` | "Allow" |
| **permissionConfirmDialogDenyButton** | Deny button text of the permission request. | `String` | "Deny" |
| **permissionConfirmDialogCancelButton** | Cancel button text of the permission request. | `String` | "Cancel" |
| **permissionConfirmDialogOKButton** | OK button text of the permission request. | `String` | "OK" |
| **callingToolbarMicrophoneButtonText** | Microphone button text in the calling toolbar. | `String` | "Microphone" |
| **callingToolbarMicrophoneOnButtonText** | Microphone ON button text. | `String` | "Microphone ON" |
| **callingToolbarMicrophoneOffButtonText** | Microphone OFF button text. | `String` | "Microphone OFF" |
| **callingToolbarSpeakerButtonText** | Speaker button text in the calling toolbar. | `String` | "Speaker" |
| **callingToolbarSpeakerOnButtonText** | Speaker ON button text. | `String` | "Speaker ON" |
| **callingToolbarSpeakerOffButtonText** | Speaker OFF button text. | `String` | "Speaker OFF" |
| **callingToolbarCameraButtonText** | Camera button text in the calling toolbar. | `String` | "Camera" |
| **callingToolbarCameraOnButtonText** | Camera ON button text. | `String` | "Camera ON" |
| **callingToolbarCameraOffButtonText** | Camera OFF button text. | `String` | "Camera OFF" |
| **minimizedCallingPageWaitingText** | Waiting text shown in minimized calling page. | `String` | "Waiting for answer" |

---

## ZegoUIKitPrebuiltCallInvitationEvents

Invitation-related event notifications and callbacks.

- **onError**
  - **Function Prototype**: `Function(ZegoUIKitError)?`
  - **Description**: Error stream callback.

- **onInvitationUserStateChanged**
  - **Function Prototype**: `Function(List<ZegoSignalingPluginInvitationUserInfo>)?`
  - **Description**: Triggered to **caller** or **callee** when the other calling member accepts, rejects, or exits, or the response times out.

- **onIncomingCallDeclineButtonPressed**
  - **Function Prototype**: `Function()?`
  - **Description**: Triggered to **callee** when callee clicks the decline button in incoming call.

- **onIncomingCallAcceptButtonPressed**
  - **Function Prototype**: `Function()?`
  - **Description**: Triggered to **callee** when callee clicks the accept button in incoming call.

- **onIncomingCallReceived**
  - **Function Prototype**: `Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData)?`
  - **Description**: Triggered to **callee** when a call is received.

- **onIncomingCallCanceled**
  - **Function Prototype**: `Function(String callID, ZegoCallUser caller, String customData)?`
  - **Description**: Triggered to **callee** when the caller cancels the invitation.

- **onIncomingCallTimeout**
  - **Function Prototype**: `Function(String callID, ZegoCallUser caller)?`
  - **Description**: Triggered to **callee** when the invitation times out.

- **onIncomingMissedCallClicked**
  - **Function Prototype**: `Future<void> Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData, Future<void> Function() defaultAction)?`
  - **Description**: Triggered to **callee** when a missed call notification is clicked.

- **onIncomingMissedCallDialBackFailed**
  - **Function Prototype**: `Function()?`
  - **Description**: Triggered when missed call dial back failed.

- **onOutgoingCallSent**
  - **Function Prototype**: `Function(String callID, ZegoCallUser caller, ZegoCallInvitationType callType, List<ZegoCallUser> callees, String customData)?`
  - **Description**: Triggered to **caller** when a call invitation is sent.

- **onOutgoingCallCancelButtonPressed**
  - **Function Prototype**: `Function()?`
  - **Description**: Triggered to **caller** when caller clicks the cancel button.

- **onOutgoingCallAccepted**
  - **Function Prototype**: `Function(String callID, ZegoCallUser callee)?`
  - **Description**: Triggered to **caller** when the callee accepts the invitation.

- **onOutgoingCallRejectedCauseBusy**
  - **Function Prototype**: `Function(String callID, ZegoCallUser callee, String customData)?`
  - **Description**: Triggered to **caller** when the callee rejects the invitation because they are busy.

- **onOutgoingCallDeclined**
  - **Function Prototype**: `Function(String callID, ZegoCallUser callee, String customData)?`
  - **Description**: Triggered to **caller** when the callee actively declines the invitation.

- **onOutgoingCallTimeout**
  - **Function Prototype**: `Function(String callID, List<ZegoCallUser> callees, bool isVideoCall)?`
  - **Description**: Triggered to **caller** when the invitation times out.

---



