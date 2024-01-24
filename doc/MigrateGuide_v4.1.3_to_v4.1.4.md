---

* [onHangUpConfirmation]

---

# Introduction

>
> In this migration guide, we will explain how to upgrade from version 4.1.3 to the latest 4.1.4 version. This document aims to help users understand the interface changes and feature improvements,
> and provide a migration guide for the upgrade process.

# Major Interface Changes

## onHangUpConfirmation

- add **defaultAction** in `onHangUpConfirmation`

<details>
<summary>Migrate Guide</summary>

> Modify your code based on the following guidelines to make it compatible with version 4.1.4:
>
> 4.1.3 Version Code:
>
>```dart
>/// Example code in version 4.1.3
>/// ...
> events: ZegoUIKitPrebuiltCallEvents(
>   onHangUpConfirmation: (
>     BuildContext context,
>   ) {
>     debugPrint('onHangUpConfirmation, do whatever you want');
>
>     ...show you confirm dialog 
>
>     return dialog result;
>   },
> ),
>```
>
>4.1.4 Version Code:
>
>```dart
>/// Example code in version 4.1.4
>/// ...
> events: ZegoUIKitPrebuiltCallEvents(
>   onHangUpConfirmation: (
>     ZegoUIKitCallHangUpConfirmationEvent event,
>     Future<bool> Function() defaultAction,
>   ) {
>     debugPrint('onHangUpConfirmation, do whatever you want');
>
>     /// you can call this defaultAction to return to the previous page,
>     return defaultAction.call();
>   },
> ),
>```
>
> - parameter prototype:
> ```dart
> class ZegoUIKitCallHangUpConfirmationEvent {
>   BuildContext context;
> }
> ```

</details>

## Feedback Channels

If you encounter any issues or have any questions during the migration process, please provide feedback through the following channels:

- GitHub Issues: [Link to the project's issue page](https://github.com/ZEGOCLOUD/zego_uikit_prebuilt_call_flutter/issues)
- Forum: [Link to the forum page](https://www.zegocloud.com/)

We appreciate your feedback and are here to help you successfully complete the migration process.