# Configs

## ZegoUIKitPrebuiltCallConfig

Configuration for initializing the Call. This class is used as the `config` parameter for the constructor of `ZegoUIKitPrebuiltCall`.

### Constructors

#### ZegoUIKitPrebuiltCallConfig

```dart
ZegoUIKitPrebuiltCallConfig({
  bool turnOnCameraWhenJoining = true,
  bool useFrontCameraWhenJoining = true,
  bool turnOnMicrophoneWhenJoining = true,
  bool useSpeakerWhenJoining = false,
  bool rootNavigator = false,
  Map<String, String> advanceConfigs = const {},
  bool enableAccidentalTouchPrevention = true,
  ZegoUIKitVideoConfig? videoConfig,
  ZegoCallAudioVideoViewConfig? audioVideoViewConfig,
  ZegoCallTopMenuBarConfig? topMenuBarConfig,
  ZegoCallBottomMenuBarConfig? bottomMenuBarConfig,
  ZegoCallMemberListConfig? memberListConfig,
  ZegoCallPIPConfig? pipConfig,
  ZegoCallDurationConfig? durationConfig,
  ZegoCallInRoomChatViewConfig? chatViewConfig,
  ZegoCallHangUpConfirmDialogConfig? hangUpConfirmDialog,
  ZegoCallUserConfig? userConfig,
  ZegoCallDeviceConfig? deviceConfig,
  ZegoLayout? layout,
  Widget? foreground,
  Widget? background,
  ZegoAvatarBuilder? avatarBuilder,
  ZegoUIKitPrebuiltCallInnerText? translationText,
  ZegoCallAudioEffectConfig? audioEffect,
})
```

#### ZegoUIKitPrebuiltCallConfig.groupVideoCall

Default initialization parameters for the group video call.

```dart
factory ZegoUIKitPrebuiltCallConfig.groupVideoCall()
```

#### ZegoUIKitPrebuiltCallConfig.groupVoiceCall

Default initialization parameters for the group voice call.

```dart
factory ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
```

#### ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall

Default initialization parameters for the one-on-one video call.

```dart
factory ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
```

#### ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall

Default initialization parameters for the one-on-one voice call.

```dart
factory ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
```

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **video** | `ZegoUIKitVideoConfig` | Configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate. |
| **audioVideoView** | `ZegoCallAudioVideoViewConfig` | Configuration options for audio/video views. |
| **topMenuBar** | `ZegoCallTopMenuBarConfig` | Configuration options for the top menu bar (toolbar). |
| **bottomMenuBar** | `ZegoCallBottomMenuBarConfig` | Configuration options for the bottom menu bar (toolbar). |
| **memberList** | `ZegoCallMemberListConfig` | Configuration related to the bottom member list. |
| **beauty** | `ZegoBeautyPluginConfig?` | Advance beauty config. |
| **duration** | `ZegoCallDurationConfig` | Call timing configuration. |
| **chatView** | `ZegoCallInRoomChatViewConfig` | Configuration related to the bottom-left message list. |
| **hangUpConfirmDialog** | `ZegoCallHangUpConfirmDialogConfig` | Configuration for the hang-up confirmation dialog. |
| **audioEffect** | `ZegoCallAudioEffectConfig` | Configuration options for voice changer and reverberation effects. |
| **screenSharing** | `ZegoCallScreenSharingConfig` | Screen sharing configuration. |
| **pip** | `ZegoCallPIPConfig` | Picture-in-Picture (PIP) configuration. |
| **advanceConfigs** | `Map<String, String>` | Set advanced engine configuration. |
| **user** | `ZegoCallUserConfig` | Config about users. |
| **device** | `ZegoCallDeviceConfig` | Config about device. |
| **enableAccidentalTouchPrevention** | `bool` | Whether to enable accidental touch prevention during earpiece calls. Default is `true`. |
| **turnOnCameraWhenJoining** | `bool` | Whether to open the camera when joining the call. Default is `true`. |
| **useFrontCameraWhenJoining** | `bool` | Whether to use the front camera when joining the call. Default is `true`. |
| **turnOnMicrophoneWhenJoining** | `bool` | Whether to open the microphone when joining the call. Default is `true`. |
| **useSpeakerWhenJoining** | `bool` | Whether to use the speaker to play audio when joining the call. Default is `false`. |
| **layout** | `ZegoLayout` | Layout-related configuration. |
| **foreground** | `Widget?` | The foreground of the call. |
| **background** | `Widget?` | The background of the call. |
| **avatarBuilder** | `ZegoAvatarBuilder?` | Use this to customize the avatar. |
| **translationText** | `ZegoUIKitPrebuiltCallInnerText` | Configuration options for modifying all calling page's text content. |
| **rootNavigator** | `bool` | Whether to use the root navigator. Default is `false`. |

