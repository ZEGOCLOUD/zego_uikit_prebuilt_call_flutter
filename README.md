# Overview

- - -

**Call Kit** is a prebuilt feature-rich call component, which enables you to build **one-on-one and group voice/video calls** into your app with only a few lines of code.

And it includes the business logic with the UI, you can add or remove features accordingly by customizing UI components.


|One-on-one call|Group call|
|---|---|
|![One-on-one call](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/_all_close.gif)|![Group call](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/conference/8C_little.jpg)|


## When do you need the Call Kit

- Build apps faster and easier
  - When you want to prototype 1-on-1 or group voice/video calls **ASAP** 

  - Consider **speed or efficiency** as the first priority

  - Call Kit allows you to integrate **in minutes**

- Customize UI and features as needed
  - When you want to customize in-call features **based on actual business needs**

  - **Less time wasted** developing basic features

  - Call Kit includes the business logic along with the UI, allows you to **customize features accordingly**


## Embedded features

- Ready-to-use one-on-one/group calls
- Customizable UI styles
- Real-time sound waves display
- Device management
- Switch views during a one-on-one call
- Extendable top/bottom menu bar
- Participant list

# Quick start

- - -


## Integrate the SDK

### Add ZegoUIKitPrebuiltCall as dependencies

Run the following code in your project root directory: 

```dart
flutter pub add zego_uikit_prebuilt_call
```

### Import the SDK

Now in your Dart code, import the prebuilt Call Kit SDK.

```dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
```

### Using the ZegoUIKitPrebuiltCall in your project

- Go to [ZEGOCLOUD Admin Console\|_blank](https://console.zegocloud.com/), get the `appID` and `appSign` of your project.
- Specify the `userID` and `userName` for connecting the Call Kit service. 
- Create a `callID` that represents the call you want to make. 

<div class="mk-hint">

- `userID` and `callID` can only contain numbers, letters, and underlines (_). 
- Users that join the call with the same `callID` can talk to each other. 
</div>

```dart
class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: yourAppID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign: yourAppSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: 'user_id',
      userName: 'user_name',
      callID: callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideo() 
        ..onOnlySelfInRoom = (context) => Navigator.of(context).pop(),
    );
  }
}
```

Now, you can make a new call by navigating to this `CallPage`.


### Call With Invitation

#### Add as dependencies

1. Edit your project's pubspec.yaml and add local project dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  zego_uikit_prebuilt_call: ^1.2.5 # Add this line
  zego_uikit_signaling_plugin: ^1.0.10 # Add this line
```

2. Execute the command as shown below under your project's root folder to install all dependencies

```dart
flutter pub get
```

#### Import SDK

Now in your Dart code, you can import prebuilt.

```dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
```

#### Integrate the call functionality with the invitation feature

##### 1. Warp your widget with ZegoUIKitPrebuiltCallInvitationService

> You can get the AppID and AppSign from [ZEGOCLOUD&#39;s Console](https://console.zegocloud.com).
> Users who use the same callID can talk to each other. (ZegoUIKitPrebuiltCallInvitationService supports 1 on 1 call and group call)

```dart
@override
Widget build(BuildContext context) {
   return ZegoUIKitPrebuiltCallInvitationService(
      appID: yourAppID,
      appSign: yourAppSign,
      userID: userID,
      userName: userName,
      requireConfig: (ZegoCallInvitationData data) {
         late ZegoUIKitPrebuiltCallConfig config;

         if (data.invitees.length > 1) {
            ///  group call
            config = ZegoInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.groupVoiceCall();
         } else {
            ///  one on one call
            config = ZegoInvitationType.videoCall == data.type
                    ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                    : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

            config.onHangUp = () {
               Navigator.of(context).pop();
            };
         }

         return config;
      },
      child: YourWidget(),
   );
}
```

##### 2. Add a button for making a call

```dart
ZegoStartCallCallInvitation(
   isVideoCall: true,
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

Now, you can invite someone to the call by simply clicking this button.

## Configure your project


### Android:
1. If your project is created with Flutter 2.x.x, you will need to open the `your_project/android/app/build.gradle` file, and modify the `compileSdkVersion` to 33.


![compileSdkVersion.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/compileSdkVersion.png)

2. Add app permissions.
Open the file `your_project/app/src/main/AndroidManifest.xml`, and add the following code:

```xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE"/>
```

![/Pics/ZegoUIKit/Flutter/permission_android.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_android.png)

### iOS: 

To add permissions, open `your_project/ios/Runner/Info.plist`, and add the following code to the `dict` part:

```
<key>NSCameraUsageDescription</key>
<string>We require camera access to connect to a call</string>
<key>NSMicrophoneUsageDescription</key>
<string>We require microphone access to connect to a call</string>
```

![/Pics/ZegoUIKit/Flutter/permission_ios.png](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/permission_ios.png)

### Turn off some classes's confusion

To prevent the ZEGO SDK public class names from being obfuscated, please complete the following steps:

1. Create `proguard-rules.pro` file under [your_project > android > app] with content as show below:
```
-keep class **.zego.** { *; }
```

2. Add the following config code to the release part of the `your_project/android/app/build.gradle` file.
```
proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
```

![image](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/android_class_confusion.png)


## Run & Test

Now you have finished all the steps!

You can simply click the **Run** or **Debug** to run and test your App on your device.

![/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg](https://storage.zego.im/sdk-doc/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg)

## Recommended resources

[Custom prebuilt UI](https://docs.zegocloud.com/article/14748)

[Complete Sample Code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter)

[About Us](https://www.zegocloud.com)

If you have any questions regarding bugs and feature requests, visit the [ZEGOCLOUD community](https://discord.gg/EtNRATttyp) or email us at global_support@zegocloud.com.
