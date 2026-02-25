# Components

- [ZegoUIKitPrebuiltCall](#zegouikitprebuiltcall)
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
