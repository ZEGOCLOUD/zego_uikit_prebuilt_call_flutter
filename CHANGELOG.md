## 4.14.3

- Update dependency

## 4.14.2

- Bugs
  - Fix the issue of offline receive failure caused by android/iOS certificate indexing error

## 4.14.1

- Update dependency


## 4.14.0

- Features
  - Added `ZegoUIKitPrebuiltCallMiniPopScope` to protect the interface from being destroyed when minimized
  - Added `license` in `ZegoBeautyPluginConfig` to setting license to beauty

## 4.13.1

- Update dependency

## 4.13.0

- Features
  - Support login by token

## 4.12.11

- Bugs
  - Fix the issue that there is no pop-up box for offline calls after enabling the foreground service in Android.

## 4.12.10

- Bugs
  - Fix call-id being modified midway

## 4.12.9

- Bugs
  - Fix the issue of invitee name loss in invitation-related callbacks

## 4.12.6-4.12.8

- Update documents.
  
## 4.12.5

- Bugs
  - Fix the issue of not entering a call due to offline call timing in IOS
  
## 4.12.4

- Bugs
  - Fix the issue of not entering a call directly when accept the offline call in Android

## 4.12.3

- Bugs
  - try fix the issue of not entering a call due to offline call timing in IOS

## 4.12.2

- Bugs
  - Fix crash on normal call

## 4.12.1

- Bugs
  - Fixing the issue of failed invitations in certain scenarios.

## 4.12.0