## ZegoCallAudioVideoViewConfig

Configuration options for audio/video views.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **isVideoMirror** | `bool` | Whether to mirror the displayed video captured by the camera. Default is `true`. |
| **showMicrophoneStateOnView** | `bool` | Whether to display the microphone status on the audio/video view. Default is `true`. |
| **showCameraStateOnView** | `bool` | Whether to display the camera status on the audio/video view. Default is `false`. |
| **showUserNameOnView** | `bool` | Whether to display the username on the audio/video view. Default is `true`. |
| **showOnlyCameraMicrophoneOpened** | `bool` | Is it only displayed audio video view when the camera or microphone is turned on? Default is `false`. |
| **showLocalUser** | `bool` | Is it display local user audio video view. Default is `true`. |
| **showWaitingCallAcceptAudioVideoView** | `bool` | When inviting in calling, the invited user window will appear on the invitation side. Default is `true`. |
| **waitingCallAcceptForegroundBuilder** | `ZegoAudioVideoViewForegroundBuilder?` | Custom foreground builder for waiting call accept view. |
| **foregroundBuilder** | `ZegoAudioVideoViewForegroundBuilder?` | Custom foreground builder for audio/video view. |
| **backgroundBuilder** | `ZegoAudioVideoViewBackgroundBuilder?` | Custom background builder for audio/video view. |
| **useVideoViewAspectFill** | `bool` | Video view mode. `true` for aspect fill, `false` for aspect fit. Default is `false`. |
| **showAvatarInAudioMode** | `bool` | Whether to display user avatars in audio mode. Default is `true`. |
| **showSoundWavesInAudioMode** | `bool` | Whether to display sound waveforms in audio mode. Default is `true`. |
| **containerBuilder** | `ZegoCallAudioVideoContainerBuilder?` | Custom audio/video view container. |
| **containerRect** | `Rect Function()?` | Specify the rect of the audio & video container. |

## ZegoCallTopMenuBarConfig

Configuration options for the top menu bar (toolbar).

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **isVisible** | `bool` | Whether to display the top menu bar. Default is `true`. |
| **title** | `String` | Title of the top menu bar. |
| **hideAutomatically** | `bool` | Whether to automatically collapse the top menu bar after 5 seconds of inactivity. Default is `true`. |
| **hideByClick** | `bool` | Whether to collapse the top menu bar when clicking on the blank area. Default is `true`. |
| **buttons** | `List<ZegoCallMenuBarButtonName>` | Buttons displayed on the menu bar. |
| **extendButtons** | `List<Widget>` | Extension buttons that allow you to add your own buttons to the top toolbar. |
| **style** | `ZegoCallMenuBarStyle` | Style of the top menu bar. Default is `ZegoCallMenuBarStyle.light`. |
| **padding** | `EdgeInsetsGeometry?` | Padding for the top menu bar. |
| **margin** | `EdgeInsetsGeometry?` | Margin for the top menu bar. |
| **backgroundColor** | `Color?` | Background color for the top menu bar. |
| **height** | `double?` | Height for the top menu bar. |

## ZegoCallBottomMenuBarConfig

