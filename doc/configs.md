- [Invitation](#invitation)
  ----------
  - [config](#zegocallinvitationconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallinvitationconfig-classhtml)
  - [ringtone](#zegocallringtoneconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallringtoneconfig-classhtml)
  - [UI](#zegocallinvitationuiconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallinvitationuiconfig-classhtml)
    - `inviter`
    - `invitee`
      - `popUp`
  - [notification](#zegocallinvitationnotificationconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallinvitationnotificationconfig-classhtml)
    - `iOSNotificationConfig`
    - `androidNotificationConfig`
    
- [Call](#zegouikitprebuiltcallconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegouikitprebuiltcallconfig-classhtml)
  - [video](#zegouikitvideoconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegouikitvideoconfig-classhtml-video)
  - [audioVideoView](#zegocallaudiovideoviewconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallaudiovideoviewconfig-classhtml-audiovideoview)
  - [topMenuBar](#zegocalltopmenubarconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocalltopmenubarconfig-classhtml-topmenubar)
  - [bottomMenuBar](#zegocallbottommenubarconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallbottommenubarconfig-classhtml-bottommenubar)
  - [memberList](#zegocallmemberlistconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallmemberlistconfig-classhtml-memberlist)
  - [beauty](#zegobeautypluginconfighttpspubdevdocumentationzego_plugin_adapterlatestzego_plugin_adapterzegobeautypluginconfig-classhtml-beauty)
  - [duration](#zegocalldurationconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocalldurationconfig-classhtml-duration)
  - [chatView](#zegocallinroomchatviewconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallinroomchatviewconfig-classhtml-chatview)
  - [user](#zegocalluserconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocalluserconfig-classhtml-user)
  - [hangUpConfirmDialog](#zegocallhangupconfirmdialogconfighttpspubdevdocumentationzego_uikit_prebuilt_calllatestzego_uikit_prebuilt_callzegocallhangupconfirmdialogconfig-classhtml-hangupconfirmdialog)
  - [advanceConfigs](#mapstring-string-advanceconfigs)
  - [turnOnCameraWhenJoining](#bool-turnoncamerawhenjoining)
  - [turnOnMicrophoneWhenJoining](#bool-turnonmicrophonewhenjoining)
  - [useSpeakerWhenJoining](#bool-usespeakerwhenjoining)
  - [layout](#zegolayouthttpspubdevdocumentationzego_uikitlatestzego_uikitzegolayouthtml-layout)
  - [foreground](#widget-foreground)
  - [background](#widget-background)
  - [avatarBuilder](#zegoavatarbuilderhttpspubdevdocumentationzego_uikitlatestzego_uikitzegoavatarbuilderhtml-avatarbuilder)
  - [rootNavigator](#bool-rootnavigator)

---

# Invitation

## [ZegoCallInvitationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationConfig-class.html)

  - List\<ZegoCallInvitationPermission\> `permissions`:
  > If you want to a pure audio call with invitation without popping up
  > camera permission requests, you can remove the camera in [permissions]
  > and set [ZegoUIKitPrebuiltCallConfig turnOnCameraWhenJoining] to false
  >
  > ``` dart
  > ZegoUIKitPrebuiltCallInvitationService().init(
  >   ...
  >   config: ZegoCallInvitationConfig(permissions: [
  >     ZegoCallInvitationPermission.microphone,
  >   ]),
  >   requireConfig: (ZegoCallInvitationData data) {
  >     ...
  >     config.turnOnCameraWhenJoining = false;
  >     ...
  >   },
  > );
  > ```

  - bool `onlyInitiatorCanInvite`:
  > whether only the call initiator has the permission to invite others to
  > join the call.
  > Default value is false.
  >
  > If set to false, all participants in the call can invite others.

  - bool `endCallWhenInitiatorLeave`:
  > whether the entire call should end when the initiator leaves the call
  > (will causing other participants to leave together).
  > Default value is false.
  >
  > If set to false, the call can continue even after the initiator leaves.

## [ZegoCallRingtoneConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallRingtoneConfig-class.html)

> online call ringtone config
> Note that it only works for online calls. If it is offline, please configure it in the zego console

- String? `incomingCallPath`

> callee ringtone on local side, please note that the resource needs to be configured in your flutter project
> example: "assets/ringtone/incomingCallRingtone.mp3"

- String? `outgoingCallPath`

> caller ringtone on local side, please note that the resource needs to be configured in your flutter project
> example: "assets/ringtone/outgoingCallRingtone.mp3"

## [ZegoCallInvitationUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationUIConfig-class.html)

- bool `prebuiltWithSafeArea`: does [ZegoUIKitPrebuiltCall] display with SafeArea or not
- [ZegoCallInvitationInviterUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationInviterUIConfig.html)? `inviter`:

  - bool `showAvatar`: show avatar or not
  - bool `showCentralName`: show central name or not
  - bool `showCallingText`: show calling text or not
  - double? `spacingBetweenAvatarAndName`: spacing between avatar and name
  - double? `spacingBetweenNameAndCallingText`: spacing between name and calling text
  - [ZegoCallingForegroundBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingForegroundBuilder.html)? `foregroundBuilder`: foreground builder
  - [ZegoCallingPageBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingPageBuilder.html)? `pageBuilder`: It will replace the inviter/invitee's call view
  - [ZegoCallingBackgroundBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingBackgroundBuilder.html)? `backgroundBuilder`: background
    builder, default is a image
  - [ZegoCallButtonUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallButtonUIConfig-class.html) `cancelButton`: cancel button
    - Size? `size`
    - bool `visible`
    - Widget? `icon`
    - Size? `iconSize`
    - TextStyle? `textStyle`
- [ZegoCallInvitationInviteeUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationInviteeUIConfig.html)? `invitee`:

  - bool `showAvatar`: show avatar or not
  - bool `showCentralName`: show central name or not
  - bool `showCallingText`: show calling text or not
  - double? `spacingBetweenAvatarAndName`: spacing between avatar and name
  - double? `spacingBetweenNameAndCallingText`: spacing between name and calling text
  - [ZegoCallInvitationNotifyPopUpUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationNotifyPopUpUIConfig-class.html) `popUp`: config of call invitation pop-up dialog

    - EdgeInsetsGeometry? `padding`: popup's padding
    - double? `width`: popup's width
    - double? `height`: popup's height
    - Decoration? `decoration`: popup's decoration
    - bool `visible`:

    > when receiving an online call, whether to pop up the top pop-up dialog
    >
    > If you want to customize the invitation pop-up dialog, set
    > [visible] to false and listen
    > [ZegoUIKitPrebuiltCallInvitationEvents.onIncomingCallReceived], when
    > you receive the invitation event, show invitation widget
    >
    > ```dart
    > invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
    >   onIncomingCallReceived: (
    >     String callID,
    >     ZegoCallUser caller,
    >     ZegoCallInvitationType callType,
    >     List<ZegoCallUser> callees,
    >     String customData,
    >   ) {
    >   /// show your custom call notification
    >   },
    > ),
    > uiConfig: ZegoCallInvitationUIConfig(
    >   popUp: ZegoCallInvitationNotifyPopUpUIConfig(
    >     visible: false,
    >   ),
    > ),
    > ```
    >

    - ZegoCallInvitationNotifyDialogBuilder? `builder`:

    > custom the top pop-up dialog which receiving an online call
    >
    > ```dart
    > popUp: ZegoCallInvitationNotifyPopUpUIConfig(
    >         builder: (
    >           ZegoCallInvitationData invitationData,
    >         ) {
    >         /// show your custom popup dialog,
    >         /// and call ZegoUIKitPrebuiltCallInvitationService().accept() if you accept
    >         /// and call ZegoUIKitPrebuiltCallInvitationService().reject() if you reject
    >         },
    >       ),
    > ```
    >
  - [ZegoCallButtonUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallButtonUIConfig-class.html) `declineButton`: decline button

    - Size? `size`
    - bool `visible`
    - Widget? `icon`
    - Size? `iconSize`
    - TextStyle? `textStyle`
  - [ZegoCallButtonUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallButtonUIConfig-class.html) `acceptButton`: accept button

    - Size? `size`
    - bool `visible`
    - Widget? `icon`
    - Size? `iconSize`
    - TextStyle? `textStyle`
  - [ZegoCallingForegroundBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingForegroundBuilder.html)? `foregroundBuilder`: foreground builder
  - [ZegoCallingPageBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingPageBuilder.html)? `pageBuilder`: It will replace the inviter/invitee's call view
  - [ZegoCallingBackgroundBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallingBackgroundBuilder.html)? `backgroundBuilder`: background
    builder, default is a image

## [ZegoCallInvitationNotificationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationNotificationConfig-class.html)

- [ZegoCallIOSNotificationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallIOSNotificationConfig-class.html)? `iOSNotificationConfig`:

  - bool? `isSandboxEnvironment`: is iOS sandbox or not
  - ZegoSignalingPluginMultiCertificate `certificateIndex`: Corresponding certificate index configured by Zego console
  - String `systemCallingIconName`:

  > Customizing the icon for the iOS CallKit lock screen interface
  >
  > Below, we will using the example of setting a CallKitIcon icon, to
  > explain how to set the icon for the CallKit lock screen interface on iOS system .
  >
  > Place your icon file in the ios/Runner/Assets.xcassets/ folder, with the file name CallKitIcon.imageset.
  > When calling ZegoUIKitPrebuiltCallInvitationService.init,
  > configure the [iOSNotificationConfig.systemCallingIconName] parameter with the file name (without the file extension).
  >
  > such as :
  > iOSNotificationConfig: ZegoCallIOSNotificationConfig(
  > systemCallingIconName: 'CallKitIcon',
  > ),
  >
- [ZegoCallAndroidNotificationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallAndroidNotificationConfig-class.html)? `androidNotificationConfig`: android notification config

  - Call

    - ZegoSignalingPluginMultiCertificate `certificateIndex`: Corresponding certificate index configured by Zego console
    - String `channelID`: specify the channel id of notification, which is same in 'Zego Console'
    - String `channelName`: specify the channel name of notification, which is same in 'Zego Console'
    - String? `icon`: specify the icon file name id of notification, additionally, you must place your icon file in the following path: ${project_root}/android/app/src/main/res/drawable/${icon}.png
    - String? `sound`:

    > specify the sound file name id of notification, which is same in 'Zego Console'.
    > Additionally, you must place your audio file in the following path:
    > ${project_root}/android/app/src/main/res/raw/${sound}.mp3
    >

    - bool `vibrate`: vibrate or not
    - bool `callIDVisibility`: specify the call id show or hide
    - bool `showFullScreen`:

    > **only for offline call**, displayed in full screen or not when the screen is locked, default value is false.
    > and THE IMPORTANT IS, if set `showFullScreen` to true, then you need set `android:launchMode="singleInstance"` in `manifest/application/activity` node of `${project_root} /android/app/src/main/AndroidManifest.xml`
    >

    - bool `fullScreenBackground`:

    > If fullScreen is enabled, you can use this parameter to configure the background image
    > such as fullScreenBackground: 'assets/image/call.png'
    >
  - message(ZIMKit)

    - String `messageChannelID`: specify the channel id of message notification, which is same in 'Zego Console'
    - String `messageChannelName`: specify the channel name of message notification, which is same in 'Zego Console'
    - String? `messageIcon`: specify the icon file name id of message notification, additionally, you must place your icon file in the following path: ${project_root}/android/app/src/main/res/drawable/${icon}.png
    - String? `messageSound`: specify the sound file name id of message notification, which is same in 'Zego Console'. additionally, you must place your audio file in the following path: ${project_root}/android/app/src/main/res/raw/${sound}.mp3
    - bool `messageVibrate`: vibrate or not if message arrived

---

# [ZegoUIKitPrebuiltCallConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallConfig-class.html)

## construtors

- [`groupVideoCall`](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallConfig/ZegoUIKitPrebuiltCallConfig.groupVideoCall.html): Default initialization parameters for the group video call.
- [`groupVoiceCall`](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallConfig/ZegoUIKitPrebuiltCallConfig.groupVoiceCall.html): Default initialization parameters for the group voice call.
- [`oneOnOneVideoCall`](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallConfig/ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall.html): Default initialization parameters for the one-on-one video call
- [`oneOnOneVoiceCall`](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallConfig/ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall.html): Default initialization parameters for the one-on-one voice call

## parameters

### [ZegoUIKitVideoConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoUIKitVideoConfig-class.html) `video`

> configuration parameters for audio and video streaming, such as Resolution, Frame rate, Bit rate.
> you can set by **video = ZegoUIKitVideoConfig.presetXX()**

- parameters:

  - int `fps`: Frame rate, control the frame rate of the camera and the frame rate of the encoder.
  - int `bitrate`: Bit rate in kbps.
  - int `width`: resolution width, control the image width of camera image acquisition or encoder when publishing stream.
  - int `height`: resolution height, control the image height of camera image acquisition or encoder when publishing stream.
- construtors:

  - `preset180P`
  - `preset270P`
  - `preset360P`
  - `preset540P`
  - `preset720P`
  - `preset1080P`
  - `preset2K`
  - `preset4K`

### [ZegoCallAudioVideoViewConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallAudioVideoViewConfig-class.html) `audioVideoView`

> Configuration options for audio/video views.
>
> You can use the [ZegoUIKitPrebuiltCallConfig].[audioVideoView] property to set the properties inside this class.
>
> These options allow you to customize the display effects of the audio/video views, such as showing microphone status and usernames.
>
> If you need to customize the foreground or background of the audio/video view, you can use foregroundBuilder and backgroundBuilder.
>
> If you want to hide user avatars or sound waveforms in audio mode, you can set showAvatarInAudioMode and showSoundWavesInAudioMode to false.

- [ZegoCallAudioVideoContainerBuilder](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallAudioVideoContainerBuilder-class.html) `? containerBuilder`:

> Custom audio/video view.
> If you don't want to use the default view components, you can pass a custom component through this parameter.
>
> ```dart
> typedef ZegoCallAudioVideoContainerBuilder = Widget Function(
>  BuildContext,
>  List<ZegoUIKitUser> allUsers,
>  List<ZegoUIKitUser> audioVideoUsers,
>  /// The default audio-video view creator, you can also use [ZegoAudioVideoView] as a child control to continue encapsulating
>  ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator,
> );
> ```

- Rect Function()? `containerRect`:

> Specify the rect of the audio & video container.
> If not specified, it defaults to display full.

- bool `isVideoMirror`:

> Whether to mirror the displayed video captured by the camera.
>
> This mirroring effect only applies to the front-facing camera.
>
> Set it to true to enable mirroring, which flips the image horizontally.

- bool `showMicrophoneStateOnView`:

> Whether to display the microphone status on the audio/video view.
>
> Set it to false if you don't want to show the microphone status on the audio/video view.

- bool `showCameraStateOnView`:

> Whether to display the camera status on the audio/video view.
>
> Set it to false if you don't want to show the camera status on the audio/video view.

- bool `showUserNameOnView`:

> Whether to display the username on the audio/video view.
>
> Set it to false if you don't want to show the username on the audio/video view.

- bool `showWaitingCallAcceptAudioVideoView`:

> When inviting in calling, the invited user window will appear on the
> invitation side, if you don\'t want to show this view, set it to false.

- ZegoAudioVideoViewForegroundBuilder? `waitingCallAcceptForegroundBuilder`:

> When inviting in calling, the invited user window will appear on the invitation side,
> and you can customize the foreground at this time.

- ZegoAudioVideoViewForegroundBuilder? `foregroundBuilder`:

> You can customize the foreground of the audio/video view, which refers to the widget positioned on top of the view.
>
> You can return any widget, and we will place it at the top of the audio/video view.
>
> ```dart
> /// type of audio video view foreground builder
> typedef ZegoAudioVideoViewForegroundBuilder = Widget Function(
>  BuildContext context,
>  Size size,
>  ZegoUIKitUser? user,
>  Map<String, dynamic> extraInfo,
> );
> ```

- ZegoAudioVideoViewBackgroundBuilder? `backgroundBuilder`:

> Background for the audio/video windows in a call.
>
> You can use any widget as the background for the audio/video windows. This can be a video, a GIF animation, an image, a web page, or any other widget.
>
> If you need to dynamically change the background content, you should implement the logic for dynamic modification within the widget you return.
>
> ```dart
> /// type of audio video view background builder
> typedef ZegoAudioVideoViewBackgroundBuilder = Widget Function(
>  BuildContext context,
>  Size size,
>  ZegoUIKitUser? user,
>  Map<String, dynamic> extraInfo,
> );
> ```

- bool `useVideoViewAspectFill`:

> Video view mode.
>
> Set it to true if you want the video view to scale proportionally to fill the entire view, potentially resulting in partial cropping.
>
> Set it to false if you want the video view to scale proportionally, potentially resulting in black borders.

- bool `showAvatarInAudioMode`:

> Whether to display user avatars in audio mode.
>
> Set it to false if you don't want to show user avatars in audio mode.

- bool `showSoundWavesInAudioMode`:

> Whether to display sound waveforms in audio mode.
>
> Set it to false if you don't want to show sound waveforms in audio mode.

### [ZegoCallTopMenuBarConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallTopMenuBarConfig-class.html) `topMenuBar`

> Configuration options for the top menu bar (toolbar).
> You can use these options to customize the appearance and behavior of the top menu bar.

- bool `isVisible`: Whether to display the top menu bar.
- String `title`: Title of the top menu bar.
- bool `hideAutomatically`: Whether to automatically collapse the top menu bar after 5 seconds of inactivity.
- bool `hideByClick`: Whether to collapse the top menu bar when clicking on the blank area.
- List`<ZegoCallMenuBarButtonName>` `buttons`: Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
- `List<Widget> extendButtons`: Extension buttons that allow you to add your own buttons to the top toolbar.: These buttons will be added to the menu bar in the specified order.: If the limit of [3] is exceeded, additional buttons will be automatically added to the overflow menu.
- ZegoCallMenuBarStyle `style`: Style of the top menu bar.
- EdgeInsetsGeometry? `padding`: Padding for the top menu bar.
- EdgeInsetsGeometry? `margin`: Margin for the top menu bar.
- Color? `backgroundColor`: Background color for the top menu bar.
- double? `height`: Height for the top menu bar.

### [ZegoCallBottomMenuBarConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallBottomMenuBarConfig-class.html) `bottomMenuBar`

> Configuration options for the bottom menu bar (toolbar).
> You can use these options to customize the appearance and behavior of the bottom menu bar.

- bool `isVisible`: Whether to display the bottom menu bar.
- bool `hideAutomatically`: Whether to automatically collapse the top menu bar after 5 seconds of inactivity.
- bool `hideByClick`: Whether to collapse the top menu bar when clicking on the blank area.
- List`<ZegoCallMenuBarButtonName>` `buttons`: Buttons displayed on the menu bar. The buttons will be arranged in the order specified in the list.
- int `maxCount`:

> Controls the maximum number of buttons to be displayed in the menu bar (toolbar).
>
> When the number of buttons exceeds the `maxCount` limit, a "More" button will appear.
>
> Clicking on it will display a panel showing other buttons that cannot be displayed in the menu bar (toolbar).

- ZegoCallMenuBarStyle `style`: Button style for the bottom menu bar.
- EdgeInsetsGeometry? `padding`: Padding for the bottom menu bar.
- EdgeInsetsGeometry? `margin`: Margin for the bottom menu bar.
- Color? `backgroundColor`: Background color for the bottom menu bar.
- double? `height`: Height for the bottom menu bar.
- List`<Widget>` `extendButtons`:

> Extension buttons that allow you to add your own buttons to the top toolbar.
>
> These buttons will be added to the menu bar in the specified order.
>
> If the limit of `maxCount` is exceeded, additional buttons will be automatically added to the overflow menu.

### [ZegoCallMemberListConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallMemberListConfig-class.html) `memberList`

> Configuration related to the bottom member list, including displaying the member list, member list styles, and more.

- bool `showMicrophoneState`: Whether to show the microphone state of the member. Defaults to true, which means it will be shown.
- bool `showCameraState`:

> Whether to show the camera state of the member.
>
> Defaults to true, which means it will be shown.

- ZegoMemberListItemBuilder? `itemBuilder`: Custom member list item view.

### [ZegoBeautyPluginConfig](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginConfig-class.html)? `beauty`

> advance beauty config

- List\<[ZegoBeautyPluginEffectsType](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginEffectsType.html)\> `effectsTypes`
- [ZegoBeautyPluginInnerText](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginInnerText-class.html) `innerText`
- [ZegoBeautyPluginUIConfig](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginUIConfig-class.html) `uiConfig`:

  - Color? `backgroundColor`
  - Color? `selectedIconBorderColor`
  - Color? `selectedIconDotColor`
  - TextStyle? `selectedTextStyle`
  - TextStyle? `normalTextStyle`
  - TextStyle? `sliderTextStyle`
  - Color? `sliderTextBackgroundColor`
  - Color? `sliderActiveTrackColor`
  - Color? `sliderInactiveTrackColor`
  - Color? `sliderThumbColor`
  - double? `sliderThumbRadius`
  - Widget? `backIcon`
  - TextStyle? `normalHeaderTitleTextStyle`
  - TextStyle? `selectHeaderTitleTextStyle`
- String? `segmentationBackgroundImageName`: backgroundPortraitSegmentation feature need use this path.
- bool `enableFaceDetection`: if true, can use getFaceDetection to notify face detection.
- [ZegoBeautyPluginSegmentationScaleMode](https://pub.dev/documentation/zego_plugin_adapter/latest/zego_plugin_adapter/ZegoBeautyPluginSegmentationScaleMode.html) `segmentationScaleMode`

### [ZegoCallDurationConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallDurationConfig-class.html) `duration`

> Call timing configuration.

- bool `isVisible`: Whether to display call timing.
- void Function(Duration)? `onDurationUpdate`: Call timing callback function, called every second.

> Example: Set to automatically hang up after 5 minutes.
>
> ```dart
> ..duration.isVisible = true
> ..duration.onDurationUpdate = (Duration duration) {
>  if (duration.inSeconds >= 5 * 60) {
>    callController?.hangUp(context);
>  }
> }
> ```

### [ZegoCallInRoomChatViewConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInRoomChatViewConfig-class.html) `chatView`

> Configuration related to the bottom-left message list.

- ZegoInRoomMessageItemBuilder? `itemBuilder`:

> Use this to customize the style and content of each chat message list item.
>
> For example, you can modify the background color, opacity, border radius, or add additional information like the sender's level or role.
>
> ```dart
> /// Chat message list builder for customizing the display of chat messages.
> typedef ZegoInRoomMessageItemBuilder = Widget Function(
>  BuildContext context,
>  ZegoInRoomMessage message,
>  Map<String, dynamic> extraInfo,
> );
> ```

### [ZegoCallUserConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallUserConfig-class.html) `user`

> config about users.

- [ZegoCallRequiredUserConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallRequiredUserConfig-class.html) `requiredUsers`:

> Necessary user to participate in the call.
>
> If the participant have not joined after [requiredParticipantCheckTimeoutSeconds] after entering the call,
> the call will be triggered [ZegoUIKitPrebuiltCallEvents.onCallEnd] with [ZegoCallEndReason.abandoned]

- bool `enabled`: is enable detection or not
- int `detectSeconds`:

> The time to start the detection, when it arrives, it will start to detect whether all members have entered the call.
>
> Note that this duration cannot be too short,
> otherwise if the remote users enters the call relatively late under poor
> network conditions, it will cause current call to be ended.

- List\<ZegoUIKitUser\> `users`:

> Necessary participants to participate in the call.
>
> If the participant have not joined after [detectSeconds] after entering the call,
> the call will be triggered to end by
> [ZegoUIKitPrebuiltCallEvents.onCallEnd] with [ZegoCallEndReason.abandoned]
>
> Usually, you DON'T need to specify.
> By default, in the 1v1 call scenario, we will set [users] as the Caller(Inviter) of the cal.

- bool `detectInDebugMode`:

> Is detection of [participants] enabled in debugging mode?
>
> Due to hitting breakpoints during debugging, it is easy to cause
> timeout issues([checkTimeoutSeconds] is timeout),
> which can lead to call exits

### [ZegoCallHangUpConfirmDialogConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallHangUpConfirmDialogConfig-class.html)? `hangUpConfirmDialog`

> Confirmation dialog when hang up the call.
>
> - `ZegoCallHangUpConfirmDialogInfo? info`:
>   dialog information,
>   If not set, clicking the exit button will directly exit the call.
>   If set, a confirmation dialog will be displayed when clicking the exit button, and you will need to confirm the exit before actually exiting.
> - `TextStyle? titleStyle`: title text style
> - `TextStyle? contentStyle`: content text style
> - `TextStyle? actionTextStyle`: action button text style
> - `Brightness? backgroundBrightness`: background brightness

### Map<String, String> `advanceConfigs`

> Set advanced engine configuration, Used to enable advanced functions.
>
> For details, please consult ZEGO technical support.

### bool `turnOnCameraWhenJoining`

> Whether to open the camera when joining the call.
>
> If you want to join the call with your camera closed, set this value to false;
>
> if you want to join the call with your camera open, set this value to true.
>
> The default value is `true`.

### bool `turnOnMicrophoneWhenJoining`

> Whether to open the microphone when joining the call.
>
> If you want to join the call with your microphone closed, set this value to false;
>
> if you want to join the call with your microphone open, set this value to true.
>
> The default value is `true`.

### bool `useSpeakerWhenJoining`

> Whether to use the speaker to play audio when joining the call.
>
> The default value is `false`, but it will be set to `true` if the user is in a group call or video call.
>
> If this value is set to `false`, the system's default playback device, such as the earpiece or Bluetooth headset, will be used for audio playback.

### [ZegoLayout](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoLayout.html) `layout`

> Layout-related configuration. You can choose your layout here.

### Widget? `foreground`

> The foreground of the call.
>
> If you need to nest some widgets in [ZegoUIKitPrebuiltCall], please use [foreground] nesting, otherwise these widgets will be lost when you minimize and restore the [ZegoUIKitPrebuiltCall]

### Widget? `background`

> The background of the call.
>
> You can use any Widget as the background of the call, such as a video, a GIF animation, an image, a web page, etc.
>
> If you need to dynamically change the background content, you will need to implement the logic for dynamic modification within the Widget you return.
>
> ```dart
> ..background = Container(
>    width: size.width,
>    height: size.height,
>    decoration: const BoxDecoration(
>      image: DecorationImage(
>        fit: BoxFit.fitHeight,
>        image: ,
>      )));
> ```

### [ZegoAvatarBuilder](https://pub.dev/documentation/zego_uikit/latest/zego_uikit/ZegoAvatarBuilder.html)? `avatarBuilder`

> Use this to customize the avatar, and replace the default avatar with it.
>
> Example：
>
> ```dart
> // eg:
> avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
>  return user != null
>      ? Container(
>          decoration: BoxDecoration(
>            shape: BoxShape.circle,
>            image: DecorationImage(
>              image: NetworkImage(
>                'https://your_server/app/avatar/${user.id}.png',
>              ),
>            ),
>          ),
>        )
>      : const SizedBox();
> },
> ```

### bool `rootNavigator`

> same as Flutter's Navigator's param
>
> If `rootNavigator` is set to true, the state from the furthest instance of this class is given instead.
>
> Useful for pushing contents above all subsequent instances of [Navigator].
