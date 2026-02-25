# Components

- [ZegoUIKitPrebuiltCall](#zegouikitprebuiltcall)
- [ZegoUIKitPrebuiltCallInvitationService](#zegouikitprebuiltcallinvitationservice)
- [ZegoUIKitPrebuiltCallController](#zegouikitprebuiltcallcontroller)
- [ZegoSendCallInvitationButton](#zegosendcallinvitationbutton)
- [ZegoSendCallingInvitationButton](#zegosendcallinginvitationbutton)
- [ZegoSendCallingInvitationList](#zegosendcallinginvitationlist)
  - [showCallingInvitationListSheet](#showcallinginvitationlistsheet)
- [ZegoUIKitPrebuiltCallMiniOverlayPage](#zegouikitprebuiltcallminioverlaypage)

---

## ZegoUIKitPrebuiltCall

Call Widget.
You can embed this widget into any page of your project to integrate the functionality of a call.

**Constructor:**

```dart
const ZegoUIKitPrebuiltCall({
  Key? key,
  required int appID,
  required String callID,
  required String userID,
  required String userName,
  required ZegoUIKitPrebuiltCallConfig config,
  String appSign = '',
  String token = '',
  ZegoUIKitPrebuiltCallEvents? events,
  VoidCallback? onDispose,
  List<IZegoUIKitPlugin>? plugins,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **appID** | `int` | Yes | The App ID of your Zego project. |
| **callID** | `String` | Yes | The ID of the call. |
| **userID** | `String` | Yes | The ID of the user. |
| **userName** | `String` | Yes | The name of the user. |
| **config** | `ZegoUIKitPrebuiltCallConfig` | Yes | The configuration of the call. |
| **appSign** | `String` | No | The App Sign of your Zego project. |
| **token** | `String` | No | The Token of your Zego project. |
| **events** | `ZegoUIKitPrebuiltCallEvents?` | No | The events of the call. |
| **onDispose** | `VoidCallback?` | No | Callback when the widget is disposed. |
| **plugins** | `List<IZegoUIKitPlugin>?` | No | The plugins to be used. |

**Example**
```dart
ZegoUIKitPrebuiltCall(
  appID: appID,
  callID: callID,
  userID: userID,
  userName: userName,
  config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
);
```

---

## ZegoUIKitPrebuiltCallInvitationService

Call invitation service singleton class that manages core features including sending, receiving, accepting, and rejecting call invitations.

**Methods:**

### init

Initialize the invitation service.

```dart
Future<void> init({
  required int appID,
  required String userID,
  required String userName,
  required List<IZegoUIKitPlugin> plugins,
  String appSign = '',
  String token = '',
  ZegoCallPrebuiltConfigQuery? requireConfig,
  ZegoUIKitPrebuiltCallEvents? events,
  ZegoCallInvitationConfig? config,
  ZegoCallRingtoneConfig? ringtoneConfig,
  ZegoCallInvitationUIConfig? uiConfig,
  ZegoCallInvitationNotificationConfig? notificationConfig,
  ZegoCallInvitationInnerText? innerText,
  ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **appID** | `int` | Yes | The App ID of your Zego project. |
| **userID** | `String` | Yes | The ID of the user. |
| **userName** | `String` | Yes | The name of the user. |
| **plugins** | `List<IZegoUIKitPlugin>` | Yes | The plugins to be used. |
| **appSign** | `String` | No | The App Sign of your Zego project. |
| **token** | `String` | No | The Token of your Zego project. |
| **requireConfig** | `ZegoCallPrebuiltConfigQuery?` | No | Callback to obtain the call config. |
| **events** | `ZegoUIKitPrebuiltCallEvents?` | No | The events of the call. |
| **config** | `ZegoCallInvitationConfig?` | No | The configuration of the invitation. |
| **ringtoneConfig** | `ZegoCallRingtoneConfig?` | No | The ringtone configuration. |
| **uiConfig** | `ZegoCallInvitationUIConfig?` | No | The UI configuration of the invitation. |
| **notificationConfig** | `ZegoCallInvitationNotificationConfig?` | No | The notification configuration. |
| **innerText** | `ZegoCallInvitationInnerText?` | No | The inner text of the invitation. |
| **invitationEvents** | `ZegoUIKitPrebuiltCallInvitationEvents?` | No | The events of the invitation. |

### uninit

Deinitialize the service. Must be called when the user logs out.

```dart
Future<void> uninit()
```

### send

Send a call invitation to one or more specified users.

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

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **invitees** | `List<ZegoCallUser>` | Yes | The list of invitees to send the call invitation to. |
| **isVideoCall** | `bool` | Yes | Determines whether the call is a video call. |
| **customData** | `String` | No | Custom data to be passed to the invitee. |
| **callID** | `String?` | No | The call ID. If not provided, the system will generate one automatically. |
| **resourceID** | `String?` | No | The resource ID for notification. |
| **notificationTitle** | `String?` | No | The title for the notification. |
| **notificationMessage** | `String?` | No | The message for the notification. |
| **timeoutSeconds** | `int` | No | The timeout duration in seconds for the call invitation. |

### cancel

Cancel the call invitation.

```dart
Future<bool> cancel({
  required List<ZegoCallUser> callees,
  String customData = '',
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **callees** | `List<ZegoCallUser>` | Yes | The list of callees to cancel the invitation for. |
| **customData** | `String` | No | Custom data. |

### reject

Reject the call invitation.

```dart
Future<bool> reject({
  String customData = '',
  bool needHideInvitationTopSheet = true,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **customData** | `String` | No | Custom data. |
| **needHideInvitationTopSheet** | `bool` | No | Whether to hide the invitation top sheet. |

### accept

Accept the call invitation.

```dart
Future<bool> accept({
  String customData = '',
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **customData** | `String` | No | Custom data. |

### join

Join the call invitation.

```dart
Future<bool> join({
  required String invitationID,
  String? customData = '',
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **invitationID** | `String` | Yes | The invitation ID. |
| **customData** | `String?` | No | Custom data. |

### enterAcceptedOfflineCall

Enter an accepted offline call. Suitable for scenarios requiring navigation after data loading completes.

```dart
void enterAcceptedOfflineCall()
```

### setNavigatorKey

Set the navigation key for necessary configuration when navigating pages upon receiving invitations.

```dart
void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey)
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **navigatorKey** | `GlobalKey<NavigatorState>` | Yes | The navigator key. |

### useSystemCallingUI

Enable offline system calling UI to support receiving invitations in the background, answering on lock screen, etc.

Note: If you use CallKit with ZIMKit, this must be called AFTER ZIMKit().init!!!

```dart
Future<void> useSystemCallingUI(List<IZegoUIKitPlugin> plugins)
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **plugins** | `List<IZegoUIKitPlugin>` | Yes | The plugins to be used. |

**Example**
```dart
await ZegoUIKitPrebuiltCallInvitationService().init(
  appID: appID,
  userID: userID,
  userName: userName,
  plugins: [ZegoUIKitSignalingPlugin()],
);
```

---

## ZegoUIKitPrebuiltCallController

Used to control the call functionality.
**Singleton Instance:**
```dart
ZegoUIKitPrebuiltCallController()
```

### hangUp

This function is used to end the current call.

```dart
Future<bool> hangUp(
  BuildContext context, {
  bool showConfirmation = false,
  ZegoCallEndReason reason = ZegoCallEndReason.localHangUp,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The context. |
| **showConfirmation** | `bool` | No | Whether to display a confirmation dialog. |
| **reason** | `ZegoCallEndReason` | No | The reason for ending the call. |

### minimize.minimize

To minimize the ZegoUIKitPrebuiltCall.

```dart
bool minimize(
  BuildContext context, {
  bool rootNavigator = true,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The context. |
| **rootNavigator** | `bool` | No | Whether to use the root navigator. |

### minimize.restore

Restore the ZegoUIKitPrebuiltCall from minimize.

```dart
bool restore(
  BuildContext context, {
  bool rootNavigator = true,
  bool withSafeArea = false,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The context. |
| **rootNavigator** | `bool` | No | Whether to use the root navigator. |
| **withSafeArea** | `bool` | No | Whether to use SafeArea. |

### minimize.minimizeInviting

Minimize the inviting interface.

```dart
bool minimizeInviting(
  BuildContext context, {
  bool rootNavigator = true,
  required ZegoCallInvitationType invitationType,
  required ZegoUIKitUser inviter,
  required List<ZegoUIKitUser> invitees,
  required bool isInviter,
  required ZegoCallInvitationPageManager pageManager,
  required ZegoUIKitPrebuiltCallInvitationData callInvitationData,
  String? customData,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The context. |
| **rootNavigator** | `bool` | No | Whether to use the root navigator. |
| **invitationType** | `ZegoCallInvitationType` | Yes | The invitation type. |
| **inviter** | `ZegoUIKitUser` | Yes | The inviter. |
| **invitees** | `List<ZegoUIKitUser>` | Yes | The invitees. |
| **isInviter** | `bool` | Yes | Whether the current user is the inviter. |
| **pageManager** | `ZegoCallInvitationPageManager` | Yes | The page manager. |
| **callInvitationData** | `ZegoUIKitPrebuiltCallInvitationData` | Yes | The call invitation data. |
| **customData** | `String?` | No | Custom data. |

### minimize.restoreInviting

Restore the inviting interface.

```dart
bool restoreInviting(
  BuildContext context, {
  bool rootNavigator = true,
  bool withSafeArea = false,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The context. |
| **rootNavigator** | `bool` | No | Whether to use the root navigator. |
| **withSafeArea** | `bool` | No | Whether to use SafeArea. |

### pip.enable

Enable PIP.

```dart
Future<ZegoPiPStatus> enable({
  int aspectWidth = 9,
  int aspectHeight = 16,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **aspectWidth** | `int` | No | The aspect width. |
| **aspectHeight** | `int` | No | The aspect height. |

### pip.enableWhenBackground

Enable PIP when background.

```dart
Future<ZegoPiPStatus> enableWhenBackground({
  int aspectWidth = 9,
  int aspectHeight = 16,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **aspectWidth** | `int` | No | The aspect width. |
| **aspectHeight** | `int` | No | The aspect height. |

### pip.cancelBackground

Cancel background PIP.

```dart
Future<void> cancelBackground()
```

### audioVideo.microphone.turnOn

Turn on/off microphone.

```dart
Future<void> turnOn(bool isOn, {String? userID})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **isOn** | `bool` | Yes | Whether to turn on. |
| **userID** | `String?` | No | The user ID. |

### audioVideo.microphone.switchState

Switch microphone state.

```dart
void switchState({String? userID})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **userID** | `String?` | No | The user ID. |

### audioVideo.camera.turnOn

Turn on/off camera.

```dart
Future<void> turnOn(bool isOn, {String? userID})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **isOn** | `bool` | Yes | Whether to turn on. |
| **userID** | `String?` | No | The user ID. |

### audioVideo.camera.switchState

Switch camera state.

```dart
void switchState({String? userID})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **userID** | `String?` | No | The user ID. |

### audioVideo.camera.switchFrontFacing

Switch front facing camera.

```dart
void switchFrontFacing(bool isFrontFacing)
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **isFrontFacing** | `bool` | Yes | Whether to use front facing camera. |

### audioVideo.audioOutput.switchToSpeaker

Switch to speaker.

```dart
void switchToSpeaker(bool isSpeaker)
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **isSpeaker** | `bool` | Yes | Whether to use speaker. |

### screenSharing.showViewInFullscreenMode

Set fullscreen display mode for screen sharing.

```dart
void showViewInFullscreenMode(String userID, bool isFullscreen)
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **userID** | `String` | Yes | The user ID. |
| **isFullscreen** | `bool` | Yes | Whether to enter or exit full-screen mode. |

**Example**
```dart
ZegoUIKitPrebuiltCallController().hangUp(context);
```

---

## ZegoSendCallInvitationButton

This button is used to send a call invitation to one or more specified users.

**Constructor:**

```dart
const ZegoSendCallInvitationButton({
  Key? key,
  required List<ZegoUIKitUser> invitees,
  required bool isVideoCall,
  String? callID,
  String customData = '',
  Future<bool> Function()? onWillPressed,
  void Function(String code, String message, List<String>)? onPressed,
  String? resourceID,
  String? notificationTitle,
  String? notificationMessage,
  int timeoutSeconds = 60,
  Size? buttonSize,
  double? borderRadius,
  ButtonIcon? icon,
  Size? iconSize,
  bool iconVisible = true,
  String? text,
  TextStyle? textStyle,
  double? iconTextSpacing,
  bool verticalLayout = true,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  Color? clickableTextColor = Colors.black,
  Color? unclickableTextColor = Colors.black,
  Color? clickableBackgroundColor = Colors.transparent,
  Color? unclickableBackgroundColor = Colors.transparent,
  ZegoNetworkLoadingConfig? networkLoadingConfig,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **invitees** | `List<ZegoUIKitUser>` | Yes | The list of invitees to send the call invitation to. |
| **isVideoCall** | `bool` | Yes | Determines whether the call is a video call. |
| **callID** | `String?` | No | The call ID. |
| **customData** | `String` | No | Custom data. |
| **onWillPressed** | `Future<bool> Function()?` | No | Send call invitation if return true, false will do nothing. |
| **onPressed** | `void Function(String, String, List<String>)?` | No | Callback function that is executed when the button is pressed. |
| **resourceID** | `String?` | No | The resource ID for notification. |
| **notificationTitle** | `String?` | No | The title for the notification. |
| **notificationMessage** | `String?` | No | The message for the notification. |
| **timeoutSeconds** | `int` | No | The timeout duration in seconds for the call invitation. |
| **buttonSize** | `Size?` | No | The size of the button. |
| **borderRadius** | `double?` | No | The radius of the button. |
| **icon** | `ButtonIcon?` | No | The icon widget for the button. |
| **iconSize** | `Size?` | No | The size of the icon. |
| **iconVisible** | `bool` | No | Whether the icon is visible. |
| **text** | `String?` | No | The text of the button. |
| **textStyle** | `TextStyle?` | No | The style of the text. |
| **iconTextSpacing** | `double?` | No | The spacing between the icon and the text. |
| **verticalLayout** | `bool` | No | Whether the layout is vertical. |
| **margin** | `EdgeInsetsGeometry?` | No | The margin of the button. |
| **padding** | `EdgeInsetsGeometry?` | No | The padding of the button. |
| **clickableTextColor** | `Color?` | No | The text color when the button is clickable. |
| **unclickableTextColor** | `Color?` | No | The text color when the button is unclickable. |
| **clickableBackgroundColor** | `Color?` | No | The background color when the button is clickable. |
| **unclickableBackgroundColor** | `Color?` | No | The background color when the button is unclickable. |
| **networkLoadingConfig** | `ZegoNetworkLoadingConfig?` | No | The network loading configuration. |

**Example**
```dart
ZegoSendCallInvitationButton(
  invitees: [ZegoUIKitUser(id: 'user_id', name: 'User')],
  isVideoCall: true,
  onPressed: (code, message, invitees) {
    debugPrint('onPressed: $code, $message');
  },
)
```

---

## ZegoSendCallingInvitationButton

This button is used to invite again when already in calling.

**Constructor:**

```dart
const ZegoSendCallingInvitationButton({
  Key? key,
  required String callID,
  required List<ZegoCallUser> waitingSelectUsers,
  required List<ZegoCallUser> selectedUsers,
  List<ZegoCallUser> Function(List<ZegoCallUser>)? userSort,
  ButtonIcon? buttonIcon,
  String? popUpTitle,
  TextStyle? popUpTitleStyle,
  Size? buttonIconSize,
  Size? buttonSize,
  ZegoAvatarBuilder? avatarBuilder,
  Widget Function(List<ZegoCallUser>, List<ZegoCallUser>, void Function(List<ZegoCallUser>))? sheetBuilder,
  Color? userNameColor,
  Widget? popUpBackIcon,
  Widget? inviteButtonIcon,
  bool defaultChecked = true,
  ZegoNetworkLoadingConfig? networkLoadingConfig,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **callID** | `String` | Yes | The call ID. |
| **waitingSelectUsers** | `List<ZegoCallUser>` | Yes | Waiting for selected users. |
| **selectedUsers** | `List<ZegoCallUser>` | Yes | Selected users. |
| **userSort** | `Function?` | No | The sorting method of the user list. |
| **buttonIcon** | `ButtonIcon?` | No | Icon. |
| **popUpTitle** | `String?` | No | Title of pop-up. |
| **popUpTitleStyle** | `TextStyle?` | No | Title style of pop-up. |
| **buttonIconSize** | `Size?` | No | Icon size. |
| **buttonSize** | `Size?` | No | Button size. |
| **avatarBuilder** | `ZegoAvatarBuilder?` | No | Avatar builder. |
| **sheetBuilder** | `Function?` | No | Sheet builder. |
| **userNameColor** | `Color?` | No | User name color. |
| **popUpBackIcon** | `Widget?` | No | Back icon of pop-up. |
| **inviteButtonIcon** | `Widget?` | No | Icon of invite button. |
| **defaultChecked** | `bool` | No | Whether to default check the waiting users. |
| **networkLoadingConfig** | `ZegoNetworkLoadingConfig?` | No | Network loading configuration. |

**Example**
```dart
ZegoSendCallingInvitationButton(
  callID: callID,
  waitingSelectUsers: [ZegoCallUser('user_id', 'User')],
)
```

---

## ZegoSendCallingInvitationList

A list widget for displaying and selecting users to invite during an ongoing call.

**Constructor:**

```dart
const ZegoSendCallingInvitationList({
  Key? key,
  required this.callID,
  required this.waitingSelectUsers,
  required this.onPressed,
  this.selectedUsers = const [],
  this.userSort,
  this.buttonIcon,
  this.popUpTitle,
  this.popUpTitleStyle,
  this.buttonIconSize,
  this.buttonSize,
  this.avatarBuilder,
  this.userNameColor,
  this.popUpBackIcon,
  this.inviteButtonIcon,
  this.defaultChecked = true,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **callID** | `String` | Yes | The call ID. |
| **waitingSelectUsers** | `List<ZegoCallUser>` | Yes | Users waiting to be selected (not in a call, not invited). |
| **onPressed** | `void Function(List<ZegoCallUser>)` | Yes | Callback after clicking the invite button. |
| **selectedUsers** | `List<ZegoCallUser>` | No | Users already selected (in a call or invited). |
| **userSort** | `List<ZegoCallUser> Function(List<ZegoCallUser>)?` | No | Member list sorting function. |
| **buttonIcon** | `ButtonIcon?` | No | Icon for the invite button. |
| **popUpTitle** | `String?` | No | Title of the pop-up. Default is 'Invitees'. |
| **popUpTitleStyle** | `TextStyle?` | No | Title style of the pop-up. |
| **buttonIconSize** | `Size?` | No | Icon size. |
| **buttonSize** | `Size?` | No | Button size. |
| **avatarBuilder** | `ZegoAvatarBuilder?` | No | Avatar builder. |
| **userNameColor** | `Color?` | No | User name color. |
| **popUpBackIcon** | `Widget?` | No | Back icon of the pop-up. |
| **inviteButtonIcon** | `Widget?` | No | Icon of the invite button. |
| **defaultChecked** | `bool` | No | Whether to default select waiting members. Default is `true`. |

### showCallingInvitationListSheet

Display a call invitation list pop-up.

```dart
void showCallingInvitationListSheet(
  BuildContext context, {
  required String callID,
  required List<ZegoCallUser> waitingSelectUsers,
  required void Function(List<ZegoCallUser> selectedUsers) onPressed,
  bool defaultChecked = true,
  List<ZegoCallUser> selectedUsers = const [],
  List<ZegoCallUser> Function(List<ZegoCallUser>)? userSort,
  bool rootNavigator = false,
  ButtonIcon? buttonIcon,
  Size? buttonIconSize,
  Size? buttonSize,
  ZegoAvatarBuilder? avatarBuilder,
  Color? userNameColor,
  Color? backgroundColor,
  String? popUpTitle,
  TextStyle? popUpTitleStyle,
  Widget? popUpBackIcon,
  Widget? inviteButtonIcon,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **context** | `BuildContext` | Yes | The build context. |
| **callID** | `String` | Yes | The call ID. |
| **waitingSelectUsers** | `List<ZegoCallUser>` | Yes | Users waiting to be selected (not in a call, not invited). |
| **onPressed** | `void Function(List<ZegoCallUser>)` | Yes | Callback after clicking the invite button. |
| **defaultChecked** | `bool` | No | Whether to default select waiting members. Default is `true`. |
| **selectedUsers** | `List<ZegoCallUser>` | No | Users already selected (in a call or invited). |
| **userSort** | `List<ZegoCallUser> Function(List<ZegoCallUser>)?` | No | Member list sorting function. |
| **rootNavigator** | `bool` | No | Whether to use root navigator. |
| **buttonIcon** | `ButtonIcon?` | No | Icon for the invite button. |
| **buttonIconSize** | `Size?` | No | Icon size. |
| **buttonSize** | `Size?` | No | Button size. |
| **avatarBuilder** | `ZegoAvatarBuilder?` | No | Avatar builder. |
| **userNameColor** | `Color?` | No | User name color. |
| **backgroundColor** | `Color?` | No | Background color. |
| **popUpTitle** | `String?` | No | Title of the pop-up. Default is 'Invitees'. |
| **popUpTitleStyle** | `TextStyle?` | No | Title style of the pop-up. |
| **popUpBackIcon** | `Widget?` | No | Back icon of the pop-up. |
| **inviteButtonIcon** | `Widget?` | No | Icon of the invite button. |

**Example**
```dart
ZegoSendCallingInvitationList(
  callID: callID,
  waitingSelectUsers: [ZegoCallUser('user_id', 'User')],
)
```

---

## ZegoUIKitPrebuiltCallMiniOverlayPage

The page can be minimized within the app.

**Constructor:**

```dart
const ZegoUIKitPrebuiltCallMiniOverlayPage({
  Key? key,
  required BuildContext Function() contextQuery,
  bool rootNavigator = true,
  bool navigatorWithSafeArea = true,
  Size? size,
  Offset topLeft = const Offset(100, 100),
  double borderRadius = 6.0,
  Color borderColor = Colors.black12,
  Color soundWaveColor = const Color(0xff2254f6),
  double padding = 0.0,
  bool showDevices = true,
})
```

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| **contextQuery** | `BuildContext Function()` | Yes | Callback to obtain the context. |
| **rootNavigator** | `bool` | No | Same as Flutter's Navigator's param. |
| **navigatorWithSafeArea** | `bool` | No | Whether to use SafeArea. |
| **size** | `Size?` | No | The size of the overlay. |
| **topLeft** | `Offset` | No | The initial position of the overlay. |
| **borderRadius** | `double` | No | The border radius. |
| **borderColor** | `Color` | No | The border color. |
| **soundWaveColor** | `Color` | No | The color of the sound wave. |
| **padding** | `double` | No | The padding. |
| **showDevices** | `bool` | No | Whether to show devices. |

**Example**
```dart
ZegoUIKitPrebuiltCallMiniOverlayPage(
  contextQuery: () => context,
)
```