Configuration options for the bottom menu bar (toolbar).

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **isVisible** | `bool` | Whether to display the bottom menu bar. Default is `true`. |
| **hideAutomatically** | `bool` | Whether to automatically collapse the bottom menu bar after 5 seconds of inactivity. Default is `true`. |
| **hideByClick** | `bool` | Whether to collapse the bottom menu bar when clicking on the blank area. Default is `true`. |
| **buttons** | `List<ZegoCallMenuBarButtonName>` | Buttons displayed on the menu bar. |
| **maxCount** | `int` | Controls the maximum number of buttons to be displayed in the menu bar. Default is `5`. |
| **style** | `ZegoCallMenuBarStyle` | Button style for the bottom menu bar. Default is `ZegoCallMenuBarStyle.light`. |
| **padding** | `EdgeInsetsGeometry?` | Padding for the bottom menu bar. |
| **margin** | `EdgeInsetsGeometry?` | Margin for the bottom menu bar. |
| **backgroundColor** | `Color?` | Background color for the bottom menu bar. |
| **height** | `double?` | Height for the bottom menu bar. |
| **extendButtons** | `List<Widget>` | Extension buttons. |

## ZegoCallMemberListConfig

Configuration for the member list.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **showMicrophoneState** | `bool` | Whether to show the microphone state of the member. Default is `true`. |
| **showCameraState** | `bool` | Whether to show the camera state of the member. Default is `true`. |
| **itemBuilder** | `ZegoMemberListItemBuilder?` | Custom member list item view. |

## ZegoCallDurationConfig

Call timing configuration.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **isVisible** | `bool` | Whether to display call timing. Default is `true`. |
| **onDurationUpdate** | `void Function(Duration)?` | Call timing callback function, called every second. |

## ZegoCallInRoomChatViewConfig

Control options for the bottom-left message list.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **itemBuilder** | `ZegoInRoomMessageItemBuilder?` | Use this to customize the style and content of each chat message list item. |

## ZegoCallHangUpConfirmDialogConfig

Confirmation dialog when hang up the call.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **info** | `ZegoCallHangUpConfirmDialogInfo?` | Dialog information. |
| **titleStyle** | `TextStyle?` | Title text style. |
| **contentStyle** | `TextStyle?` | Content text style. |
| **actionTextStyle** | `TextStyle?` | Action button text style. |
| **backgroundBrightness** | `Brightness?` | Background brightness. |

## ZegoCallAudioEffectConfig

Configuration options for voice changer, beauty effects and reverberation effects.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **voiceChangeEffect** | `List<VoiceChangerType>` | List of voice changer effects. |
| **reverbEffect** | `List<ReverbType>` | List of revert effects types. |
| **backgroundColor** | `Color?` | The background color of the sheet. |
| **headerTitleTextStyle** | `TextStyle?` | The text style of the head title sheet. |
| **backIcon** | `Widget?` | Back button icon. |
| **resetIcon** | `Widget?` | Reset button icon. |
| **normalIconColor** | `Color?` | Color of the icons in the normal state. |
| **selectedIconColor** | `Color?` | Color of the icons in the highlighted state. |
| **normalIconBorderColor** | `Color?` | Border color of the icons in the normal state. |
| **selectedIconBorderColor** | `Color?` | Border color of the icons in the highlighted state. |
| **selectedTextStyle** | `TextStyle?` | Text-style of buttons in the highlighted state. |
| **normalTextStyle** | `TextStyle?` | Text-style of buttons in the normal state. |
| **sliderTextStyle** | `TextStyle?` | The style of the text displayed on the Slider's thumb. |
| **sliderTextBackgroundColor** | `Color?` | The background color of the text displayed on the Slider's thumb. |
| **sliderActiveTrackColor** | `Color?` | The color of the track that is active when sliding the Slider. |
| **sliderInactiveTrackColor** | `Color?` | The color of the track that is inactive when sliding the Slider. |
| **sliderThumbColor** | `Color?` | The color of the Slider's thumb. |
| **sliderThumbRadius** | `double?` | The radius of the Slider's thumb. |

