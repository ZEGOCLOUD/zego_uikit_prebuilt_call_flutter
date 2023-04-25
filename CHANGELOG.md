
## 3.3.7
- Update dependencies

## 3.3.6
- Update dependencies

## 3.3.5
- Fix some issues about iOS supports VoIP mode.

## 3.3.4
- Fix the issue with show notification box crashing when received a call background in iOS

## 3.3.3
- Fix the issue of missed call notifications not popping up when the app is in the background.

## 3.3.2
- mark 'appDesignSize' as Deprecated

## 3.3.1
- Update dependencies

## 3.3.0
- To differentiate the 'appDesignSize' between the App and ZegoUIKitPrebuiltCall, we introduced the 'flutter_screenutil_zego' library and removed the 'appDesignSize' parameter from the 
  ZegoUIKitPrebuiltCall that was previously present.

## 3.2.0
- For the offline calling feature, Android supports a silent push mode, while iOS supports VoIP mode.

## 3.1.1 
- Optimize the in-app minimization feature and add control for local camera and microphone; display the camera and microphone status of others; display user names.

## 3.1.0
- supports in-app minimization.

## 3.0.3
- fixed appDesignSize for ScreenUtil that didn't work

## 3.0.2-dev.1
- add sendCallInvitation function in ZegoUIKitPrebuiltCallController

## 3.0.1-dev.1
- onOutgoingCallRejectedCauseBusy and onOutgoingCallDeclined, these two event are trigger wrong

## 3.0.0-dev.1
- ZegoUIKitPrebuiltCallWithInvitation Widget class is deprecated, replace by a singleton instance ZegoUIKitPrebuiltCallInvitationService

## 2.1.3 
- add assert to key parameters to ensure prebuilt run normally

## 2.1.2
- Fixed landscape not displaying full web screen sharing content

## 2.1.1

- update dependency

## 2.1.0

- support screen share

## 2.0.1

* add appDesignSize for ScreenUtil in prebuilt param, if you use ScreenUtil, prebuilt will restore the param when dispose
* remove login token
* optimizing code warnings

## 2.0.0

* Architecture upgrade based on adapter.

## 1.4.3

* downgrade flutter_screenutil to ">=5.5.3+2 <5.6.1"

## 1.4.2

* fix some bugs

## 1.4.1

* fix some bugs

## 1.4.0

* support offline call
* support sdk log

## 1.2.14

* update a dependency to the latest release

## 1.2.13

* update a dependency to the latest release

## 1.2.12

* update a dependency to the latest release

## 1.2.11

* update a dependency to the latest release

## 1.2.10

* fix some bugs

## 1.2.9

* rename ZegoUIKitPrebuiltCallInvitationService to ZegoUIKitPrebuiltInvitationCall
* update a dependency to the latest release

## 1.2.8

* update a dependency to the latest release

## 1.2.7

* fix gallery layout

## 1.2.6

* fix some bugs

## 1.2.5

* update a dependency to the latest release

## 1.2.4

* fix some bugs

## 1.2.3

* fix some bugs

## 1.2.2

* update a dependency to the latest release

## 1.2.1

* fix some bugs

## 1.2.0

* support group call

## 1.1.4

* fix some bugs

## 1.1.3

* fix some bugs

## 1.1.2

* fix some bugs

## 1.1.1

* update a dependency to the latest release

## 1.1.0

* support group call
* fix some bugs

## 1.0.3

* fix some bugs

## 1.0.2

* fix some bugs

## 1.0.1

* fix some bugs
* update a dependency to the latest release

## 1.0.0

* Congratulations!

## 0.0.5

* fix some bugs
* update ZegoUIKitPrebuiltCallConfig

## 0.0.4

* fix some bugs

## 0.0.3

* fix some bugs
* remove **serverSecret** in init function
* update a dependency to the latest release

## 0.0.2

* update some documents

## 0.0.1

* Upload Initial release.
