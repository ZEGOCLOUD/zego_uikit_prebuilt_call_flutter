- [Call Events](#call-events)
  - [onError](#onerror)
  - [onHangUpConfirmation](#onhangupconfirmation)
  - [onCallEnd](#oncallend)
  - [user](#userzegouikitprebuiltcalluserevents)
     - [onEnter](#onenter)
     - [onLeave](#onleave)
  - [room](#roomzegouikitprebuiltcallroomevents)
     - [onStateChanged](#onstatechanged)
  - [audioVideo](#audiovideozegouikitprebuiltcallaudiovideoevents)
     - [onCameraStateChanged](#oncamerastatechanged)
     - [onFrontFacingCameraStateChanged](#onfrontfacingcamerastatechanged)
     - [onMicrophoneStateChanged](#onmicrophonestatechanged)
     - [onAudioOutputChanged](#onaudiooutputchanged)
     - [onLocalCameraExceptionOccurred](#onlocalcameraexceptionoccurred)
     - [onLocalMicrophoneExceptionOccurred](#onlocalmicrophoneexceptionoccurred)
     - [onRemoteCameraExceptionOccurred](#onremotecameraexceptionoccurred)
     - [onRemoteMicrophoneExceptionOccurred](#onremotemicrophoneexceptionoccurred)
- [Invitation Events](#invitation-events)
  - [onError](#onerror-2)
  - [onInvitationUserStateChanged](#oninvitationuserstatechanged)
  - [onIncomingCallDeclineButtonPressed](#onincomingcalldeclinebuttonpressed)
  - [onIncomingCallAcceptButtonPressed](#onincomingcallacceptbuttonpressed)
  - [onIncomingCallReceived](#onincomingcallreceived)
  - [onIncomingCallCanceled](#onincomingcallcanceled)
  - [onIncomingCallTimeout](#onincomingcalltimeout)
  - [onOutgoingCallCancelButtonPressed](#onoutgoingcallcancelbuttonpressed)
  - [onOutgoingCallAccepted](#onoutgoingcallaccepted)
  - [onOutgoingCallRejectedCauseBusy](#onoutgoingcallrejectedcausebusy)
  - [onOutgoingCallDeclined](#onoutgoingcalldeclined)
  - [onOutgoingCallTimeout](#onoutgoingcalltimeout)

---

# Call Events

## onError

>
>- function prototype:
>```dart
>Function(ZegoUIKitError)? onError
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onError: (ZegoUIKitError) {
>       ...
>   }),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onError: (ZegoUIKitError) {
>       ...
>   }),
>);
>```

## onHangUpConfirmation

>
> Confirmation callback method before hang up the call.
>
> If you want to perform more complex business logic before exiting the call, such as updating some records to the backend, you can use the **onLeaveConfirmation** parameter to set it.
>
> This parameter requires you to provide a callback method that returns an asynchronous result.
>
> If you return true in the callback, the prebuilt page will quit and return to your previous page, otherwise it will be ignored.
>
>- function prototype:
   >  ```dart
>  Future<bool?> Function(BuildContext context)? onHangUpConfirmation;
>  ```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onHangUpConfirmation: (context) {
>       ...
>   }),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onHangUpConfirmation: (context) {
>       ...
>   }),
>);
>```

## onCallEnd

>
> This callback is triggered when call end, you can differentiate the reasons for call ended by using the **event.reason**, if the call ended reason is due to being kicked, you can determine who initiated the kick by using the variable **event.kickerUserID**.
>
> The default action is to return to the previous page like following:
>
>```dart
>onCallEnd: (
>    ZegoCallEndEvent event,
>    /// defaultAction to return to the previous page
>    VoidCallback defaultAction,
>) {
>  debugPrint('onCallEnd, do whatever you want');
>
>  /// you can call this defaultAction to return to the previous page,
>  defaultAction.call();
>
>  /// OR perform the page navigation yourself to return to the previous page.
>  /// if (ZegoCallMiniOverlayPageState.idle !=
>  ///     ZegoUIKitPrebuiltCallController().minimize.state) {
>  ///   /// now is minimizing state, not need to navigate, just hide
>  ///   ZegoUIKitPrebuiltCallController().minimize.hide();
>  /// } else {
>  ///   Navigator.of(context).pop();
>  /// }
>}
>```
>
> If you override this callback, you MUST perform the page navigation yourself to return to the previous page(easy way is call **defaultAction.call()**)!!! otherwise the user will remain on the current call page !!!!!
>
> You can perform business-related prompts or other actions in this callback. For example, you can perform custom logic during the hang-up operation, such as recording log information, stopping recording, etc.
>
>- function prototype:
>```dart
>void Function(
>  ZegoCallEndEvent event,
>
>  /// defaultAction to return to the previous page
>  VoidCallback defaultAction,
>)? onCallEnd;
>
>
>class ZegoCallEndEvent {
>  /// the user ID of who kick you out
>  String? kickerUserID;
>
>  /// end reason
>  ZegoCallEndReason reason;
>}
>
>/// The default behavior is to return to the previous page.
>///
>/// If you override this callback, you must perform the page navigation
>/// yourself to return to the previous page!!!
>/// otherwise the user will remain on the current call page !!!!!
>enum ZegoCallEndReason {
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
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onCallEnd: (event, defaultAction) {
>       ...
>   }),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(onCallEnd: (event, defaultAction) {
>       ...
>   }),
>);
>```

## user(ZegoCallUserEvents)

>
> events about user

### onEnter

>
> This callback is triggered when user enter
>
>- function prototype:
>```dart
>void Function(ZegoUIKitUser)? onEnter;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       user: ZegoCallUserEvents(
>           onEnter: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       user: ZegoCallUserEvents(
>           onEnter: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onLeave

>
> This callback is triggered when user leave
>- function prototype:
>```dart
>void Function(ZegoUIKitUser)? onLeave;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       user: ZegoCallUserEvents(
>           onLeave: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       user: ZegoCallUserEvents(
>           onLeave: (user) {
>               ...
>           },
>       ),
>   ),
>);
>```

## room(ZegoCallRoomEvents)

> 
> events about room

### onStateChanged

> 
> This callback is triggered when room state changed, you can get the current call room entry status by using the **state.reason**.
>
>- function prototype:
>```dart
>void Function(ZegoUIKitRoomState)? onStateChanged;
>
>class ZegoUIKitRoomState {
>  ///  Room state change reason.
>  ZegoRoomStateChangedReason reason;
>
>  /// Error code, please refer to the error codes document https://doc-en.zego.im/en/5548.html for >details.
>  int errorCode;
>
>  /// Extended Information with state updates. When the room login is successful, the key >"room_session_id" can be used to obtain the unique RoomSessionID of each audio and video communication, >which identifies the continuous communication from the first user in the room to the end of the audio and >video communication. It can be used in scenarios such as call quality scoring and call problem diagnosis.
>  Map<String, dynamic> extendedData;
>}
>
>/// Room state change reason.
>enum ZegoRoomStateChangedReason {
>  /// Logging in to the room. When calling [loginRoom] to log in to the room or [switchRoom] to switch to >the target room, it will enter this state, indicating that it is requesting to connect to the server. The >application interface is usually displayed through this state.
>  Logining,
>
>  /// Log in to the room successfully. When the room is successfully logged in or switched, it will enter >this state, indicating that the login to the room has been successful, and users can normally receive >callback notifications of other users in the room and all stream information additions and deletions.
>  Logined,
>
>  /// Failed to log in to the room. When the login or switch room fails, it will enter this state, >indicating that the login or switch room has failed, for example, AppID or Token is incorrect, etc.
>  LoginFailed,
>
>  /// The room connection is temporarily interrupted. If the interruption occurs due to poor network >quality, the SDK will retry internally.
>  Reconnecting,
>
>  /// The room is successfully reconnected. If there is an interruption due to poor network quality, the >SDK will retry internally, and enter this state after successful reconnection.
>  Reconnected,
>
>  /// The room fails to reconnect. If there is an interruption due to poor network quality, the SDK will >retry internally, and enter this state after the reconnection fails.
>  ReconnectFailed,
>
>  /// Kicked out of the room by the server. For example, if you log in to the room with the same user >name in other places, and the local end is kicked out of the room, it will enter this state.
>  KickOut,
>
>  /// Logout of the room is successful. It is in this state by default before logging into the room. When >calling [logoutRoom] to log out of the room successfully or [switchRoom] to log out of the current room >successfully, it will enter this state.
>  Logout,
>
>  /// Failed to log out of the room. Enter this state when calling [logoutRoom] fails to log out of the >room or [switchRoom] fails to log out of the current room internally.
>  LogoutFailed
>}
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       room: ZegoCallRoomEvents(
>           onStateChanged: (state) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       room: ZegoCallRoomEvents(
>           onStateChanged: (state) {
>               ...
>           },
>       ),
>   ),
>);
>```

## audioVideo(ZegoCallAudioVideoEvents)

> 
> events about audio video

### onCameraStateChanged

> 
> This callback is triggered when camera state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onCameraStateChanged;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onCameraStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onCameraStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onFrontFacingCameraStateChanged

>
> This callback is triggered when front camera state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onFrontFacingCameraStateChanged;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onFrontFacingCameraStateChanged: (isFronted) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onFrontFacingCameraStateChanged: (isFronted) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onMicrophoneStateChanged

>
> This callback is triggered when microphone state changed
>
>- function prototype:
>``` dart
>void Function(bool)? onMicrophoneStateChanged;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onMicrophoneStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onMicrophoneStateChanged: (isOpened) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onAudioOutputChanged

>
> This callback is triggered when audio output device changed
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitAudioRoute)? onAudioOutputChanged;
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onAudioOutputChanged: (audioRoute) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onAudioOutputChanged: (audioRoute) {
>               ...
>           },
>       ),
>   ),
>);
>```

<details>
<summary>ZegoUIKitDeviceExceptionType</summary>

```dart
enum ZegoUIKitDeviceExceptionType {
  /// Unknown device exception.
  unknown,

  /// Generic device exception.
  generic,

  /// Invalid device ID exception.
  invalidId,

  /// Device permission is not granted.
  permissionNotGranted,

  /// The capture frame rate of the device is 0.
  zeroCaptureFps,

  /// The device is being occupied.
  deviceOccupied,

  /// The device is unplugged (not plugged in).
  deviceUnplugged,

  /// The device requires the system to restart before it can work (Windows platform only).
  rebootRequired,

  /// The system media service is unavailable, e.g. when the iOS system detects that the current pressure is huge (such as playing a lot of animation), it is possible to disable all media related services (Apple platform only).
  mediaServicesWereLost,

  /// The device is being occupied by Siri (Apple platform only).
  siriIsRecording,

  /// The device captured sound level is too low (Windows platform only).
  soundLevelTooLow,

  /// The device is being occupied, and maybe cause by iPad magnetic case (Apple platform only).
  magneticCase,

  /// Audio session deactivate (Apple platform only).
  audioSessionDeactivate,

  /// Audio session category change (Apple platform only).
  audioSessionCategoryChange,

  /// The device is interrupted, such as a phone call interruption, etc.
  interruption,

  /// There are multiple apps at the same time in the foreground, such as the iPad app split screen, the system will prohibit all apps from using the camera.
  inBackground,

  /// CDN server actively disconnected
  multiForegroundApp,

  /// The system is under high load pressure and may cause abnormal equipment.
  bySystemPressure,
}
```

</details>

### onLocalCameraExceptionOccurred

>
> This callback is triggered when local camera device exceptions happen
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitDeviceExceptionType?)? onLocalCameraExceptionOccurred
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onLocalCameraExceptionOccurred: (exception) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onLocalCameraExceptionOccurred: (exception) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onLocalMicrophoneExceptionOccurred

>
> This callback is triggered when local microphone device exceptions happen
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitDeviceExceptionType?)? onLocalMicrophoneExceptionOccurred
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onLocalMicrophoneExceptionOccurred: (exception) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onLocalMicrophoneExceptionOccurred: (exception) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onRemoteCameraExceptionOccurred

>
> This callback is triggered when remote user's camera device exceptions happen
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitUser, ZegoUIKitDeviceExceptionType?)? onRemoteCameraExceptionOccurred
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onRemoteCameraExceptionOccurred: (user, exception) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onRemoteCameraExceptionOccurred: (user, exception) {
>               ...
>           },
>       ),
>   ),
>);
>```

### onRemoteMicrophoneExceptionOccurred

>
> This callback is triggered when remote user's microphone device exceptions happen
>
>- function prototype:
>``` dart
>void Function(ZegoUIKitUser, ZegoUIKitDeviceExceptionType?)? onRemoteMicrophoneExceptionOccurred
>```
>- example in service:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onRemoteMicrophoneExceptionOccurred: (user, exception) {
>               ...
>           },
>       ),
>   ),
>);
>```
>- example in prebuilt:
>```dart
>ZegoUIKitPrebuiltCall(
>   ...
>   events: ZegoUIKitPrebuiltCallEvents(
>       audioVideo: ZegoCallAudioVideoEvents(
>           onRemoteMicrophoneExceptionOccurred: (user, exception) {
>               ...
>           },
>       ),
>   ),
>);
>```


# Invitation Events

## onError

>
>- function prototype:
>```dart
>Function(ZegoUIKitError)? onError;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onError: (error) {
>           ...
>       },
>   ),
>);
>```

## onInvitationUserStateChanged

>
> This callback will be triggered to **caller** or **callee** in current calling inviting when the other calling member accepts, rejects, or exits, or the response times out.
>
> If the user is not the inviter who initiated this call invitation or is not online, the callback will not be received.
>
>- function prototype:
>```dart
>Function(List<ZegoSignalingPluginInvitationUserInfo>)? onInvitationUserStateChanged;
>
>/// Call invitation user information.
>class ZegoSignalingPluginInvitationUserInfo {
>  /// Description:  userID.
>  final String userID;
>
>  /// Description:  user status.
>  final ZegoSignalingPluginInvitationUserState state;
>
>  final String extendedData;
>}
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onInvitationUserStateChanged: (userInfos) {
>           ...
>       },
>   ),
>);
>```


## onIncomingCallDeclineButtonPressed

>
> This callback will be triggered to **callee** when callee click decline button in incoming call
>
>- function prototype:
>```dart
>Function()? onIncomingCallDeclineButtonPressed;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onIncomingCallDeclineButtonPressed: () {
>           ...
>       },
>   ),
>);
>```


## onIncomingCallAcceptButtonPressed

>
> This callback will be triggered to **callee** when callee click accept button in incoming call
>
>- function prototype:
>```dart
>Function()? onIncomingCallAcceptButtonPressed;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onIncomingCallAcceptButtonPressed: () {
>           ...
>       },
>   ),
>);
>```


## onIncomingCallReceived

>
> This callback will be triggered to **callee** when callee receive a call
>
>- function prototype:
>```dart
>  Function(
>    String callID,
>    ZegoCallUser caller,
>    ZegoCallInvitationType callType,
>    List<ZegoCallUser> callees,
>    String customData,
>  )? onIncomingCallReceived;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onIncomingCallReceived: (callID, caller, callType, callees, customData) {
>           ...
>       },
>   ),
>);
>```

## onIncomingCallCanceled

>
> This callback will be triggered to **callee** when the caller cancels the call invitation.
>
>- function prototype:
>```dart
>  Function(
>    String callID,
>    ZegoCallUser caller,
>    String customData,
>  )? onIncomingCallCanceled;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onIncomingCallCanceled: (callID, caller, customData) {
>           ...
>       },
>   ),
>);
>```

## onIncomingCallTimeout

>
> The **callee** will receive a notification through this callback when the callee doesn't respond to the call invitation after a timeout duration.
>
>- function prototype:
>```dart
>Function(String callID, ZegoCallUser caller)? onIncomingCallTimeout;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onIncomingCallTimeout: (callID, caller) {
>           ...
>       },
>   ),
>);
>```

## onOutgoingCallCancelButtonPressed

>
> This callback will be triggered to **caller** when caller cancels the call invitation by click the cancel button
>
>- function prototype:
>```dart
>Function()? onOutgoingCallCancelButtonPressed;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onOutgoingCallCancelButtonPressed: () {
>           ...
>       },
>   ),
>);
>```

## onOutgoingCallAccepted

>
> The **caller** will receive a notification through this callback when the callee accepts the call invitation.
>
>- function prototype:
>```dart
>Function(String callID, ZegoCallUser callee)? onOutgoingCallAccepted;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onOutgoingCallAccepted: (callID, callee) {
>           ...
>       },
>   ),
>);
>```

## onOutgoingCallRejectedCauseBusy

>
> The **caller** will receive a notification through this callback when the callee rejects the call invitation (the callee is busy).
>
>- function prototype:
>```
>  Function(
>    String callID,
>    ZegoCallUser callee,
>    String customData,
>  )? onOutgoingCallRejectedCauseBusy;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
>           ...
>       },
>   ),
>);
>```

## onOutgoingCallDeclined

>
> The **caller** will receive a notification through this callback when the callee declines the call invitation actively.
>
>- function prototype:
>```dart
>  Function(
>    String callID,
>    ZegoCallUser callee,
>    String customData,
>  )? onOutgoingCallDeclined;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onOutgoingCallDeclined: (callID, callee, customData) {
>           ...
>       },
>   ),
>);
>```

## onOutgoingCallTimeout

>
> The **caller** will receive a notification through this callback when the call invitation didn't get responses after a timeout duration.
>
>- function prototype:
>```dart
>  Function(
>    String callID,
>    List<ZegoCallUser> callees,
>    bool isVideoCall,
>  )? onOutgoingCallTimeout;
>```
>- example:
>```dart
>ZegoUIKitPrebuiltCallInvitationService().init(
>   ...
>   invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
>       onOutgoingCallTimeout: (callID, callees, isVideoCall) {
>           ...
>       },
>   ),
>);
>```

