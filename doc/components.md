
- [ZegoSendCallInvitationButton](#zegosendcallinvitationbutton)
- [ZegoSendCallingInvitationButton](#zegosendcallinginvitationbutton)
- [ZegoUIKitPrebuiltCallMiniOverlayPage && ZegoUIKitPrebuiltCallMiniPopScope](#zegouikitprebuiltcallminioverlaypage--zegouikitprebuiltcallminipopscope)

---

## ZegoSendCallInvitationButton

> This button is used to send a call invitation to one or more specified users.
>
> You can provide a target user list **invitees** and specify whether it is a video call **isVideoCall**. If it is not a video call, it defaults to an audio call.
> You can also pass additional custom data **customData** to the invitees.
> If you want to set a custom ringtone for the offline call invitation, set **resourceID** to a value that matches the push resource ID in the ZEGOCLOUD management console.
> You can also set the notification title **notificationTitle** and message **notificationMessage**.
> If the call times out, the call will automatically hang up after the specified timeout period **timeoutSeconds** (in seconds).

- List`<ZegoUIKitUser>` `invitees`: The list of invitees to send the call invitation to.
- String? `callID`: you can specify the call ID. If not provided, the system will generate one automatically based on certain rules.
- bool `isVideoCall`: Determines whether the call is a video call. If false, it is an audio call by default.
- String `customData`: Custom data to be passed to the invitee.
- Future`<bool>` Function()? `onWillPressed`: send call invitation if return true, false will do nothing
- void Function(String code, String message, List`<String>`)? `onPressed`: Callback function that is executed when the button is pressed.
- String? `resourceID`: The **resource id** for notification which same as [Zego Console](https://console.zegocloud.com/)
- String? `notificationTitle`: The title for the notification.
- String? `notificationMessage`: The message for the notification.
- int `timeoutSeconds`: The timeout duration in seconds for the call invitation.
- Size? `buttonSize`: The size of the button.
- double? `borderRadius`: The radius of the button.
- ButtonIcon? `icon`: The icon widget for the button.
- bool `iconVisible`: is icon visible or not
- Size? `iconSize`: The size of the icon.
- String? `text`: The text displayed on the button.
- TextStyle? `textStyle`: The text style for the button text.
- double? `iconTextSpacing`: The spacing between the icon and text.
- bool `verticalLayout`: Determines whether the layout is vertical or horizontal.
- EdgeInsetsGeometry? `margin`: padding of button
- EdgeInsetsGeometry? `padding`: padding of button
- Color? `clickableTextColor`: The text color when the button is clickable.
- Color? `clickableBackgroundColor`: The background color when the button is clickable.
- Color? `unclickableBackgroundColor`: The background color when the button is unclickable.

## ZegoSendCallingInvitationButton

> This button is used to invite again when **already in calling**
>
> pass the user you need to invite to **waitingSelectUsers**.
> If you want to display users who are already in a call (unable to kick out) to **selectedUsers**.
> If you need to sort the user list, you can set it through **userSort**.

- ButtonIcon? `buttonIcon`: icon
- Size? `buttonIconSize`: icon size
- Size? `buttonSize`: button size
- ZegoAvatarBuilder? `avatarBuilder`: avatar builder
- Color? `userNameColor`: color of user name
- String? `popUpTitle`: title of pop-up, default is 'Invitees'
- TextStyle? `popUpTitleStyle`: text style of pop-up\'s title
- Widget? `popUpBackIcon`: back icon of pop-up
- Widget? `inviteButtonIcon`: icon of invite button
- List`<ZegoCallUser>` `waitingSelectUsers`: Waiting for selected users, that is, users who have not yet participated in the call
- List`<ZegoCallUser>` `selectedUsers`: selected users (cannot be unselected again), that is, users who are already in the call
- List`<ZegoCallUser>` Function(List`<ZegoCallUser>`)? `userSort`: The sorting method of the user list, the default is to sort by user id
- bool `defaultChecked`: Whether **waitingSelectUsers** is selected by default

## ZegoUIKitPrebuiltCallMiniOverlayPage && ZegoUIKitPrebuiltCallMiniPopScope

> The page can be minimized within the app
> 
> To support the minimize functionality in the app:
> 
> 1. Add a minimize button.
> ```dart
> ZegoUIKitPrebuiltCallConfig.topMenuBar.buttons.add(ZegoCallMenuBarButtonName.minimizingButton)
> ```
> Alternatively, if you have defined your own button, you can call:
> ```dart
> ZegoUIKitPrebuiltCallController().minimize.minimize()
> ```
> 
> 2. Nest the `ZegoUIKitPrebuiltCallMiniOverlayPage` within your MaterialApp widget. Make sure to return the correct context in the `contextQuery` parameter.
> 
> How to add in MaterialApp, example:
> ```dart
> 
> void main() {
>   WidgetsFlutterBinding.ensureInitialized();
> 
>   final navigatorKey = GlobalKey<NavigatorState>();
>   runApp(MyApp(
>     navigatorKey: navigatorKey,
>   ));
> }
> 
> class MyApp extends StatefulWidget {
>   final GlobalKey<NavigatorState> navigatorKey;
> 
>   const MyApp({
>     required this.navigatorKey,
>     Key? key,
>   }) : super(key: key);
> 
>   @override
>   State<StatefulWidget> createState() => MyAppState();
> }
> 
> class MyAppState extends State<MyApp> {
>   @override
>   Widget build(BuildContext context) {
>     return MaterialApp(
>       title: 'Flutter Demo',
>       home: const ZegoUIKitPrebuiltCallMiniPopScope(
>         child: HomePage(),
>       ),
>       navigatorKey: widget.navigatorKey,
>       builder: (BuildContext context, Widget? child) {
>         return Stack(
>           children: [
>             child!,
> 
>             /// support minimizing
>             ZegoUIKitPrebuiltCallMiniOverlayPage(
>               contextQuery: () {
>                 return widget.navigatorKey.currentState!.context;
>               },
>             ),
>           ],
>         );
>       },
>     );
>   }
> }
> ```
> 