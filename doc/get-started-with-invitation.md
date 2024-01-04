Get started with call invitation

> You can refer to this document to understand the effects of the offline call invitation (system-calling UI) and complete the basic integration.

> 1. If your project needs Firebase integration or customization of features like ringtone and UI, complete the basic integration first and then refer to advanced integration for further configuration.
> 2. Offline call invitation configuration is complex. If you only require online call invitations, please skip the steps related to firebase console and apple certificate.

---

# UI Implementation Effects

> Recorded on Xiaomi and iPhone, the outcome may differ on different devices.
>
>| Online call                                                                                                              | online call (Android App background) | offline call (Android App killed) | offline call (iOS Background/Killed) |
>|--------------------------------------------------------------------------------------------------------------------------| ---- | ---- | ---- |
>| ![xx](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/1online.gif) |    ![xx](https://media-resource.spreading.<br/>io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/2background.gif)  |    ![xx](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/3offline.gif)  |    ![xx](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/iOScallkit.gif)  |

# Integration Guide for Common Components

>
>It is recommended that you start by completing the integration of the common parts, and then proceed with the configuration for Android and iOS in sequence. After successfully setting up the first platform, you can begin configuring the second platform.

# Prerequisites

> 
> Go to [ZEGOCLOUD Admin Console](https://console.zegocloud.com) to create a UIKit project.
> 
> Get the **AppID** and **AppSign** of the project.
> 
> If you don't know how to create a project and obtain an app ID, please refer to [this guide](https://console.zegocloud.com).

## Add ZegoUIKitPrebuiltCall as a dependency

>
>1. Run the following code in your project root directory:
>```shell
>flutter pub add zego_uikit_prebuilt_call
>flutter pub add zego_uikit_signaling_plugin
>```
>2. Run the following code in your project root directory to install all dependencies.
>```shell
>flutter pub get
>```

## Import the SDK

>
>Now in your Dart code, import the prebuilt Call Kit SDK.
>```shell
>import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
>import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
>```


# Initialize the call invitation service
>
>To receive the call invites from others and let the calling notification show on the top bar when receiving it, you will need to initialize the call invitation service (ZegoUIKitPrebuiltCallInvitationService) first.


1. Set up the **navigatorkey**.
> 
>To make the UI show when receiving a call invite, you will need to set the navigatorkey. To do so, do the following steps:
>1.1 Define a navigatorkey.
>1.2 Set the navigatorKey to ZegoUIKitPrebuiltCallInvitationService.
>1.3 Register the navigatorKey to MaterialApp.(If you are using GoRouter, you need to register the navigatorKey to GoRouter.)

2. call the **useSystemCallingUI** method in the main.dart file.
>
><details>
><summary>Example Codes</summary>
>
>```dart
>/// 1.1 define a navigator key or get navigator key from others
>final navigatorKey = GlobalKey();
>
>void main() async {
>  WidgetsFlutterBinding.ensureInitialized();
>
>  /// 1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
>  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
>
>  // 2. call the useSystemCallingUI
>  ZegoUIKit().initLog().then((value) {
>    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
>      [ZegoUIKitSignalingPlugin()],
>    );
>
>    runApp(MyApp(navigatorKey: navigatorKey));
>  });
>}
>
>class MyApp extends StatefulWidget {
>  final GlobalKey navigatorKey;
>
>  const MyApp({
>    required this.navigatorKey,
>    Key? key,
>  }) : super(key: key);
>
>  @override
>  State createState() => MyAppState();
>}
>
>class MyAppState extends State {
>  @override
>  Widget build(BuildContext context) {
>    return MaterialApp(
>      /// 1.3: register the navigator key to MaterialApp
>      navigatorKey: widget.navigatorKey,
>      ...
>    );
>  }
>}
>```
>
></details>


3. Initialize/Deinitialize the call invitation service.
>
>After the user logs in, it is necessary to Initialize the ZegoUIKitPrebuiltCallInvitationService to ensure that it is initialized only once, avoiding errors caused by repeated initialization.
>
>When the user logs out, it is important to perform Deinitialize to clear the previous login records, preventing any impact on the next login.
> 
>![mermaid-diagram](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/mermaid-diagram-2023-10-19-170946.png)
>
><details>
><summary>Example Codes</summary>
>
>```dart
>/// on App's user login
>void onUserLogin() {
>  /// 3.1. initialized ZegoUIKitPrebuiltCallInvitationService
>  /// when app's user is logged in or re-logged in
>  /// We recommend calling this method as soon as the user logs in to your app.
>  ZegoUIKitPrebuiltCallInvitationService().init(
>    appID: yourAppID /*input your AppID*/,
>    appSign: yourAppSign /*input your AppSign*/,
>    userID: currentUser.id,
>    userName: currentUser.name,
>    plugins: [ZegoUIKitSignalingPlugin()],
>  );
>}
>
>/// on App's user logout
>void onUserLogout() {
>  /// 3.2. de-initialization ZegoUIKitPrebuiltCallInvitationService
>  /// when app's user is logged out
>  ZegoUIKitPrebuiltCallInvitationService().uninit();
>}
>```
>
></details>

# Add a call invitation button

Add the button for making call invitations, and pass in the ID of the user you want to call.

<details>
<summary>Example Codes</summary>

```dart
ZegoSendCallInvitationButton(
   isVideoCall: true,
   resourceID: "zegouikit_call", //You need to use the resourceID that you created in the subsequent steps. Please continue reading this document.
   invitees: [
      ZegoUIKitUser(
         id: targetUserID,
         name: targetUserName,
      ),
      ...
      ZegoUIKitUser(
         id: targetUserID,
         name: targetUserName,
      )
   ],
)
```

</details>

# Configure your project (Android)

>
> Please refer to the following steps to configure your Android project. 
> If you want to experience the functionality before integration, we have provided [sample code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter/tree/master/call_with_offline_invitation) that includes steps 2 through 6 
so you can quickly test it.

1. Firebase Console and ZEGO Console Configuration
>
>- step1. In the Firebase console: Create a project. (Resource may help: [Firebase Console](https://console.firebase.google.com/))
>
><div style="position: relative; width: 100%; 
>  padding-top: calc(100% * 720 / 1280); 
>  border: 2px black solid;">
>  <iframe 
>    src="https://youtu.be/HhP7rLirCA4" 
>    title="Offline push configuration - Android part 1"
>    style="position: absolute; width: 100%; height: 100%; top: 0;"
>    frameborder="0" 
>    allow="accelerometer; 
>    autoplay; 
>    clipboard-write; 
>    encrypted-media; gyroscope; 
>    picture-in-picture; 
>    web-share" 
>    allowfullscreen>
>  </iframe>
></div>
>
>- step2. In the ZegoCloud console: Add FCM certificate, create a resource ID;
>In the create resource ID popup dialog, you should switch to the VoIP option for APNs, and switch to Data messages for FCM.
>
><div style="position: relative; width: 100%; 
>  padding-top: calc(100% * 720 / 1280); 
>  border: 2px black solid;">
>  <iframe 
>    src="https://youtu.be/K3kRWyafRIY" 
>    title="Offline push configuration - Android part 2"
>    style="position: absolute; width: 100%; height: 100%; top: 0;"
>    frameborder="0" 
>    allow="accelerometer; 
>    autoplay; 
>    clipboard-write; 
>    encrypted-media; gyroscope; 
>    picture-in-picture; 
>    web-share" 
>    allowfullscreen>
>  </iframe>
></div>
>
>When you have completed the configuration, you will obtain the resourceID. You can refer to the image below for comparison.
> ![android_resource_id](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/android_resource_id.png)
> 
> - step3. In the Firebase console: Create an Android application and modify your code;
> 
><div style="position: relative; width: 100%; 
>  padding-top: calc(100% * 720 / 1280); 
>  border: 2px black solid;">
>  <iframe 
>    src="https://youtu.be/0f9Ai2uJM5o" 
>    title="Offline push configuration - Android part 3"
>    style="position: absolute; width: 100%; height: 100%; top: 0;"
>    frameborder="0" 
>    allow="accelerometer; 
>    autoplay; 
>    clipboard-write; 
>    encrypted-media; gyroscope; 
>    picture-in-picture; 
>    web-share" 
>    allowfullscreen>
>  </iframe>
></div>

2. Modify the compileSdkVersion and minSdkVersion
> 
> - step1. Modify the compileSdkVersion to 33 in the your_project/android/app/build.gradle file.
> ![compile_sdk_version](https://media-resource.spreading.io/5fa3f99cda659c8c9f2907cbb0242e6c/workspace86/compile_sdk_version.png)
> 
> - step2. Modify the minSdkVersion in the same file
> ```shell
> minSdkVersion 21
> ```

3. Set the Kotlin & Gradle versions
> 
> - step1. Modify the kotlin version to >= 1.8.0 and the gradle classpath version to 7.3.0 in the your_project/android/app/build.gradle file:
> ```shell
> buildscript {
>     ext.kotlin_version = '1.8.0'
>     repositories {
>         google()
>         mavenCentral()
>     }
> 
>     dependencies {
>         classpath 'com.android.tools.build:gradle:7.3.0'
>         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
> 
>         // support notification
>         classpath 'com.google.gms:google-services:4.3.14'
>     }
> }
> ```
4. 