## ZegoCallScreenSharingConfig

Configuration for screen sharing.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **autoStop** | `ZegoCallScreenSharingAutoStopConfig` | Configuration for auto-stop when ending screen sharing from a non-app. |
| **defaultFullScreen** | `bool` | If true, screen sharing will automatically be full screen. Default is `false`. |

## ZegoCallScreenSharingAutoStopConfig

Configuration for automatic screen sharing stop when ending from a non-app.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **invalidCount** | `int` | Number of check fails before automatically ending the screen sharing. Default is `3`. |
| **canEnd** | `bool Function()?` | Callback to determine whether to end. Returns false if you don't want to end. |

## ZegoCallUserConfig

Config about users.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **requiredUsers** | `ZegoCallRequiredUserConfig` | Necessary user in the call. |

## ZegoCallDeviceConfig

Config about device.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **enableSyncDeviceStatusBySEI** | `bool` | Whether to sync device status by SEI. Default is `true`. |

## ZegoCallRequiredUserConfig

Necessary participants to participate in the call.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **enabled** | `bool` | Is enable detection or not. Default is `false`. |
| **detectSeconds** | `int` | The time to start the detection. Default is `5`. |
| **users** | `List<ZegoUIKitUser>` | Necessary participants list. |
| **detectInDebugMode** | `bool` | Is detection enabled in debugging mode. Default is `false`. |

## ZegoCallPIPConfig

PIP config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **android** | `ZegoCallPIPAndroidConfig` | Android config. |
| **iOS** | `ZegoCallPIPIOSConfig` | iOS config. |
| **aspectWidth** | `int` | Aspect width. Default is `9`. |
| **aspectHeight** | `int` | Aspect height. Default is `16`. |
| **enableWhenBackground** | `bool` | Enable PIP when background. Default is `true`. |

## ZegoCallPIPAndroidConfig

Android PIP config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **background** | `Widget?` | Background widget. Default is black. |

## ZegoCallPIPIOSConfig

iOS PIP config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **support** | `bool` | Whether to enable PIP under iOS. Default is `true`. |

## ZegoUIKitPrebuiltCallInnerText

Control the text on the UI.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **audioEffectTitle** | `String` | Title of audio effects dialog. |
| **audioEffectReverbTitle** | `String` | Title of reverb category. |
| **audioEffectVoiceChangingTitle** | `String` | Title of voice changing category. |
| **voiceChangerNoneTitle** | `String` | Voice changer: None. |
| **voiceChangerLittleBoyTitle** | `String` | Voice changer: Little Boy. |
| **voiceChangerLittleGirlTitle** | `String` | Voice changer: Little Girl. |
| **voiceChangerDeepTitle** | `String` | Voice changer: Deep. |
| **voiceChangerCrystalClearTitle** | `String` | Voice changer: Crystal-clear. |
| **voiceChangerRobotTitle** | `String` | Voice changer: Robot. |
| **voiceChangerEtherealTitle** | `String` | Voice changer: Ethereal. |
| **voiceChangerFemaleTitle** | `String` | Voice changer: Female. |
| **voiceChangerMaleTitle** | `String` | Voice changer: Male. |
| **voiceChangerOptimusPrimeTitle** | `String` | Voice changer: Optimus Prime. |
| **voiceChangerCMajorTitle** | `String` | Voice changer: C Major. |
| **voiceChangerAMajorTitle** | `String` | Voice changer: A Major. |
| **voiceChangerHarmonicMinorTitle** | `String` | Voice changer: Harmonic minor. |
| **reverbTypeNoneTitle** | `String` | Reverb: None. |
| **reverbTypeKTVTitle** | `String` | Reverb: KTV. |
| **reverbTypeHallTitle** | `String` | Reverb: Hall. |
| **reverbTypeConcertTitle** | `String` | Reverb: Concert. |
| **reverbTypeRockTitle** | `String` | Reverb: Rock. |
| **reverbTypeSmallRoomTitle** | `String` | Reverb: Small room. |
| **reverbTypeLargeRoomTitle** | `String` | Reverb: Large room. |
| **reverbTypeValleyTitle** | `String` | Reverb: Valley. |
| **reverbTypeRecordingStudioTitle** | `String` | Reverb: Recording studio. |
| **reverbTypeBasementTitle** | `String` | Reverb: Basement. |
| **reverbTypePopularTitle** | `String` | Reverb: Pop. |
| **reverbTypeGramophoneTitle** | `String` | Reverb: Gramophone. |
| **screenSharingTipText** | `String` | Screen sharing tip text. |
| **stopScreenSharingButtonText** | `String` | Stop screen sharing button text. |
| **screenBlockedTitle** | `String` | Screen blocked title. |
| **screenBlockedSubtitle** | `String` | Screen blocked subtitle. |

