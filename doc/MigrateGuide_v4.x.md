
>
> This document aims to help users understand the APIs changes and feature improvements, and provide a migration guide for the upgrade process.
>
> <br />
>
> It is an `incompatible change` if marked with `breaking changes`.
> All remaining changes is compatible and uses the deprecated prompt. Of course, it will also be completely abandoned in the version after a certain period of time.
>
> <br />
>
> You can run this command in `the root directory of your project` to output warnings and partial error prompts to assist you in finding deprecated parameters/functions or errors after upgrading.
> ```shell
> dart analyze | grep zego
> ```


<br />
<br />

# Versions

- [4.12.0](#4120)
- [4.11.0](#4110)  **(💥 breaking changes)**
- [4.8.0](#480)  **(💥 breaking changes)**
- [4.4.0](#440)
- [4.2.0](#420)
- [4.1.10](#4110-2)
- [4.1.9](#419)
- [4.1.4](#414)  **(💥 breaking changes)**
- [4.0.0](#400)  **(💥 breaking changes)**

<br />
<br />

# 4.12.0
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.11.+ to the latest 4.12.0 version.

# Major Interface Changes
    - rename **ZegoCallType** to `ZegoCallInvitationType`


# 4.11.0
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.10.+ to the latest 4.11.0 version.

# Major Interface Changes

- ZegoCallInvitationUIConfig
  - inviter  
    - move **cancelButton** to `ZegoCallInvitationUIConfig.inviter`
    - rename **callingForegroundBuilder** to `ZegoCallInvitationUIConfig.inviter.foregroundBuilder`
    - rename **callingPageBuilder** to `ZegoCallInvitationUIConfig.inviter.pageBuilder`
    - rename **callingBackgroundBuilder** to `ZegoCallInvitationUIConfig.inviter.backgroundBuilder`
  - invitee
    - move **declineButton** to `ZegoCallInvitationUIConfig.invitee`
    - move **acceptButton** to `ZegoCallInvitationUIConfig.invitee`
    - move **popUp** to `ZegoCallInvitationUIConfig.invitee`
    - rename **callingForegroundBuilder** to `ZegoCallInvitationUIConfig.invitee.foregroundBuilder`
    - rename **callingPageBuilder** to `ZegoCallInvitationUIConfig.invitee.pageBuilder`
    - rename **callingBackgroundBuilder** to `ZegoCallInvitationUIConfig.invitee.backgroundBuilder`
    <details>
    <summary>Migrate Guide</summary>

  > Modify your code based on the following guidelines to make it compatible with version 4.11.0:
  >
  > 4.10.+ Version Code:
  >
  >```dart
  > ZegoUIKitPrebuiltCallInvitationService().init(
  >   ...
  >   uiConfig: ZegoCallInvitationUIConfig(
  >     acceptButton: ZegoCallButtonUIConfig(),
  >     declineButton: ZegoCallButtonUIConfig(),
  >     callingForegroundBuilder: (
  >       BuildContext context,
  >       Size size,
  >       ZegoCallingBuilderInfo info,
  >     ) {},
  >     callingPageBuilder: (
  >       BuildContext context,
  >       ZegoCallingBuilderInfo info,
  >     ) {},
  >     callingBackgroundBuilder: (
  >       BuildContext context,
  >       Size size,
  >       ZegoCallingBuilderInfo info,
  >     ) {},
  >   ),
  > );
  > }
  >```
  >
  >4.11.0 Version Code:
  >
  >```dart
  > ZegoUIKitPrebuiltCallInvitationService().init(
  >   ...
  >   uiConfig: ZegoCallInvitationUIConfig(
  >     inviter: ZegoCallInvitationInviterUIConfig(
  >       cancelButton: ZegoCallButtonUIConfig(),
  >       foregroundBuilder: (
  >         BuildContext context,
  >         Size size,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >       pageBuilder: (
  >         BuildContext context,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >       backgroundBuilder: (
  >         BuildContext context,
  >         Size size,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >     ),
  >     invitee: ZegoCallInvitationInviteeUIConfig(
  >       acceptButton: ZegoCallButtonUIConfig(),
  >       declineButton: ZegoCallButtonUIConfig(),
  >       foregroundBuilder: (
  >         BuildContext context,
  >         Size size,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >       pageBuilder: (
  >         BuildContext context,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >       backgroundBuilder: (
  >         BuildContext context,
  >         Size size,
  >         ZegoCallingBuilderInfo info,
  >       ) {},
  >     ),
  >   ),
  > );
  > }
  >```

    </details>

<br />
<br />


# 4.8.0
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.7.+ to the latest 4.8.0 version.

# Major Interface Changes

- ZegoCallAudioVideoViewConfig
    - add **audioVideoViewCreator** in `ZegoCallAudioVideoContainerBuilder(type of containerBuilder)`
    <details>
    <summary>Migrate Guide</summary>
    
    > Modify your code based on the following guidelines to make it compatible with version 4.8.0:
    >
    > 4.7.+ Version Code:
    >
    >```dart
    >typedef ZegoCallAudioVideoContainerBuilder = Widget Function(
    >  BuildContext,
    >  List<ZegoUIKitUser> allUsers,
    >  List<ZegoUIKitUser> audioVideoUsers,
    >);
    >```
    >
    >4.8.0 Version Code:
    >
    >```dart
    >typedef ZegoCallAudioVideoContainerBuilder = Widget? Function(
    >BuildContext context,
    >List<ZegoUIKitUser> allUsers,
    >List<ZegoUIKitUser> audioVideoUsers,
    >
    >/// The default audio-video view creator, you can also use [ZegoAudioVideoView] as a child control to continue encapsulating
    >ZegoAudioVideoView Function(ZegoUIKitUser) audioVideoViewCreator,
    >);
    >```
    
    </details>

<br />
<br />


# 4.4.0
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.3.2 to the latest 4.4.0 version.

# Major Interface Changes

- ZegoUIKitPrebuiltCallConfig
  - move **hangUpConfirmDialogInfo** to `hangUpConfirmDialog?.dialogInfo`

<br />
<br />


# 4.2.0
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.1.10 to the latest 4.2.0 version.

# Major Interface Changes

- ZegoCallInvitationUIConfig
  - move **showDeclineButton** to `declineButton.visible`
  - move **showCancelInvitationButton** to `cancelButton.visible`
- ZegoCallRingtoneConfig
  - remove useless parameters `packageName`

<br />
<br />


# 4.1.10
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.1.9 to the latest 4.1.10 version.

# Major Interface Changes

- rename **ZegoUIKitCallEndReason** to `ZegoCallEndReason`
- rename **ZegoUIKitCallHangUpConfirmationEvent** to `ZegoCallHangUpConfirmationEvent`
- rename **ZegoUIKitCallEndEvent** to `ZegoCallEndEvent`
- rename **ZegoUIKitPrebuiltCallRoomEvents** to `ZegoCallRoomEvents`
- rename **ZegoUIKitPrebuiltCallAudioVideoEvents** to `ZegoCallAudioVideoEvents`
- rename **ZegoUIKitPrebuiltCallUserEvents** to `ZegoCallUserEvents`
- rename **CallEndCallback** to `ZegoCallEndCallback`
- rename **CallHangUpConfirmationCallback** to `ZegoCallHangUpConfirmationCallback`
- rename **ZegoMenuBarStyle** to `ZegoCallMenuBarStyle`
- rename **ZegoAndroidNotificationConfig** to `ZegoCallAndroidNotificationConfig`
- rename **ZegoIOSNotificationConfig** to `ZegoCallIOSNotificationConfig`
- rename **ZegoRingtoneConfig** to `ZegoCallRingtoneConfig`
- rename **PrebuiltConfigQuery** to `ZegoCallPrebuiltConfigQuery`
- rename **ZegoInvitationType** to `ZegoCallType`
- rename **ZegoMiniOverlayPage** to `ZegoUIKitPrebuiltCallMiniOverlayPage`

>
>

- move API in `ZegoUIKitPrebuiltCallController().invitation` to `ZegoUIKitPrebuiltCallInvitationService()`

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.1.10:
>
> 4.1.9 Version Code:
>
>```dart
>/// Example code in version 4.1.9
>/// ...
>ZegoUIKitPrebuiltCallController().invitation.send(...);
>ZegoUIKitPrebuiltCallController().invitation.cancel(...);
>ZegoUIKitPrebuiltCallController().invitation.reject(...);
>ZegoUIKitPrebuiltCallController().invitation.accept(...);
>```
>
>4.1.10 Version Code:
>
>```dart
>/// Example code in version 4.1.10
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().send(...);
>ZegoUIKitPrebuiltCallInvitationService().cancel(...);
>ZegoUIKitPrebuiltCallInvitationService().reject(...);
>ZegoUIKitPrebuiltCallInvitationService().accept(...);
>```

</details>

<br />
<br />


# 4.1.9
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.1.8 to the latest 4.1.9 version.

# Major Interface Changes

- rename **PrebuiltCallMiniOverlayPageState** to `ZegoCallMiniOverlayPageState`
- ZegoUIKitPrebuiltCallConfig
    - class name
        - rename **ZegoMenuBarButtonName** to `ZegoCallMenuBarButtonName`
        - rename **ZegoPrebuiltAudioVideoViewConfig** to `ZegoCallAudioVideoViewConfig`
        - rename **ZegoTopMenuBarConfig** to `ZegoCallTopMenuBarConfig`
        - rename **ZegoBottomMenuBarConfig** to `ZegoCallBottomMenuBarConfig`
        - rename **ZegoMemberListConfig** to `ZegoCallMemberListConfig`
        - rename **ZegoInRoomChatViewConfig** to `ZegoCallInRoomChatViewConfig`
        - rename **ZegoHangUpConfirmDialogInfo** to `ZegoCallHangUpConfirmDialogInfo`
    - variable name
        - rename **videoConfig** to `video`
        - rename **audioVideoViewConfig** to `audioVideoView`
        - rename **topMenuBarConfig** to `topMenuBar`
        - rename **bottomMenuBarConfig** to `bottomMenuBar`
        - rename **memberListConfig** to `memberList`
        - rename **beautyConfig** to `beauty`
        - rename **chatViewConfig** to `chatView`
        - move **audioVideoContainerBuilder** to `audioVideoView.containerBuilder`

<br />
<br />

# 4.1.4
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.1.3 to the latest 4.1.4 version.

# Major Interface Changes

## onHangUpConfirmation

- add **defaultAction** in `onHangUpConfirmation  `**(💥 breaking changes)**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.1.4:
>
> 4.1.3 Version Code:
>
>```dart
>/// Example code in version 4.1.3
>/// ...
> events: ZegoUIKitPrebuiltCallEvents(
>   onHangUpConfirmation: (
>     BuildContext context,
>   ) {
>     debugPrint('onHangUpConfirmation, do whatever you want');
>
>     ...show you confirm dialog 
>
>     return dialog result;
>   },
> ),
>```
>
>4.1.4 Version Code:
>
>```dart
>/// Example code in version 4.1.4
>/// ...
> events: ZegoUIKitPrebuiltCallEvents(
>   onHangUpConfirmation: (
>     ZegoUIKitCallHangUpConfirmationEvent event,
>     Future<bool> Function() defaultAction,
>   ) {
>     debugPrint('onHangUpConfirmation, do whatever you want');
>
>     /// you can call this defaultAction to return to the previous page,
>     return defaultAction.call();
>   },
> ),
>```
>
> - parameter prototype:
> ```dart
> class ZegoUIKitCallHangUpConfirmationEvent {
>   BuildContext context;
> }
> ```

</details>

<br />
<br />
<br />
<br />
<br />

# 4.0.0

>
> The 4.0 version has standardized and optimized the [API](APIs-topic.html) and [Event](Events-topic.html), simplifying the usage of most APIs.
>
> Most of the changes involve modifications to the calling path, such as:
> - Changing from `ZegoUIKitPrebuiltCallController().isMinimizing()` to `ZegoUIKitPrebuiltCallController().minimize.isMinimizing`.
> - Move the event callback in the **ZegoUIKitPrebuiltCallConfig** to the [Event](Events-topic.html).
>
> After upgrading the call kit, you can refer to the directory index to see how specific APIs from the old version can be migrated to the new version.

---

* [ZegoUIKitPrebuiltCallInvitationService](#zegouikitprebuiltcallinvitationservice)
    * [init](#init--breaking-changes)
* [ZegoUIKitPrebuiltCallMiniOverlayMachine(ZegoMiniOverlayMachine)](#zegouikitprebuiltcallminioverlaymachinezegominioverlaymachine)
* [Controller](#controller)
    * [screenSharingViewController](#screensharingviewcontroller)
    * [showScreenSharingViewInFullscreenMode](#showscreensharingviewinfullscreenmode)
    * [sendCallInvitation](#sendcallinvitation)
    * [cancelCallInvitation](#cancelcallinvitation)
    * [rejectCallInvitation](#rejectcallinvitation)
    * [acceptCallInvitation](#acceptcallinvitation)
    * [isMinimizing => minimize.isMinimizing](#isminimizing--minimizeisminimizing)
* Events
    * [ZegoUIKitPrebuiltCallConfig](#zegouikitprebuiltcallconfig)
        * [onError](#onerror--breaking-changes)
        * [onHangUpConfirmation](#onhangupconfirmation--breaking-changes)
        * [onHangUp/onOnlySelfInRoom/onMeRemovedFromRoom](#onhangupononlyselfinroomonmeremovedfromroom--breaking-changes)
    * [ZegoUIKitPrebuiltCallInvitationEvents](#zegouikitprebuiltcallinvitationevents)
        * [onOutgoingCallRejectedCauseBusy/onOutgoingCallDeclined](#onoutgoingcallrejectedcausebusyonoutgoingcalldeclined--breaking-changes)
          
---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 3.x to the latest 4.0 version. This document aims to help users understand the interface changes and feature improvements, and
> provide a migration guide for the upgrade process.

# Major Interface Changes

## ZegoUIKitPrebuiltCall

- remove `controller`, **ZegoUIKitPrebuiltCallController** is now accessed through a singleton and does not require any parameters to be passed.  **(💥 breaking changes)**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>class CallPage extends StatefulWidget {
>  const CallPage({Key? key}) : super(key: key);
>
>  @override
>  State<StatefulWidget> createState() => CallPageState();
>}
>
>class CallPageState extends State<CallPage> {
>  ZegoUIKitPrebuiltCallController? callController;
>
>  @override
>  void initState() {
>    super.initState();
>    callController = ZegoUIKitPrebuiltCallController();
>  }
>
>  @override
>  void dispose() {
>    super.dispose();
>
>    callController = null;
>  }
>
>  void doSomething() {
>    callController?.xxx();
>  }
>
>  @override
>  Widget build(BuildContext context) {
>    return ZegoUIKitPrebuiltCall(
>        ...
>        callController: callController,
>    );
>  }
>}
>```
>
>4.0 Version Code:
>
>```dart
>class CallPage extends StatefulWidget {
>  const CallPage({Key? key}) : super(key: key);
>
>  @override
>  State<StatefulWidget> createState() => CallPageState();
>}
>
>class CallPageState extends State<CallPage> {
>  void doSomething() {
>    ZegoUIKitPrebuiltCallController().xxx();
>  }
>
>  @override
>  Widget build(BuildContext context) {
>    return ZegoUIKitPrebuiltCall(
>      ...
>    );
>  }
>}
>```

</details>

## ZegoUIKitPrebuiltCallInvitationService

### init  **(💥 breaking changes)**

For the purpose of clarity and future extensibility, the parameters have been categorized.

- adding **events**, which is used to listen for events **within a call**. please note that this is **not** related to **invitation** events.  
- invitation-related `events`, rename `events` to **invitationEvents**  
- move `showDeclineButton` and `showCancelInvitationButton` to **uiConfig**
- move `appName`,  `certificateIndex` and `isIOSSandboxEnvironment` to **notificationConfig.iOSNotificationConfig**
- remove `controller`, **ZegoUIKitPrebuiltCallController** is now accessed through a singleton and does not require any parameters to be passed.
- remove `notifyWhenAppRunningInBackgroundOrQuit`
- move `androidNotificationConfig` and `iOSNotificationConfig` to **notificationConfig**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    showDeclineButton: true,
>    showCancelInvitationButton: true,
>    notifyWhenAppRunningInBackgroundOrQuit: true,
>    androidNotificationConfig: ZegoAndroidNotificationConfig(
>    
>    ),
>    iOSNotificationConfig: ZegoIOSNotificationConfig(
>    
>    ),
>    certificateIndex: ZegoSignalingPluginMultiCertificate.firstCertificate,
>    appName: '',
>    isIOSSandboxEnvironment: false,
>    
>    events: ZegoUIKitPrebuiltCallInvitationEvents(
>        onError:(_) {
>        
>        }
>    ),
>);
>```
>
>4.0 Version Code:
>
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    uiConfig: ZegoCallInvitationUIConfig(
>    showDeclineButton: true,
>    showCancelInvitationButton: true,
>    ),
>    notificationConfig: ZegoCallInvitationNotificationConfig(
>        androidNotificationConfig: ZegoAndroidNotificationConfig(
>        
>        ),
>        iOSNotificationConfig: ZegoIOSNotificationConfig(
>            appName: '',
>            certificateIndex: ZegoSignalingPluginMultiCertificate.firstCertificate,
>            isIOSSandboxEnvironment: false,
>        ),
>    ),
>    
>    invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>        onError:(_) {
>        
>        }
>    ),
>);
>```

</details>


## ZegoUIKitPrebuiltCallMiniOverlayMachine(ZegoMiniOverlayMachine)  **(💥 breaking changes)**

The related APIs are **no longer exported externally**, the original APIs have been transferred to  **ZegoUIKitPrebuiltCallController.minimize** .

- move **switchToIdle** from `ZegoUIKitPrebuiltCallMiniOverlayMachine`to **ZegoUIKitPrebuiltCallController.minimize.hide**
- to prevent internal logic errors caused by state switching outside, **deprecated** the **changeState** function
- add **ZegoUIKitPrebuiltCallController.minimize.state**
- add **ZegoUIKitPrebuiltCallController.minimize.isMinimizing**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// 1.
>ZegoUIKitPrebuiltCallMiniOverlayMachine().changeState(
>  PrebuiltCallMiniOverlayPageState.idle,
>);
>/// 2.
>ZegoUIKitPrebuiltCallMiniOverlayMachine().switchToIdle();
>/// 3.
>ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().isMinimizing;
>/// 4.
>ZegoUIKitPrebuiltCallMiniOverlayInternalMachine().state();
>```
>
>4.0 Version Code:
>
>```dart
>/// 1.
>ZegoUIKitPrebuiltCallController().minimize.hide();
>/// 2.
>ZegoUIKitPrebuiltCallController().minimize.hide();
>/// 3.
>ZegoUIKitPrebuiltCallController().minimize.isMinimizing;
>/// 4.
>ZegoUIKitPrebuiltCallController().minimize.state;
>```

</details>


## Controller

In version 3.x, the ZegoUIKitPrebuiltCallController required declaring the variable and passing either a ZegoUIKitPrebuiltCall instance or initializing it within the ZegoUIKitPrebuiltCallInvitationService().init method.

However, in version 4.0, the ZegoUIKitPrebuiltCallController has been `changed to a singleton pattern`.

This means that you no longer need to declare a separate variable and pass parameters.

Instead, you can directly access the singleton instance and make calls to it.

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>/// assign controller to ZegoUIKitPrebuiltCallInvitationService().init
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    controller:controller,
>    ...
>);
>/// or, assign controller to ZegoUIKitPrebuiltCall
>ZegoUIKitPrebuiltCall(
>    ...
>    controller:controller,
>    ...
>)
>
>controller.xxx(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().xxx(...);
>```

</details>


### screenSharingViewController

- move **screenSharingViewController** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.screenSharing** and rename to **viewController**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.screenSharingViewController.xxx(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().screenSharing.viewController.xxx(...);
>```

</details>

### showScreenSharingViewInFullscreenMode

- move **showScreenSharingViewInFullscreenMode** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.screenSharing**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.showScreenSharingViewInFullscreenMode(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().screenSharing.showScreenSharingViewInFullscreenMode(...);
>```

</details>

### sendCallInvitation

- move **sendCallInvitation** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.invitation** and rename to **send**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.sendCallInvitation(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().invitation.send(...);
>```

</details>

### cancelCallInvitation

- move **cancelCallInvitation** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.invitation** and rename to **cancel**


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.cancelCallInvitation(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().invitation.cancel(...);
>```

</details>


### rejectCallInvitation

- move **rejectCallInvitation** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.invitation** and rename to **reject**

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.rejectCallInvitation(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().invitation.reject(...);
>```

</details>


### acceptCallInvitation

- move **acceptCallInvitation** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.invitation** and rename to **accept**


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>controller.acceptCallInvitation(...);
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallController().invitation.accept(...);
>```

</details>

### isMinimizing => minimize.isMinimizing

- move **isMinimizing** from `ZegoUIKitPrebuiltCallController`to **ZegoUIKitPrebuiltCallController.minimize**


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallController controller;
>
>...assign controller to ZegoUIKitPrebuiltCallInvitationService().init/ZegoUIKitPrebuiltCall
>
>if(controller.isMinimizing) {
>
>}
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>if(ZegoUIKitPrebuiltCallController().minimize.isMinimizing) {
>
>}
>```

</details>

## Events

### ZegoUIKitPrebuiltCallConfig


#### onError **(💥 breaking changes)**

- move **onError** from `ZegoUIKitPrebuiltCallConfig`to **ZegoUIKitPrebuiltCallEvents.onError**


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    config: ZegoUIKitPrebuiltCallConfig(
>        onError: (error){
>        
>        }
>    ),
>)
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    events: ZegoUIKitPrebuiltCallEvents(
>        onError: (error){
>        
>        }
>    ),
>)
>```

</details>

#### onHangUpConfirmation **(💥 breaking changes)**

- move **onHangUpConfirmation** from `ZegoUIKitPrebuiltCallConfig`to **ZegoUIKitPrebuiltCallEvents.onHangUpConfirmation**


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    config: ZegoUIKitPrebuiltCallConfig(
>        onHangUpConfirmation: (context){
>        
>        }
>    ),
>)
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    events: ZegoUIKitPrebuiltCallEvents(
>        onHangUpConfirmation: (context){
>        
>        }
>    ),
>)
>```

</details>


#### onHangUp/onOnlySelfInRoom/onMeRemovedFromRoom **(💥 breaking changes)**

>
> Due to the fact that all three events indicate the end of a call, they will be consolidated into **ZegoUIKitPrebuiltCallEvents.onCallEnd** and differentiated by the **ZegoUIKitCallEndEvent.reason**.
>
> And you can use **defaultAction.call()** to perform the internal default action, which returns to the previous page.

- move **onHangUp** from `ZegoUIKitPrebuiltCallConfig` to ZegoUIKitPrebuiltCallEvents.**onCallEnd**(ZegoUIKitCallEndEvent(reason:ZegoUIKitCallEndReason.**localHangUp**), defaultAction)
- move **onOnlySelfInRoom** from `ZegoUIKitPrebuiltCallConfig`to ZegoUIKitPrebuiltCallEvents.**onCallEnd**(ZegoUIKitCallEndEvent(reason:ZegoUIKitCallEndReason.**remoteHangUp**), defaultAction)
- move **onMeRemovedFromRoom** from `ZegoUIKitPrebuiltCallConfig`to ZegoUIKitPrebuiltCallEvents.**onCallEnd**(ZegoUIKitCallEndEvent(reason:ZegoUIKitCallEndReason.**kickOut**), defaultAction)



<details>
<summary>Defines</summary>

>
>```dart
>typedef CallEndCallback = void Function(
>    ZegoUIKitCallEndEvent event,
>
>    /// defaultAction to return to the previous page
>    VoidCallback defaultAction,
>);
>```
>
>```dart
>class ZegoUIKitCallEndEvent {
>  /// the user ID of who kick you out
>  String? kickerUserID;
>
>  /// end reason
>  ZegoUIKitCallEndReason reason;
>
>  ZegoUIKitCallEndEvent({
>    required this.reason,
>    this.kickerUserID,
>  });
>}
>
>/// The default behavior is to return to the previous page.
>///
>/// If you override this callback, you must perform the page navigation
>/// yourself to return to the previous page!!!
>/// otherwise the user will remain on the current call page !!!!!
>enum ZegoUIKitCallEndReason {
>  /// the call ended due to a local hang-up
>  localHangUp,
>
>  /// the call ended when the remote user hung up, leaving only one local user in the call
>  remoteHangUp,
>
>  /// the call ended due to being kicked out
>  kickOut,
>}
>```

</details>


<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.0:
>
>3.x Version Code:
>
>```dart
>/// Example code in version 3.x
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    config: ZegoUIKitPrebuiltCallConfig(
>        onHangUp: (){
>        
>        },
>        onOnlySelfInRoom: (context){
>        
>        },
>        onMeRemovedFromRoom: (fromUserID){
>        
>        },
>    ),
>)
>```
>
>4.0 Version Code:
>
>```dart
>/// Example code in version 4.0
>/// ...
>ZegoUIKitPrebuiltCallInvitationService().init(
>    ...
>    events: ZegoUIKitPrebuiltCallEvents(
>        onCallEnd: (event, defaultAction){
>            debugPrint('onCallEnd by ${event.reason}, do whatever you want');
>            
>            switch(event.reason) {
>                case ZegoUIKitCallEndReason.localHangUp:
>                  // TODO: Handle this case.
>                break;
>                case ZegoUIKitCallEndReason.remoteHangUp:
>                  // TODO: Handle this case.
>                break;
>                case ZegoUIKitCallEndReason.kickOut:
>                  final fromUserID = event.kickerUserID ?? '';
>                break;
>            }
>            
>            /// you can call this defaultAction to return to the previous page
>            defaultAction.call();
>        },
>    ),
>)
>```

</details>

### ZegoUIKitPrebuiltCallInvitationEvents

#### onOutgoingCallRejectedCauseBusy/onOutgoingCallDeclined **(💥 breaking changes)**

- adding **customData**, which is from **ZegoUIKitPrebuiltCallController.invitation.reject**.

## Feedback Channels

If you encounter any issues or have any questions during the migration process, please provide feedback through the following channels:

- GitHub Issues: [Link to the project's issue page](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_flutter/issues)
- Forum: [Link to the forum page](https://www.zegocloud.com/)

We appreciate your feedback and are here to help you successfully complete the migration process.