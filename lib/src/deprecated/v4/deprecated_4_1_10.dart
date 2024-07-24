// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';
import 'package:zego_uikit_prebuilt_call/src/events.dart';
import 'package:zego_uikit_prebuilt_call/src/events.defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';
import 'package:zego_uikit_prebuilt_call/src/minimizing/overlay_page.dart';

const deprecatedTipsV4_1_10 = ', '
    'deprecated since 4.1.10, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4110';

@Deprecated('use ZegoCallEndReason instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitCallEndReason = ZegoCallEndReason;

@Deprecated('use ZegoCallHangUpConfirmationEvent instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitCallHangUpConfirmationEvent = ZegoCallHangUpConfirmationEvent;

@Deprecated('use ZegoCallEndEvent instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitCallEndEvent = ZegoCallEndEvent;

@Deprecated('use ZegoCallRoomEvents instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitPrebuiltCallRoomEvents = ZegoCallRoomEvents;

@Deprecated('use ZegoCallAudioVideoEvents instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitPrebuiltCallAudioVideoEvents = ZegoCallAudioVideoEvents;

@Deprecated('use ZegoCallUserEvents instead$deprecatedTipsV4_1_10')
typedef ZegoUIKitPrebuiltCallUserEvents = ZegoCallUserEvents;

@Deprecated('use ZegoCallEndCallback instead$deprecatedTipsV4_1_10')
typedef CallEndCallback = ZegoCallEndCallback;

@Deprecated(
    'use ZegoCallHangUpConfirmationCallback instead$deprecatedTipsV4_1_10')
typedef CallHangUpConfirmationCallback = ZegoCallHangUpConfirmationCallback;

@Deprecated('use ZegoCallMenuBarStyle instead$deprecatedTipsV4_1_10')
typedef ZegoMenuBarStyle = ZegoCallMenuBarStyle;

@Deprecated(
    'use ZegoCallAndroidNotificationConfig instead$deprecatedTipsV4_1_10')
typedef ZegoAndroidNotificationConfig = ZegoCallAndroidNotificationConfig;

@Deprecated('use ZegoCallIOSNotificationConfig instead$deprecatedTipsV4_1_10')
typedef ZegoIOSNotificationConfig = ZegoCallIOSNotificationConfig;

@Deprecated('use ZegoCallRingtoneConfig instead$deprecatedTipsV4_1_10')
typedef ZegoRingtoneConfig = ZegoCallRingtoneConfig;

@Deprecated('use ZegoCallPrebuiltConfigQuery instead$deprecatedTipsV4_1_10')
typedef PrebuiltConfigQuery = ZegoCallPrebuiltConfigQuery;

@Deprecated('use ZegoCallInvitationType instead$deprecatedTipsV4_1_10')
typedef ZegoInvitationType = ZegoCallInvitationType;

@Deprecated(
    'use ZegoUIKitPrebuiltCallMiniOverlayPage instead$deprecatedTipsV4_1_10')
typedef ZegoMiniOverlayPage = ZegoUIKitPrebuiltCallMiniOverlayPage;

extension ZegoCallControllerInvitationImplDeprecated
    on ZegoCallControllerInvitationImpl {
  @Deprecated(
      'use ZegoUIKitPrebuiltCallInvitationService().send instead$deprecatedTipsV4_1_10')
  Future<bool> send({
    required List<ZegoCallUser> invitees,
    required bool isVideoCall,
    String customData = '',
    String? callID,
    String? resourceID,
    String? notificationTitle,
    String? notificationMessage,
    int timeoutSeconds = 60,
  }) async {
    return ZegoUIKitPrebuiltCallInvitationService().send(
      invitees: invitees,
      isVideoCall: isVideoCall,
      customData: customData,
      callID: callID,
      resourceID: resourceID,
      notificationTitle: notificationTitle,
      notificationMessage: notificationMessage,
      timeoutSeconds: timeoutSeconds,
    );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltCallInvitationService().cancel instead$deprecatedTipsV4_1_10')
  Future<bool> cancel({
    required List<ZegoCallUser> callees,
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltCallInvitationService().cancel(
      callees: callees,
      customData: customData,
    );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltCallInvitationService().reject instead$deprecatedTipsV4_1_10')
  Future<bool> reject({
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltCallInvitationService().reject(
      customData: customData,
    );
  }

  @Deprecated(
      'use ZegoUIKitPrebuiltCallInvitationService().accept instead$deprecatedTipsV4_1_10')
  Future<bool> accept({
    String customData = '',
  }) async {
    return ZegoUIKitPrebuiltCallInvitationService().accept(
      customData: customData,
    );
  }
}
