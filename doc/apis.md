
- [ZegoUIKitPrebuiltCall](#zegouikitprebuiltcallzego_uikit_prebuilt_callzegouikitprebuiltcall-classhtml)
- [ZegoUIKitPrebuiltCallInvitationService](#zegouikitprebuiltcallinvitationservicezego_uikit_prebuilt_callzegouikitprebuiltcallinvitationservice-classhtml)
  - [init](#init)
  - [uninit](#uninit)
  - [setNavigatorKey](#setnavigatorkey)
  - [useSystemCallingUI](#usesystemcallingui)
  - [send](#send)
  - [cancel](#cancel)
  - [reject](#reject)
  - [accept](#accept)
- [ZegoUIKitPrebuiltCallController](#zegouikitprebuiltcallcontrollerzego_uikit_prebuilt_callzegouikitprebuiltcallcontroller-classhtml)
  - [hangUp](#hangup)
  - [minimize](#minimize)
    - [isMinimizing](#isminimizingnotifiervaluenotifierbool)
    - [isMinimizing](#isminimizing)
    - [state](#state)
    - [restore](#restore)
    - [minimize](#minimize-2)
    - [hide](#hide)
  - [screenSharing](#screensharing)
    - [viewController](#viewcontroller)
    - [showViewInFullscreenMode](#showviewinfullscreenmode)
  - [audioVideo](#audiovideo)
    - [camera](#camera)
      - [localState](#localstate)
      - [localStateNotifier](#localstatenotifier)
      - [state](#state)
      - [stateNotifier](#statenotifier)
      - [turnOn](#turnon)
      - [switchState](#switchstate)
      - [switchFrontFacing](#switchfrontfacing)
      - [switchVideoMirroring](#switchvideomirroring)
    - [microphone](#microphone)
      - [localState](#localstate-1)
      - [localStateNotifier](#localstatenotifier-1)
      - [state](#state-1)
      - [stateNotifier](#statenotifier-1)
      - [turnOn](#turnon-1)
      - [switchState](#switchstate-1)
    - [audioOutput](#audiooutput)
      - [localNotifier](#localnotifier)
      - [notifier](#notifier)
      - [switchToSpeaker](#switchtospeaker)
  - [user]
    - [stream](#stream)
    - [remove](#remove)
  
---

# [ZegoUIKitPrebuiltCall](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCall-class.html)

>
> Call Widget.
>
> You can embed this widget into any page of your project to integrate the functionality of a call.
>
> If you need the function of `call invitation`, please use `ZegoUIKitPrebuiltCallInvitationService` together.
>
> - function prototype:
>
>```dart
>
>class ZegoUIKitPrebuiltCall extends StatefulWidget {
>  const ZegoUIKitPrebuiltCall({
>    Key? key,
>    required this.appID,
>    required this.appSign,
>    required this.callID,
>    required this.userID,
>    required this.userName,
>    required this.config,
>    this.events,
>    this.onDispose,
>    this.plugins,
>  }) : super(key: key);
>
>  /// You can create a project and obtain an appID from the [ZEGOCLOUD Admin >Console](https://console.zegocloud.com).
>  final int appID;
>
>  /// You can create a project and obtain an appSign from the [ZEGOCLOUD >Admin Console](https://console.zegocloud.com).
>  final String appSign;
>
>  /// The ID of the currently logged-in user.
>  /// It can be any valid string.
>  /// Typically, you would use the ID from your own user system, such as >Firebase.
>  final String userID;
>
>  /// The name of the currently logged-in user.
>  /// It can be any valid string.
>  /// Typically, you would use the name from your own user system, such as >Firebase.
>  final String userName;
>
>  /// The ID of the call.
>  /// This ID is a unique identifier for the current call, so you need to >ensure its uniqueness.
>  /// It can be any valid string.
>  /// Users who provide the same callID will be logged into the same room >for the call.
>  final String callID;
>
>  /// Initialize the configuration for the call.
>  final ZegoUIKitPrebuiltCallConfig config;
>
>  /// Initialize the events for the call.
>  final ZegoUIKitPrebuiltCallEvents? events;
>
>  /// Callback when the page is destroyed.
>  final VoidCallback? onDispose;
>
>  final List<IZegoUIKitPlugin>? plugins;
>}
>```

# [ZegoUIKitPrebuiltCallInvitationService](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallInvitationService-class.html)

## setNavigatorKey

> we need a context object, to push/pop page when receive invitation request, so we need navigatorKey to get context.
>
> - function prototype:
>
> ```dart
> void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey)
> ```

## isInCalling

> - function prototype:
>
> ```dart
> bool get isInCalling
> ```
> 

## init

>
> you must call this method as soon as the user login(or re-login, auto-login) to your app.
>
> You must include [ZegoUIKitSignalingPlugin] in [plugins] to support the invitation feature.
>
> If you need to set [ZegoUIKitPrebuiltCallConfig], you can do so through [requireConfig].
> Each time the [ZegoUIKitPrebuiltCall] starts, it will request this callback to obtain the current call's config.
>
> Additionally, you can customize the call ringtone through [ringtoneConfig], and configure notifications through [notificationConfig].
> You can also customize the invitation interface with [uiConfig]. If you want to modify the related text on the interface, you can set [innerText].
> If you want to listen for events and perform custom logics, you can use [invitationEvents] to obtain related invitation events, and for call-related events, you need to use [events].
>
> - function prototype:
>
> ```dart
> Future<void> init({
>    required int appID,
>    required String appSign,
>    required String userID,
>    required String userName,
>    required List<IZegoUIKitPlugin> plugins,
>    /// call abouts.
>    ZegoCallPrebuiltConfigQuery? requireConfig,
>    ZegoUIKitPrebuiltCallEvents? events,
>    /// invitation abouts.
>    ZegoCallInvitationConfig? config,
>    ZegoCallRingtoneConfig? ringtoneConfig,
>    ZegoCallInvitationUIConfig? uiConfig,
>    ZegoCallInvitationNotificationConfig? notificationConfig,
>    ZegoCallInvitationInnerText? innerText,
>    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
>  }) async
> ```

## uninit

> must call this method as soon as the user logout from  app
>
> - function prototype:
>
> ```dart
> Future<void> uninit() async
> ```

## useSystemCallingUI

> - function prototype:
>
> ```dart
> void useSystemCallingUI(List<IZegoUIKitPlugin> plugins)
> ```


### send

> This function is used to send call invitations to one or more specified users.
>
> You can provide a list of target users `invitees` and specify whether it is a video call `isVideoCall`. If it is not a video call, it defaults to an audio call.
>
> You can also pass additional custom data `customData` to the invitees.
>
> Additionally, you can specify the call ID `callID`. If not provided, the system will generate one automatically based on certain rules.
>
> If you want to set a ringtone for offline call invitations, set `resourceID` to a value that matches the push resource ID in the ZEGOCLOUD management console.
>
> You can also set the notification title `notificationTitle` and message `notificationMessage`.
>
> If the call times out, the call will automatically hang up after the specified timeout duration `timeoutSeconds` (in seconds).
>
> Note that this function behaves the same as `ZegoSendCallInvitationButton`.
>
> - function prototype:
>
> ```dart
> Future<bool> send({
>    required List<ZegoCallUser> invitees,
>    required bool isVideoCall,
>    String customData = '',
>    String? callID,
>    String? resourceID,
>    String? notificationTitle,
>    String? notificationMessage,
>    int timeoutSeconds = 60,
>  }) async
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallInvitationService().send(...);
> ```

### cancel

> To cancel the invitation for `callees` in a call, you can include your cancellation reason using the `customData`.
>
> Additionally, you can receive notifications by listening to `onIncomingCallCanceled` when the incoming call is canceled.
>
> - function prototype:
>
> ```dart
> Future<bool> cancel({
>    required List<ZegoCallUser> callees,
>    String customData = '',
>  }) async
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallInvitationService().cancel(...);
> ```

### reject

> when reject the current call invitation, you can use the `customData` parameter if you need to provide a reason for the rejection to the other party.
>
> Additionally, the inviting party can receive notifications of the rejection by listening to `onOutgoingCallRejectedCauseBusy` or `onOutgoingCallDeclined` when the other party declines the call invitation.
>
>> - function prototype:
>>
>
> ```dart
> Future<bool> reject({
>    String customData = '',
>  }) async
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallInvitationService().reject();
> ```

### accept

> To accept the current call invitation, you can use the `customData` parameter if you need to provide a reason for the acceptance to the other party.
>
> Additionally, the inviting party can receive notifications by listening to `onOutgoingCallAccepted` when the other party accepts the call invitation.
>
> - function prototype:
>
> ```dart
> Future<bool> accept({
>    String customData = '',
>  }) async
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallInvitationService().accept();
> ```

# [ZegoUIKitPrebuiltCallController](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallController-class.html)

> A singleton class, can be accessed and its APIs can be accessed using either ZegoUIKitPrebuiltCallController().

## hangUp

> This function is used to end the current call.
>
> You can pass the context `context` for any necessary pop-ups or page transitions.
>
> By using the `showConfirmation` parameter, you can control whether to display a confirmation dialog to confirm ending the call.
>
> This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the `onHangUpConfirmation` and `onHangUp` settings in the config.
>
> - function prototype:
>
> ```dart
>  Future<bool> hangUp(
>    BuildContext context, {
>    bool showConfirmation = false,
>  }) async
> ```

## screenSharing

### viewController

### showViewInFullscreenMode

> This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
>
> You need to provide the user's ID `userID` to determine which user to perform the operation on.
>
> By using a boolean value `isFullscreen`, you can specify whether the user enters or exits full-screen mode.
>
> - function prototype:
>
> ```dart
> void showViewInFullscreenMode(String userID, bool isFullscreen)
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController().screenSharing.showViewInFullscreenMode(...);
> ```

## minimize

### isMinimizingNotifier(ValueNotifier<bool>)

> is it currently in the minimized state or not
>
> - example:
>
> ```dart
> ValueListenableBuilder<bool>(
>   valueListenable:
>   ZegoUIKitPrebuiltCallController().minimize.isMinimizingNotifier,
>   builder: (context, isMinimized, _) {
>     ...
>   },
> )
> ```

### isMinimizing(bool)

> is it currently in the minimized state or not
>
> - example:
>
> ```dart
> final isMinimizing = ZegoUIKitPrebuiltCallController().minimize.isMinimizing;
> ```

### state(ZegoCallMiniOverlayPageState)

> current state of the minimized
>
> - enum prototype:
>
> ```dart
> /// The current state of the minimized interface can be described as follows:
> ///
> /// [idle]: in a blank state, not yet minimized, or has been restored to the original Widget.
> /// [calling]: in the process of being restored from the minimized state.
> /// [minimizing]: in the minimized state.
> enum ZegoCallMiniOverlayPageState {
>  idle,
>  calling,
>  minimizing,
> }
> ```
>
> - example:
>
> ```dart
> final state = ZegoUIKitPrebuiltCallController().minimize.state;
> ```

### restore

> restore the ZegoUIKitPrebuiltCall from minimize
>
> - function prototype:
>
> ```dart
>  bool restore(
>    BuildContext context, {
>    bool rootNavigator = true,
>    bool withSafeArea = false,
>  })
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController().minimize.restore(...);
> ```

### minimize

> to minimize the ZegoUIKitPrebuiltCall
>
> - function prototype:
>
> ```dart
> bool minimize(
>    BuildContext context, {
>    bool rootNavigator = true,
>  })
> ```
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController().minimize.minimize(...);
> ```

### hide

> if call ended in minimizing state, not need to navigate, just hide the minimize widget.
>
> Note that this is not an active call end, but merely hide the minimize widget, which will not cause hang up.
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController().minimize.hide();
> ```

## audioVideo

### camera

#### localState

> camera state of local user
>
> - function prototype:
>
> ```dart
> bool get localState
> ```
#### localStateNotifier

> camera state notifier of local user
> 
> - function prototype:
>
> ```dart
> ValueNotifier<bool> get localStateNotifier
> ```
#### state

> camera state of [userID]
>
> - function prototype:
>
> ```dart
> bool state(String userID)
> ```
#### stateNotifier

> camera state notifier of [userID]
> 
> - function prototype:
>
> ```dart
> ValueNotifier<bool> stateNotifier(String userID)
> ```

#### turnOn

> turn on/off [userID] camera, if [userID] is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void turnOn(bool isOn, {String? userID})
> ```

#### switchState

> switch [userID] camera state, if [userID] is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void switchState({String? userID})
> ```

#### switchFrontFacing
> local use front facing camera or back
> 
> - function prototype:
>
> ```dart
> void switchFrontFacing(bool isFrontFacing)
> ```

#### switchVideoMirroring
> switch video mirror mode
>
> - function prototype:
>
> ```dart
> void switchVideoMirroring(bool isVideoMirror)
> ```

### microphone

#### localState

> microphone state of local user
>
> - function prototype:
>
> ```dart
> bool get localState
> ```

#### localStateNotifier

> microphone state notifier of local user
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> get localStateNotifier
> ```

#### state

> microphone state of [userID]
>
> - function prototype:
>
> ```dart
> bool state(String userID)
> ```

#### stateNotifier

> microphone state notifier of [userID]
>
> - function prototype:
>
> ```dart
> ValueNotifier<bool> stateNotifier(String userID)
> ```

#### turnOn

> turn on/off [userID] microphone, if [userID] is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void turnOn(bool isOn, {String? userID})
> ```

#### switchState

> switch [userID] microphone state, if [userID] is empty, then it refers to local user
>
> - function prototype:
>
> ```dart
> void switchState({String? userID})
> ```

### audioOutput

```dart
/// Audio route
enum ZegoUIKitAudioRoute {
  speaker,
  headphone,

  /// bluetooth device
  bluetooth,

  /// telephone receiver
  receiver,

  /// external USB audio device
  externalUSB,

  /// apple AirPlay
  airPlay,
}
```

#### localNotifier

> local audio output device notifier
>
> - function prototype:
>
> ```dart
> ValueNotifier<ZegoUIKitAudioRoute> get localNotifier
> ```
#### notifier

> audio output device notifier of [userID]
>
> - function prototype:
>
> ```dart
>  ValueNotifier<ZegoUIKitAudioRoute> notifier(String userID)
> ```
#### switchToSpeaker

> set audio output to speaker or earpiece(telephone receiver)
>
> - function prototype:
>
> ```dart
> void switchToSpeaker(bool isSpeaker)
> ```
  
## user

### stream
>  user list stream notifier
>
> - function prototype:
>
> ```dart
> Stream<List<ZegoUIKitUser>> get stream
> ```
>
> - example:
> 
> ```dart
> StreamBuilder<List<ZegoUIKitUser>>(
>   stream: ZegoUIKit().getUserListStream(),
>   builder: (context, snapshot) {
>     final allUsers = ZegoUIKit().getAllUsers();
>     ...
>   },
> )
> ```

### remove

> remove user from call, kick out
>
> - function prototype:
>
> ```dart
> Future<bool> remove(List<String> userIDs) async
> ```
>
> @return Error code, please refer to the error codes document https://docs.zegocloud.com/en/5548.html for details.
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController().user.remove();
> ```