- Features
  - Support inviting users in calling by setting **canInvitingInCalling** to true when `ZegoUIKitPrebuiltCallInvitationService.init`, see [Doc](https://www.zegocloud.com/docs/uikit/callkit-flutter/invitation-config/invitation-in-calling) for effects and steps. ⚠️⚠️⚠️  **If you use this feature, the invitation feature will no longer be compatible with 
    version before v4.12.0, that is mean, invitations will not be received between each other**.  

  
## 4.11.4-4.11.8

- Update dependency.
- Bugs
  - Fix namespace error after grade v8.0
  
## 4.11.3

- Update dependency.

## 4.11.2

- Update dependency.

## 4.11.1

- Features
  - Add `spacingBetweenAvatarAndName` and `spacingBetweenNameAndCallingText`  in the `ZegoCallInvitationInviterUIConfig` and `ZegoCallInvitationInviteeUIConfig`

## 4.11.0

- Features
  - Parameters in the `ZegoCallInvitationInviterUIConfig` is placed in `inviter` and `invitee` according to the role; at the same time.💥 [breaking changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#4110)
  - `showAvatar`, `showCentralName` and `showCallingText` are added in the `inviter` and `invitee` of `ZegoCallInvitationInviterUIConfig`.

## 4.10.0

- Features
  - Add `callingPageBuilder` in `ZegoCallInvitationConfig`, now you can customize the entire calling view if you want.
  - Add `callingForegroundBuilder` in `ZegoCallInvitationConfig`, you can add some custom controls on the foreground of the calling view

## 4.9.1

- Bugs
  - Fix the issue that the invitee hangs up at the same time when the invitee answers, causing the invitee to make a call alone. It is not enabled by default, but can be enabled by 
    [ZegoUIKitPrebuiltCallConfig.user.requiredUsers.enabled].

## 4.9.0

- Features
  - Add `callID` in `ZegoUIKitPrebuiltCallEvents.onCallEnd.event`

## 4.8.5

- Update dependency.

## 4.8.4

- Update doc.

## 4.8.3

- Update dependency.

## 4.8.2

- Update dependency.

## 4.8.1

- Update dependency.

## 4.8.0

- Features
  - Configs
    - Support customizing the **display area of the audio video container** through `ZegoUIKitPrebuiltCallConfig.audioVideoView.containerRect`
    - `ZegoCallAudioVideoContainerBuilder` adds the `ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator` parameter to construct the **default audio & video view widget**💥 [breaking changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#480)
    - Support hiding the bottom toolbar through `ZegoUIKitPrebuiltCallConfig.bottomMenuBar.isVisible`
  - Controller
    - Add **audioVideo** in `ZegoUIKitPrebuiltCallController()`, which can access the APIs and callbacks related to camera, microphone, and audioOutput
    - Add **user** in `ZegoUIKitPrebuiltCallController()`
  - Events
    - `ZegoUIKitPrebuiltCallEvents.audioVideo` adds the event for device exception status
- Bugs
  - Fixed the issue where the default call id was missing the user id in the first call of `ZegoSendCallInvitationButton`

## 4.7.3

- Update dependency.

## 4.7.2

- Bugs
  - Fixed the issue of events being lost after back from minimization

## 4.7.1

- Update dependency.

## 4.7.0

- Features
  - Support pure audio call invitations without popping up the camera's request permission dialog. [Document](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationConfig/permissions.html)

## 4.6.0

- Features
  - Support customize full screen background.

## 4.5.4

- Bugs
  - fix offline accept issue.(in 4.5.2~4.5.3)

## 4.5.3

 - update deps.

## 4.5.2

- Bugs
  - Fix: background isolate destroying zim unexpectedly issue.

## 4.5.1

- Bugs
  - Fix the issue of automatically accepting call due to FCM.

## 4.5.0

- Features
  - Support audio effects.

## 4.4.3

- Update dependency.

## 4.4.2

- Bugs
  - Ignore with non-uikit notification protocols

## 4.4.1

- Update dependency.

## 4.4.0

- Features
  - Support setting hang-up dialog box style by `ZegoUIKitPrebuiltCallConfig.hangUpConfirmDialog`
  - move API in `ZegoUIKitPrebuiltCallConfig.hangUpConfirmDialogInfo` to `ZegoUIKitPrebuiltCallConfig.hangUpConfirmDialog.info` [migrate changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#440)

## 4.3.2

- Bugs
  - Fix the issue of minimize window no closed by default when remote user end call
  - Fix the issue of the android return button will directly end call when return to the large call page from minimizing page

## 4.3.1

- Bugs
  - Fix bugs.

## 4.3.0

- Features
  - Support full-screen display configuration for offline notification under screen locked, see [Document](https://zegocloud.spreading.io/doc/callkit/Call%20Kit/main/Invitation%20config/Enable%20fullscreen%20incoming%20call/2886fbb3)

## 4.2.5

- Update dependency.

## 4.2.4

- Update dependency.

## 4.2.3

- Bugs
  - Fix the issue of ineffective clicking in a portion of the top toolbar buttons.

## 4.2.2

- Bugs
  - Fix the issue of updating innerText by **ZegoUIKitPrebuiltCallInvitationService.innerText** before **ZegoUIKitPrebuiltCallInvitationService.init()** being called.

## 4.2.1

- Update documents

## 4.2.0

- Support custom invitation UI by [ZegoCallInvitationUIConfig](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/zego_uikit_prebuilt_call/ZegoCallInvitationUIConfig-class.html)

## 4.1.10

- move API in `ZegoUIKitPrebuiltCallController().invitation` to `ZegoUIKitPrebuiltCallInvitationService()` [migrate changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#4110)
- rename some variables. [migrate guide](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#4110).

- Add configs document

## 4.1.9

- rename some variables. [migrate guide](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#419).

- Update documents

## 4.1.8

- Update documents

## 4.1.7

- Update documents

## 4.1.6

- Bugs
  - Fix issue of the margin/size parameter not taking effect in PIP layout

## 4.1.5

- Bugs
  - Fix issue of missing `customData` in the sending end of `ZegoCallInvitationData` in `requireConfig` within Call Invitation.

## 4.1.4

- > 
> add **defaultAction** in `onHangUpConfirmation`
>
> 💥 [breaking changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#414)

- Update dependency.

## 4.1.3

- Update dependency.

## 4.1.2

- Update dependency.

## 4.1.1

- Optimization warnings from analysis

## 4.1.0

- Support for configurable streaming video and automatic adjustment based on traffic control.

## 4.0.1

- Update documents

## 4.0.0

- >
> The 4.0 version has standardized and optimized the API and Event, simplifying the usage of most APIs.
>
> Most of the changes involve modifications to the calling path, such as changing from ZegoUIKitPrebuiltCallController().isMinimizing() to ZegoUIKitPrebuiltCallController().minimize.isMinimizing.
>
> 💥 [breaking changes](https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_v4.x-topic.html#400)

- Support user/room/audioVideo series events

## 3.18.4

- Update dependency.

## 3.18.3

- Bugs
  - Fix the issue of video shaking caused by chat input.

## 3.18.2

- Bugs
  - Fix the issue where the user window disappears after both the camera and microphone are turned off

## 3.18.1

- Bugs
  - Fix the issue of setting the icon for message offline notifications failure.

## 3.18.0

- Support setting background in invitation views, you can use **uiConfig.callingBackgroundBuilder** in **ZegoUIKitPrebuiltCallInvitationService.init**.

## 3.17.11

- Update dependency.

## 3.17.10

- Update dependency.

## 3.17.9

- Update dependency.

## 3.17.8

- Bugs
  - Fixing some bugs in offline calling on iOS.
  - Fixing the exception issue when kicking user out by server api.

## 3.17.7

- Update dependency.

## 3.17.6

- Optimization warnings from analysis

## 3.17.5

- Bugs
  - Fixing video/audio display issues for iOS VOIP calls.

## 3.17.4

- Bugs
  - Fixed the issue where hang up from a call invitation would result in going back to the previous page twice when **onHangUp** is overridden.

  💥 Reminder: If you override **onHangUp**, please remember to **return to the previous page**, such as use Navigator.of(context).pop().
- Constrain the APIs call of **ZegoUIKitPrebuiltCallMiniOverlayMachine**, only use certain public methods.

## 3.17.3

- Optimization warnings from analysis

## 3.17.2

- Features
  - Compatible offline messages from with zego_zimkit.
- Bugs
  - Fixed some bugs
- Update dependency

## 3.17.1

- Update dependency.

## 3.17.0

- Support foreground/background in config，if you need to nest some widgets in **ZegoUIKitPrebuiltCall**, please use **foreground**/**background** nesting, otherwise these widgets will be lost when you
  minimize and restore the **ZegoUIKitPrebuiltCall**

## 3.16.3

- Bugs
  - Fixing the issue of notification not set correctly initialize.

## 3.16.2

- Optimization warnings from analysis

## 3.16.1

- Optimization warnings from analysis

## 3.16.0

- Support listening for errors in the signaling plugins and uikit library.

## 3.15.7

- Fix the issue of not receiving offline call after canceling by caller
- About offline call on iOS, whether in sandbox or production environment, will be automatically selected internal and no longer require manual assignment by **iOSNotificationConfig.
  isSandboxEnvironment**.

## 3.15.6

- Update dependency.

## 3.15.5

* Optimize the Android online notification style

## 3.15.4

* remove **awesome_notifications** library
* Fixed some bugs
* update dart dependency

## 3.15.3

- Update dependency.

## 3.15.2

- Update dependency.

## 3.15.1

- Fix the issue of call cancellation on the calling end, where the call fails to be accepted by the receiving end after calling again.

## 3.15.0

- Add three invitation-related interfaces to ZegoUIKitPrebuiltCallController: cancelCallInvitation, rejectCallInvitation, and acceptCallInvitation. These interfaces can be used in conjunction with
  sendCallInvitation.
- Add onInvitationUserStateChanged to ZegoUIKitPrebuiltCallInvitationEvents. This callback will be triggered to the caller or callee of the ongoing call invitation when the other callee accepts,
  rejects, exits, or when the response times out.

## 3.14.0

- Support close callKit popup programmatically for the offline callee when the caller cancels the call.

## 3.13.5

- Update dependency.

## 3.13.4

- Fix the issue where canceling offline calls is not effective on the callee side

## 3.13.3

- Fix the exception that may arise from a null pointer.

## 3.13.2

- Fix the exception that may arise from a null pointer.

## 3.13.1

- Fix the issue of call notifications not appearing when the screen is locked.

## 3.13.0

- Add **advanceConfigs** config, which to set advanced engine configuration

## 3.12.3

- Fix the issue where can no longer receive offline calls after rejecting them.

## 3.12.2

- Fix the issue of multiple initialization of notifications.
- update dependency

## 3.12.1

- Fix the issue of context being destroyed and resulting in a bunch of NullPointerExceptions when continuously calling **ZegoUIKitPrebuiltCallInvitationService.init**. you should call
  **ZegoUIKitPrebuiltCallInvitationService.init** after the successful login of the App user, and call **ZegoUIKitPrebuiltCallInvitationService.uninit** before the successful logout of the App user.

## 3.12.0

- Support chat, you can add **ZegoMenuBarButtonName.chatButton** to **ZegoBottomMenuBarConfig.buttons** to enable.

## 3.11.1

- Fixed the configuration error for incoming and outgoing ringtone.

## 3.11.0

- Support hiding the cancel button of caller. You can configure the **showCancelInvitationButton** parameter in the **init** method of **ZegoUIKitPrebuiltCallInvitationService**.

## 3.10.7

- Fixed the issue of not receiving calls when prebuilt_call is used in conjunction with prebuilt_live_audio_room or prebuilt_live_streaming. you also need to update prebuilt_live_audio_room to
  version v2.8.4 or prebuilt_live_streaming to v2.12.9.

## 3.10.6

- Fixed issues with calling on iOS while the device is locked.

## 3.10.5

- Fixed the issue where audio playback was not working in the App due to changes in the **prefix** path when using **audioplayers**.
- Update **audioplayers** dependency

## 3.10.4

- Fix the issue of incorrect microphone status in the bottom-right corner of the screen for users in PIP view.
- Fix the problem of delayed CallKit pop-up dismissal for offline calls in silent push mode.
- Update **shared_preferences** dependency

## 3.10.3

- Fixed the issue of the name of the small video window not being fully displayed due to its length.

## 3.10.2

- Fixed the issue of the name of the small video window not being fully displayed due to its length.

## 3.10.1

- update dependency

## 3.10.0

- Fixed the issue of the name of the small video window not being fully displayed due to its length.
- Added support for hiding the icon in the **ZegoSendCallInvitationButton**.
- Added margin, padding, and border radius style properties to the **ZegoSendCallInvitationButton**.

## 3.9.2

- Fix some issues

## 3.9.1

- Fix the iOS offline call rejection issue.

## 3.9.0

- Supports offline push between two apps
- Support refuse offline call

## 3.8.1

- update dependency

## 3.8.0

- Support advance beauty

## 3.7.1

- Update ReadMe.

## 3.7.0

- Compatible for Android immersive navigation to the top and bottom toolbars.
- Support for setting the style of the top and bottom toolbars by allowing customization of padding, margin, background color, and height.

## 3.6.3

- Fix the issue of offline notifications' title and message on Android.

## 3.6.2

- Optimize the methods exposed by ZegoUIKitPrebuiltCallInvitationService.

## 3.6.1

- Use awesome notification to display call pop-ups in Android's background mode, fixing the issue where Android devices couldn't enter a call after clicking on the notification in the background mode.

## 3.6.0

- Added logic for being kicked out of the call, which will automatically exit and return to the previous page.

## 3.5.2

- update dependency

## 3.5.1

- Fix the issue of custom sound not working for offline push notifications.

## 3.5.0

- `ZegoSendCallInvitationButton` supports custom `call ID`, and `onWillPressed` is added to support custom processing before calling.

## 3.4.0

- Add a `customData` parameter to `ZegoUIKitPrebuiltCallInvitationEvents`.`onIncomingCallReceived` function. The `customData` is sourced from the additional data attached when initiating a call
  invitation using `ZegoSendCallInvitationButton` or `ZegoUIKitPrebuiltCallController`.`sendCallInvitation`.

## 3.3.21

- Fixed an issue where the avatar was not displayed in the call invitation pop-up.

## 3.3.20

- update dependency

## 3.3.19

- fix the issue of conflict with extension key of the `flutter_screenutil` package.

## 3.3.18

- fix for the issue caused by SystemChannels.lifecycle.setMessageHandler leading to the failure of app-side didChangeAppLifecycleState.

## 3.3.17

- fix the issue that the user does not log in caused by the app staying in the background for a long time
- fix some user login status issues when used `zego_uikit_prebuilt_call` with `zego_zimkit`

## 3.3.16

- update comments

## 3.3.15

- update dependencies

## 3.3.14

- update comments

## 3.3.13

- update dependencies

## 3.3.12

- deprecate flutter_screenutil_zego package

## 3.3.11

- fix the issue of inability to open notification permissions on Android OS version 13+.

## 3.3.10

- fix the issue where the video button is displayed incorrectly when minimizing the app during a voice call.

## 3.3.9

- support close duration in config

## 3.3.8

- add a "hangUp" method to the controller that allows for actively ending the current call.
- support tracking the duration of the call locally.

## 3.3.7

- Update dependencies

## 3.3.6

- Update dependencies

## 3.3.5

- Fix some issues about iOS supports VoIP mode.

## 3.3.4

- Fix the issue with show notification box crashing when received a call background in iOS

## 3.3.3

- Fix the issue of missed call notifications not popping up when the app is in the background.

## 3.3.2

- mark 'appDesignSize' as Deprecated

## 3.3.1

- Update dependencies

## 3.3.0

- To differentiate the 'appDesignSize' between the App and ZegoUIKitPrebuiltCall, we introduced the 'flutter_screenutil_zego' library and removed the 'appDesignSize' parameter from the
  ZegoUIKitPrebuiltCall that was previously present.

## 3.2.0

- For the offline calling feature, Android supports a silent push mode, while iOS supports VoIP mode.

## 3.1.1

- Optimize the in-app minimization feature and add control for local camera and microphone; display the camera and microphone status of others; display user names.

## 3.1.0

- supports in-app minimization.

## 3.0.3

- fixed appDesignSize for ScreenUtil that didn't work

## 3.0.2-dev.1

- add sendCallInvitation function in ZegoUIKitPrebuiltCallController

## 3.0.1-dev.1

- onOutgoingCallRejectedCauseBusy and onOutgoingCallDeclined, these two event are trigger wrong

## 3.0.0-dev.1

- ZegoUIKitPrebuiltCallWithInvitation Widget class is deprecated, replace by a singleton instance ZegoUIKitPrebuiltCallInvitationService

## 2.1.3

- add assert to key parameters to ensure prebuilt run normally

## 2.1.2

- Fixed landscape not displaying full web screen sharing content

## 2.1.1

- update dependency

## 2.1.0

- support screen share

## 2.0.1

* add appDesignSize for ScreenUtil in prebuilt param, if you use ScreenUtil, prebuilt will restore the param when dispose
* remove login token
* optimizing code warnings

## 2.0.0

* Architecture upgrade based on adapter.

## 1.4.3

* downgrade flutter_screenutil to ">=5.5.3+2 <5.6.1"

## 1.4.2

* Fixed some bugs

## 1.4.1

* Fixed some bugs

## 1.4.0

* support offline call
* support sdk log

## 1.2.14

* update a dependency to the latest release

## 1.2.13

* update a dependency to the latest release

## 1.2.12

* update a dependency to the latest release

## 1.2.11

* update a dependency to the latest release

## 1.2.10

* Fixed some bugs

## 1.2.9

* rename ZegoUIKitPrebuiltCallInvitationService to ZegoUIKitPrebuiltInvitationCall
* update a dependency to the latest release

## 1.2.8

* update a dependency to the latest release

## 1.2.7

* fix gallery layout

## 1.2.6

* Fixed some bugs

## 1.2.5

* update a dependency to the latest release

## 1.2.4

* Fixed some bugs

## 1.2.3

* Fixed some bugs

## 1.2.2

* update a dependency to the latest release

## 1.2.1

* Fixed some bugs

## 1.2.0

* support group call

## 1.1.4

* Fixed some bugs

## 1.1.3

* Fixed some bugs

## 1.1.2

* Fixed some bugs

## 1.1.1

* update a dependency to the latest release

## 1.1.0

* support group call
* Fixed some bugs

## 1.0.3

* Fixed some bugs

## 1.0.2

* Fixed some bugs

## 1.0.1

* Fixed some bugs
* update a dependency to the latest release

## 1.0.0

* Congratulations!

## 0.0.5

* Fixed some bugs
* update ZegoUIKitPrebuiltCallConfig

## 0.0.4

* Fixed some bugs

## 0.0.3

* Fixed some bugs
* remove **serverSecret** in init function
* update a dependency to the latest release

## 0.0.2

* update some documents

## 0.0.1

* Upload Initial release.
