
- [ZegoUIKitPrebuiltCall](#zegouikitprebuiltcallzego_uikit_prebuilt_callzegouikitprebuiltcall-classhtml)
- [ZegoUIKitPrebuiltCallInvitationService](#zegouikitprebuiltcallinvitationservicezego_uikit_prebuilt_callzegouikitprebuiltcallinvitationservice-classhtml)
  - [init](#init)
  - [uninit](#uninit)
  - [setNavigatorKey](#setnavigatorkey)
  - [useSystemCallingUI](#usesystemcallingui)
- [ZegoUIKitPrebuiltCallController](#zegouikitprebuiltcallcontrollerzego_uikit_prebuilt_callzegouikitprebuiltcallcontroller-classhtml)
  - [hangUp](#hangup)
  - [invitation](#invitation)
    - [send](#send)
    - [cancel](#cancel)
    - [reject](#reject)
    - [accept](#accept)
  - [minimize](#minimize)
    - [isMinimizing](#isminimizing)
    - [state](#state)
    - [restore](#restore)
    - [minimize](#minimize-2)
    - [hide](#hide)
  - [screenSharing](#screensharing)
    - [viewController](#viewcontroller)
    - [showViewInFullscreenMode](#showviewinfullscreenmode)

---

# [ZegoUIKitPrebuiltCall](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCall-class.html)

> | Key      | Type                         |
> | -------- | ---------------------------- |
> | appID    | int                          |
> | appSign  | String                       |
> | callID   | String                       |
> | userID   | String                       |
> | userName | String                       |
> | config   | ZegoUIKitPrebuiltCallConfig  |
> | events   | ZegoUIKitPrebuiltCallEvents? |
> | plugins  | List\<IZegoUIKitPlugin>?     |

# [ZegoUIKitPrebuiltCallInvitationService](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallInvitationService-class.html)

## setNavigatorKey

> we need a context object, to push/pop page when receive invitation request, so we need navigatorKey to get context.
>
> - function prototype:
>
> ```dart
> void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey)
> ```

## init

> must call this method as soon as the user logs in  app or re-logged in.
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
>    PrebuiltConfigQuery? requireConfig,
>    ZegoRingtoneConfig? ringtoneConfig,
>    ZegoCallInvitationUIConfig? uiConfig,
>    ZegoCallInvitationNotificationConfig? notificationConfig,
>    ZegoCallInvitationInnerText? innerText,
>    ZegoUIKitPrebuiltCallEvents? events,
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

# [ZegoUIKitPrebuiltCallController](../zego_uikit_prebuilt_call/ZegoUIKitPrebuiltCallController-class.html)

> A singleton class, can be accessed and its APIs can be accessed using either ZegoUIKitPrebuiltCallController() or ZegoUIKitPrebuiltCallController.instance.

## hangUp

> This function is used to end the current call.
>
> You can pass the context **context** for any necessary pop-ups or page transitions.
>
> By using the **showConfirmation** parameter, you can control whether to display a confirmation dialog to confirm ending the call.
>
> This function behaves the same as the close button in the calling interface's top right corner, and it is also affected by the **onHangUpConfirmation** and **onHangUp** settings in the config.
>
> - function prototype:
>
> ```dart
>  Future<bool> hangUp(
>    BuildContext context, {
>    bool showConfirmation = false,
>  }) async
> ```

## invitation

### send

> This function is used to send call invitations to one or more specified users.
>
> You can provide a list of target users **invitees** and specify whether it is a video call **isVideoCall**. If it is not a video call, it defaults to an audio call.
>
> You can also pass additional custom data **customData** to the invitees.
>
> Additionally, you can specify the call ID **callID**. If not provided, the system will generate one automatically based on certain rules.
>
> If you want to set a ringtone for offline call invitations, set **resourceID** to a value that matches the push resource ID in the ZEGOCLOUD management console.
>
> Note that the **resourceID** setting will only take effect when **notifyWhenAppRunningInBackgroundOrQuit** is true.
>
> You can also set the notification title **notificationTitle** and message **notificationMessage**.
>
> If the call times out, the call will automatically hang up after the specified timeout duration **timeoutSeconds** (in seconds).
>
> Note that this function behaves the same as **ZegoSendCallInvitationButton**.
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
> ZegoUIKitPrebuiltCallController.instance.invitation.send(...);
> ```

### cancel

> To cancel the invitation for **callees** in a call, you can include your cancellation reason using the **customData**.
>
> Additionally, you can receive notifications by listening to **onIncomingCallCanceled** when the incoming call is canceled.
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
> ZegoUIKitPrebuiltCallController.instance.invitation.cancel(...);
> ```

### reject

> when reject the current call invitation, you can use the **customData** parameter if you need to provide a reason for the rejection to the other party.
>
> Additionally, the inviting party can receive notifications of the rejection by listening to **onOutgoingCallRejectedCauseBusy** or **onOutgoingCallDeclined** when the other party declines the call invitation.
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
> ZegoUIKitPrebuiltCallController.instance.invitation.reject();
> ```

### accept

> To accept the current call invitation, you can use the **customData** parameter if you need to provide a reason for the acceptance to the other party.
>
> Additionally, the inviting party can receive notifications by listening to **onOutgoingCallAccepted** when the other party accepts the call invitation.
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
> ZegoUIKitPrebuiltCallController.instance.invitation.accept();
> ```

## screenSharing

### viewController

### showViewInFullscreenMode

> This function is used to specify whether a certain user enters or exits full-screen mode during screen sharing.
>
> You need to provide the user's ID **userID** to determine which user to perform the operation on.
>
> By using a boolean value **isFullscreen**, you can specify whether the user enters or exits full-screen mode.
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
> ZegoUIKitPrebuiltCallController.instance.screenSharing.showViewInFullscreenMode(...);
> ```

## minimize

### isMinimizing(bool)

> is it currently in the minimized state or not
>
> - example:
>
> ```dart
> final isMinimizing = ZegoUIKitPrebuiltCallController.instance.minimize.isMinimizing;
> ```

### state(PrebuiltCallMiniOverlayPageState)

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
> enum PrebuiltCallMiniOverlayPageState {
>  idle,
>  calling,
>  minimizing,
> }
> ```
>
> - example:
>
> ```dart
> final state = ZegoUIKitPrebuiltCallController.instance.minimize.state;
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
> ZegoUIKitPrebuiltCallController.instance.minimize.restore(...);
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
> ZegoUIKitPrebuiltCallController.instance.minimize.minimize(...);
> ```

### hide

> if call ended in minimizing state, not need to navigate, just hide the minimize widget.
>
> Note that this is not an active call end, but merely hide the minimize widget, which will not cause hang up.
>
> - example:
>
> ```dart
> ZegoUIKitPrebuiltCallController.instance.minimize.hide();
> ```
