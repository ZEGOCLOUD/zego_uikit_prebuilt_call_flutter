# Get started

> <div style="position: relative; width: 100%; 
>   padding-top: calc(100% * 720 / 1280); 
>   border: 2px black solid;">
>   <iframe 
>     src="https://www.youtube.com/embed/RowFWxNfQhc" 
>     title="How to build video call using Flutter in 10 mins with ZEGOCLOUD"
>     style="position: absolute; width: 100%; height: 100%; top: 0;"
>     frameborder="0" 
>     allow="accelerometer; 
>     autoplay; 
>     clipboard-write; 
>     encrypted-media; gyroscope; 
>     picture-in-picture; 
>     web-share" 
>     allowfullscreen>
>   </iframe>
> </div>
>

- - -

## Integrate the SDK

### Using the ZegoUIKitPrebuiltCall in your project

>
>- Go to [ZEGOCLOUD Admin Console](https://console.zegocloud.com/), get the `appID` and `appSign` of your project.
>- Specify the `userID` and `userName` for connecting the Call Kit service.
>- Create a `callID` that represents the call you want to make.
>
>> 
>> `userID` and `callID` can only contain numbers, letters, and underlines (_).
>> Users that join the call with the same `callID` can talk to each other.
>
>
>> ```dart
>> class CallPage extends StatelessWidget {
>>   const CallPage({Key? key, required this.callID}) : super(key: key);
>>   final String callID;
>> 
>>   @override
>>   Widget build(BuildContext context) {
>>     return ZegoUIKitPrebuiltCall(
>>       appID: yourAppID, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
>>       appSign: yourAppSign, // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
>>       userID: 'user_id',
>>       userName: 'user_name',
>>       callID: callID,
>>       // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
>>       config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall() 
>>         ..onOnlySelfInRoom = () => Navigator.of(context).pop(),
>>     );
>>   }
>> }
>> ```
>
>Now, you can make a new call by navigating to this `CallPage`.


## Configure your project

- Android:
> 
> 1. If your project is created with **Flutter 2.x.x**:
> 
>> a. Modify the `compileSdkVersion` to 33 in the `your_project/android/app/build.gradle` file.
>> 
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/compile_sdk_version.png" width="100%"/>
>> b. Modify the `minSdkVersion` in the same file:
>> 
>> ```xml
>> minSdkVersion 21
>> ```
>>
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/android_min_sdk_21.png" width="100%"/>
> 
> 2. Set the Kotlin & Gradle versions:
> 
>> a. Modify the `kotlin` version to >= 1.8.0 and the `gradle classpath` version to 7.3.0 in the `your_project/android/app/build.gradle` file:
>> 
>> ```xml
>> buildscript {
>>     ext.kotlin_version = '1.8.0'
>>     repositories {
>>         google()
>>         mavenCentral()
>>     }
>> 
>>     dependencies {
>>         classpath 'com.android.tools.build:gradle:7.3.0'
>>         classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
>> 
>>         // support notification
>>         classpath 'com.google.gms:google-services:4.3.14'
>>     }
>> }
>> ```
>> 
>> b. Make the `gradle` version >= 7.0: 
>> 
>> In the `your_project/android/gradle/wrapper/gradle-wrapper.properties` file, modify the `distributionUrl` to `https\://services.gradle.org/distributions/gradle-7.4-all.zip`.
>> 
>> ```xml
>> distributionUrl=https\://services.gradle.org/distributions/gradle-7.4-all.zip
>> ```
>>
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/call/kotlin180.jpg" width="100%"/>
> 
> 3. Add app permissions.
>>    Open the file `your_project/app/src/main/AndroidManifest.xml`, and add the following code:
>>    ```xml
>>    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
>>    <uses-permission android:name="android.permission.RECORD_AUDIO" />
>>    <uses-permission android:name="android.permission.INTERNET" />
>>    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
>>    <uses-permission android:name="android.permission.CAMERA" />
>>    <uses-permission android:name="android.permission.BLUETOOTH" />
>>    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
>>    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
>>    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
>>    <uses-permission android:name="android.permission.WAKE_LOCK" />
>>    ```
>>
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/permission_android.png" width="100%"/>
> 
> 
> 4. Prevent code obfuscation.
> 
>> To prevent obfuscation of the SDK public class names, do the following:
>> 
>> a. In your project's `your_project > android > app` folder, create a `proguard-rules.pro` file with the following content as shown below:
>> 
>> ```terminal
>> -keep class **.zego.** { *; }
>> ```
>> 
>> b. Add the following config code to the `release` part of the `your_project/android/app/build.gradle` file.
>> 
>> <pre style="background-color: #011627; border-radius: 8px; padding: 25px; color: white"><div>
>> proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
>> </div></pre>
>>
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/android_class_confusion.png" width="100%"/>

- iOS:

1. Add app permissions.

>
> a. Open the `your_project/ios/Podfile` file, and add the following to the `post_install do |installer|` part:
>> 
>> ```plist
>> # Start of the permission_handler configuration
>> target.build_configurations.each do |config|
>>   config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
>>     '$(inherited)',
>>     'PERMISSION_CAMERA=1',
>>     'PERMISSION_MICROPHONE=1',
>>   ]
>> end
>> # End of the permission_handler configuration
>> ```
>> 
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/live/permission_podfile.png" width="100%"/>
> 
> b. Open the `your_project/ios/Runner/Info.plist` file, and add the following to the `dict` part:
> 
>> ```plist
>>     <key>NSCameraUsageDescription</key>
>>     <string>We require camera access to connect</string>
>>     <key>NSMicrophoneUsageDescription</key>
>>     <string>We require microphone access to connect</string>
>> ```
>> 
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/permission_ios.jpg" width="100%"/>

2. Disable `Build Libraries for Distribution`

> 1. Open the your_project > iOS > Runner.xcworkspace file.
> 
> 2. Select your target project, and follow the notes on the following image to disable the `Build Libraries for Distribution`.
> 
>> <img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/call/call_disable_build_libraries_for_distribution.png" width="100%"/>

## Run & Test

>
>Now you have finished all the steps!
>
>You can simply click the **Run** or **Debug** to run and test your App on your device.
>
><img src="https://doc.oa.zego.im/Pics/ZegoUIKit/Flutter/run_flutter_project.jpg" width="100%"/>

## More

[Sample Code](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_example_flutter)