## ZegoCallInvitationConfig

Call invitation configuration class.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **permissions** | `List<ZegoCallInvitationPermission>` | Permissions required for invitation. |
| **endCallWhenInitiatorLeave** | `bool` | Whether the entire call should end when the initiator leaves. Default is `false`. |
| **offline** | `ZegoCallInvitationOfflineConfig` | Offline config. |
| **inCalling** | `ZegoCallInvitationInCallingConfig` | Calling config. |
| **missedCall** | `ZegoCallInvitationMissedCallConfig` | Missed call config. |
| **systemWindowConfirmDialog** | `ZegoCallSystemConfirmDialogConfig?` | System window confirm dialog config. |
| **pip** | `ZegoCallInvitationPIPConfig` | PIP config. |
| **networkLoading** | `ZegoNetworkLoadingConfig?` | Network loading config. |

## ZegoCallInvitationOfflineConfig

Offline config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **autoEnterAcceptedOfflineCall** | `bool` | Whether to automatically enter the accepted offline call. Default is `true`. |

## ZegoCallInvitationInCallingConfig

In-calling config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **canInvitingInCalling** | `bool` | Whether to allow invitations in calling. Default is `false`. |
| **onlyInitiatorCanInvite** | `bool` | Whether only the initiator can invite. Default is `false`. |

## ZegoCallInvitationMissedCallConfig

Missed call config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **enabled** | `bool` | Whether to allow popup the missed notification. Default is `false`. |
| **enableDialBack** | `bool` | Whether to allow redial the missed when click notification. Default is `false`. |
| **resourceID** | `String?` | The resource id for notification. |
| **notificationTitle** | `String? Function()?` | The title for the notification. |
| **notificationMessage** | `String? Function()?` | The message for the notification. |
| **timeoutSeconds** | `int` | The timeout duration in seconds for the redial invitation. Default is `30`. |

## ZegoCallInvitationPIPConfig

Invitation PIP config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **iOS** | `ZegoCallInvitationPIPIOSConfig` | iOS config. |

## ZegoCallInvitationPIPIOSConfig

Invitation iOS PIP config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **support** | `bool` | Whether to enable PIP under iOS. Default is `false`. |

## ZegoCallInvitationUIConfig

Call invitation UI configuration class.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **withSafeArea** | `bool` | Does invitation widget display with SafeArea. Default is `true`. |
| **inviter** | `ZegoCallInvitationInviterUIConfig` | Inviter UI config. |
| **invitee** | `ZegoCallInvitationInviteeUIConfig` | Invitee UI config. |

## ZegoCallInvitationInviterUIConfig

