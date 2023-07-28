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
- Add a `customData` parameter to `ZegoUIKitPrebuiltCallInvitationEvents`.`onIncomingCallReceived` function. The `customData` is sourced from the additional data attached when initiating a call invitation using `ZegoSendCallInvitationButton` or `ZegoUIKitPrebuiltCallController`.`sendCallInvitation`.

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

* fix some bugs

## 1.4.1

* fix some bugs

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

* fix some bugs

## 1.2.9

* rename ZegoUIKitPrebuiltCallInvitationService to ZegoUIKitPrebuiltInvitationCall
* update a dependency to the latest release

## 1.2.8

* update a dependency to the latest release

## 1.2.7

* fix gallery layout

## 1.2.6

* fix some bugs

## 1.2.5

* update a dependency to the latest release

## 1.2.4

* fix some bugs

## 1.2.3

* fix some bugs

## 1.2.2

* update a dependency to the latest release

## 1.2.1

* fix some bugs

## 1.2.0

* support group call

## 1.1.4

* fix some bugs

## 1.1.3

* fix some bugs

## 1.1.2

* fix some bugs

## 1.1.1

* update a dependency to the latest release

## 1.1.0

* support group call
* fix some bugs

## 1.0.3

* fix some bugs

## 1.0.2

* fix some bugs

## 1.0.1

* fix some bugs
* update a dependency to the latest release

## 1.0.0

* Congratulations!

## 0.0.5

* fix some bugs
* update ZegoUIKitPrebuiltCallConfig

## 0.0.4

* fix some bugs

## 0.0.3

* fix some bugs
* remove **serverSecret** in init function
* update a dependency to the latest release

## 0.0.2

* update some documents

## 0.0.1

* Upload Initial release.