Inviter UI config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **foregroundBuilder** | `ZegoCallingForegroundBuilder?` | The foreground of the calling. |
| **pageBuilder** | `ZegoCallingPageBuilder?` | It will replace the inviter's call view. |
| **backgroundBuilder** | `ZegoCallingBackgroundBuilder?` | Background builder. |
| **cancelButton** | `ZegoCallButtonUIConfig` | Cancel button config. |
| **microphoneButton** | `ZegoCallButtonUIConfig?` | Microphone button config. |
| **defaultMicrophoneOn** | `bool` | Whether to open the microphone when on calling. Default is `true`. |
| **cameraButton** | `ZegoCallButtonUIConfig?` | Camera button config. |
| **defaultCameraOn** | `bool` | Whether to open the camera when on calling. Default is `true`. |
| **cameraSwitchButton** | `ZegoCallButtonUIConfig?` | Camera switch button config. |
| **speakerButton** | `ZegoCallButtonUIConfig?` | Speaker button config. |
| **defaultSpeakerOn** | `bool` | Whether to open the speaker when on calling. Default is `false`. |
| **showAvatar** | `bool` | Show avatar or not. Default is `true`. |
| **showCentralName** | `bool` | Show central name or not. Default is `true`. |
| **showCallingText** | `bool` | Show calling text or not. Default is `true`. |
| **spacingBetweenAvatarAndName** | `double?` | Spacing between avatar and name. |
| **spacingBetweenNameAndCallingText** | `double?` | Spacing between name and calling text. |
| **useVideoViewAspectFill** | `bool` | Video view mode. Default is `false`. |
| **showMainButtonsText** | `bool` | Show main buttons text or not. Default is `false`. |
| **showSubButtonsText** | `bool` | Show sub buttons text or not. Default is `true`. |
| **minimized** | `ZegoCallInvitationInviterMinimizedUIConfig?` | Minimized UI config. |

## ZegoCallInvitationInviteeUIConfig

Invitee UI config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **foregroundBuilder** | `ZegoCallingForegroundBuilder?` | The foreground of the calling. |
| **pageBuilder** | `ZegoCallingPageBuilder?` | It will replace the invitee's call view. |
| **backgroundBuilder** | `ZegoCallingBackgroundBuilder?` | Background builder. |
| **popUp** | `ZegoCallInvitationNotifyPopUpUIConfig` | Config of call invitation pop-up dialog. |
| **declineButton** | `ZegoCallButtonUIConfig` | Decline button config. |
| **acceptButton** | `ZegoCallButtonUIConfig` | Accept button config. |
| **microphoneButton** | `ZegoCallButtonUIConfig?` | Microphone button config. |
| **defaultMicrophoneOn** | `bool` | Whether to open the microphone when on be called. Default is `true`. |
| **cameraButton** | `ZegoCallButtonUIConfig?` | Camera button config. |
| **defaultCameraOn** | `bool` | Whether to open the camera when on be called. Default is `true`. |
| **cameraSwitchButton** | `ZegoCallButtonUIConfig?` | Camera switch button config. |
| **speakerButton** | `ZegoCallButtonUIConfig?` | Speaker button config. |
| **defaultSpeakerOn** | `bool` | Whether to open the speaker when on calling. Default is `false`. |
| **showAvatar** | `bool` | Show avatar or not. Default is `true`. |
| **showCentralName** | `bool` | Show central name or not. Default is `true`. |
| **showCallingText** | `bool` | Show calling text or not. Default is `true`. |
| **spacingBetweenAvatarAndName** | `double?` | Spacing between avatar and name. |
| **spacingBetweenNameAndCallingText** | `double?` | Spacing between name and calling text. |
| **useVideoViewAspectFill** | `bool` | Video view mode. Default is `false`. |
| **showVideoOnCalling** | `bool` | Show video or not on a video calling. Default is `true`. |
| **showMainButtonsText** | `bool` | Show main buttons text or not. Default is `false`. |
| **showSubButtonsText** | `bool` | Show sub buttons text or not. Default is `true`. |
| **minimized** | `ZegoCallInvitationInviteeMinimizedUIConfig?` | Minimized UI config. |

## ZegoCallInvitationInviterMinimizedUIConfig

Inviter minimized UI config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **cancelButton** | `ZegoCallButtonUIConfig` | Cancel button config. |
| **showTips** | `bool` | Show tip or not. Default is `true`. |

## ZegoCallInvitationInviteeMinimizedUIConfig

Invitee minimized UI config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **acceptButton** | `ZegoCallButtonUIConfig` | Accept button config. |
| **declineButton** | `ZegoCallButtonUIConfig` | Decline button config. |
| **showTips** | `bool` | Show tip or not. Default is `true`. |

## ZegoCallInvitationNotificationConfig

Invitation notification config.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **iOSNotificationConfig** | `ZegoCallIOSNotificationConfig?` | iOS notification config. |
| **androidNotificationConfig** | `ZegoCallAndroidNotificationConfig?` | Android notification config. |

## ZegoCallButtonUIConfig

Button UI configuration class.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **visible** | `bool` | Whether to display the button. Default is `true`. |
| **size** | `Size?` | Button size. |
| **icon** | `Widget?` | Custom icon. |
| **iconSize** | `Size?` | Icon size. |
| **textStyle** | `TextStyle?` | Text style. |

## ZegoCallInvitationNotifyPopUpUIConfig

Invitation popup UI configuration class.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **visible** | `bool` | Whether to pop up the top pop-up dialog. Default is `true`. |
| **builder** | `ZegoCallInvitationNotifyDialogBuilder?` | Custom builder for the top pop-up dialog. |
| **width** | `double?` | Width. |
| **height** | `double?` | Height. |
| **padding** | `EdgeInsetsGeometry?` | Padding. |
| **decoration** | `Decoration?` | Decoration. |

## ZegoCallRingtoneConfig

Ringtone configuration for online calls.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **incomingCallPath** | `String?` | Callee ringtone path. Must be a resource in your Flutter project. |
| **outgoingCallPath** | `String?` | Caller ringtone path. Must be a resource in your Flutter project. |

## ZegoCallIOSNotificationConfig

iOS notification configuration.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **appName** | `String` | App name displayed in notification. |
| **isSandboxEnvironment** | `bool?` | iOS sandbox mode. Auto-detected if null. |
| **certificateIndex** | `ZegoSignalingPluginMultiCertificate` | Certificate index from Zego Console. |
| **systemCallingIconName** | `String` | Icon name for CallKit lock screen (without extension). |

## ZegoCallAndroidNotificationConfig

Android notification configuration.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **callIDVisibility** | `bool` | Show/hide call ID in notification. Default is `true`. |
| **showOnLockedScreen** | `bool` | Show on locked screen. Default is `true`. |
| **showOnFullScreen** | `bool` | Show full screen intent. Default is `true`. |
| **certificateIndex** | `ZegoSignalingPluginMultiCertificate` | Certificate index from Zego Console. |
| **fullScreenBackgroundAssetURL** | `String?` | Background image URL for full screen. |
| **callChannel** | `ZegoCallAndroidNotificationChannelConfig` | Call notification channel config. |
| **messageChannel** | `ZegoCallAndroidNotificationChannelConfig` | Message notification channel config. |
| **missedCallChannel** | `ZegoCallAndroidNotificationChannelConfig` | Missed call notification channel config. |

## ZegoCallAndroidNotificationChannelConfig

Android notification channel configuration.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **channelID** | `String` | Notification channel ID. |
| **channelName** | `String` | Notification channel name. |
| **icon** | `String?` | Icon file name (place in android/app/src/main/res/drawable/). |
| **sound** | `String?` | Sound file name (must match Zego Console, place in android/app/src/main/res/raw/). |
| **vibrate** | `bool` | Enable vibration. Default is `true`. |

## ZegoCallSystemConfirmDialogConfig

System confirm dialog configuration.

### Properties

| Property | Type | Description |
| :--- | :--- | :--- |
| **title** | `String?` | Dialog title. |
| **titleStyle** | `TextStyle?` | Title text style. |
| **contentStyle** | `TextStyle?` | Content text style. |
| **actionTextStyle** | `TextStyle?` | Action button text style. |
| **backgroundBrightness** | `Brightness?` | Dialog background brightness. |
