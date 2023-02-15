// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/events.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/calling_machine.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/pages/invitation_notify.dart';

typedef ContextQuery = BuildContext Function();

class ZegoInvitationPageManager {
  factory ZegoInvitationPageManager() => instance;
  ZegoInvitationPageManager._internal();
  static final ZegoInvitationPageManager instance =
      ZegoInvitationPageManager._internal();

  String defaultPackagePrefix = 'packages/zego_uikit_prebuilt_call/';

  late int appID;
  late String appSign;
  late String userID;
  late String userName;
  late String tokenServerUrl;
  late PrebuiltConfigQuery prebuiltConfigQuery;
  late ContextQuery
      contextQuery; // we need a context object, to push/pop page when receive invitation request

  bool notifyWhenAppRunningInBackgroundOrQuit = true;
  bool showDeclineButton = true;
  ZegoAndroidNotificationConfig? androidNotificationConfig;
  ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents;
  ZegoCallInvitationInnerText? innerText;

  ZegoRingtone callerRingtone = ZegoRingtone();
  ZegoRingtone calleeRingtone = ZegoRingtone();

  late ZegoCallingMachine callingMachine;
  bool invitationTopSheetVisibility = false;
  List<StreamSubscription<dynamic>> streamSubscriptions = [];
  bool appInBackground = false;

  ZegoCallInvitationData invitationData = ZegoCallInvitationData.empty();
  List<ZegoUIKitUser> invitingInvitees = []; //  only change by inviter

  bool get isGroupCall => invitationData.invitees.length > 1;

  /// still ring mean nobody accept this invitation
  bool get isNobodyAccepted => callerRingtone.isRingTimerRunning;

  String get channelKey =>
      androidNotificationConfig?.channelID ?? 'CallInvitation';

  String get channelName =>
      androidNotificationConfig?.channelName ?? 'Call Invitation';

  Future<void> init({
    required int appID,
    String appSign = '',
    String tokenServerUrl = '',
    required String userID,
    required String userName,
    required PrebuiltConfigQuery prebuiltConfigQuery,
    required ContextQuery contextQuery,
    required ZegoRingtoneConfig ringtoneConfig,
    bool showDeclineButton = true,
    bool notifyWhenAppRunningInBackgroundOrQuit = true,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
    ZegoCallInvitationInnerText? innerText,
  }) async {
    this.appID = appID;
    this.appSign = appSign;
    this.userID = userID;
    this.userName = userName;
    this.prebuiltConfigQuery = prebuiltConfigQuery;
    this.tokenServerUrl = tokenServerUrl;
    this.contextQuery = contextQuery;

    this.notifyWhenAppRunningInBackgroundOrQuit =
        notifyWhenAppRunningInBackgroundOrQuit;
    this.showDeclineButton = showDeclineButton;
    this.androidNotificationConfig = androidNotificationConfig;
    this.invitationEvents = invitationEvents;
    this.innerText = innerText;

    listenStream();

    callingMachine = ZegoCallingMachine();
    callingMachine.init();

    initRing(ringtoneConfig);

    if (notifyWhenAppRunningInBackgroundOrQuit) {
      initNotification();
    }

    ZegoLoggerService.logInfo(
      'init, appID:$appID, appSign:$appSign, tokenServerUrl:$tokenServerUrl, userID:$userID, userName:$userName',
      tag: 'call',
      subTag: 'page manager',
    );
  }

  void uninit() {
    removeStreamListener();
  }

  void updateInvitationConfig(
    bool showDeclineButton,
    ZegoAndroidNotificationConfig? androidNotificationConfig,
    ZegoUIKitPrebuiltCallInvitationEvents? invitationEvents,
    ZegoCallInvitationInnerText? innerText,
  ) {
    this.showDeclineButton = showDeclineButton;
    this.androidNotificationConfig = androidNotificationConfig;
    this.invitationEvents = invitationEvents;
    this.innerText = innerText;
  }

  void initNotification() {
    ZegoLoggerService.logInfo(
      'init',
      tag: 'notification',
      subTag: 'page manager',
    );

    String? soundSource;

    if (Platform.isAndroid &&
        (androidNotificationConfig?.sound?.isNotEmpty ?? false)) {
      var soundFileName = androidNotificationConfig?.sound ?? '';
      final postfixIndex = soundFileName.indexOf('.');
      if (-1 != postfixIndex) {
        soundFileName = soundFileName.substring(0, postfixIndex);
      }

      soundSource = 'resource://raw/$soundFileName';

      ZegoLoggerService.logInfo(
        "sound file, config name:${androidNotificationConfig?.sound ?? ""}, file name:$soundFileName",
        tag: 'notification',
        subTag: 'page manager',
      );
    }

    AwesomeNotifications()
        .initialize(
            // set the icon to null if you want to use the default app icon
            '', //'''resource://drawable/res_app_icon',
            [
              NotificationChannel(
                channelGroupKey: 'zego_prebuilt_call_channel_group',
                channelKey: channelKey,
                channelName: channelName,
                channelDescription: 'Notification channel for call',
                defaultColor: const Color(0xFF9D50DD),
                soundSource: soundSource,
                ledColor: Colors.white,
              )
            ],
            // Channel groups are only visual and are not required
            channelGroups: [
              NotificationChannelGroup(
                channelGroupKey: 'zego_prebuilt_call_channel_group',
                channelGroupName: 'Call Notifications Channel Group',
              )
            ],
            debug: true)
        .then((value) {
      ZegoLoggerService.logInfo(
        'init finished',
        tag: 'notification',
        subTag: 'page manager',
      );

      /// clear notifications
      AwesomeNotifications().cancelAll();

      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        ZegoLoggerService.logInfo(
          'is allowed: $isAllowed',
          tag: 'notification',
          subTag: 'page manager',
        );

        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
    });
  }

  void initRing(ZegoRingtoneConfig ringtoneConfig) {
    if (ringtoneConfig.incomingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset caller ring, source path:${ringtoneConfig.incomingCallPath}',
        tag: 'call',
        subTag: 'page manager',
      );
      callerRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.incomingCallPath!,
        isVibrate: false,
      );
    } else {
      callerRingtone.init(
        prefix: defaultPackagePrefix,
        sourcePath: 'assets/invitation/audio/outgoing.mp3',
        isVibrate: false,
      );
    }
    if (ringtoneConfig.outgoingCallPath != null) {
      ZegoLoggerService.logInfo(
        'reset callee ring, source path:${ringtoneConfig.outgoingCallPath}',
        tag: 'call',
        subTag: 'page manager',
      );
      calleeRingtone.init(
        prefix: '',
        sourcePath: ringtoneConfig.outgoingCallPath!,
        isVibrate: true,
      );
    } else {
      calleeRingtone.init(
        prefix: defaultPackagePrefix,
        sourcePath: 'assets/invitation/audio/incoming.mp3',
        isVibrate: true,
      );
    }
  }

  void listenStream() {
    // check plugin installed

    streamSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationReceivedStream()
          .listen(onInvitationReceived))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationAcceptedStream()
          .listen(onInvitationAccepted))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationTimeoutStream()
          .listen(onInvitationTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationResponseTimeoutStream()
          .listen(onInvitationResponseTimeout))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationRefusedStream()
          .listen(onInvitationRefused))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationCanceledStream()
          .listen(onInvitationCanceled));
  }

  void removeStreamListener() {
    for (final streamSubscription in streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  void onLocalSendInvitation(
    String callID,
    List<ZegoUIKitUser> invitees,
    ZegoCallType invitationType,
    String code,
    String message,
    String invitationID,
    List<String> errorInvitees,
  ) {
    ZegoLoggerService.logInfo(
      'local send invitation, call id:$callID, invitees:$invitees, '
      'type: $invitationType, code:$code, message:$message, '
      'error invitees:$errorInvitees, invitation id:$invitationID',
      tag: 'call',
      subTag: 'page manager',
    );

    if (code.isNotEmpty) {
      ZegoLoggerService.logInfo(
        'send invitation error!!! code:$code, message:$message',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    invitingInvitees = List.from(invitees);
    invitingInvitees
        .removeWhere((invitee) => errorInvitees.contains(invitee.id));

    invitationData.callID = callID;
    invitationData.invitationID = invitationID;
    invitationData.inviter = ZegoUIKit().getLocalUser();
    invitationData.invitees = List.from(invitees);
    invitationData.type = invitationType;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (invitingInvitees.isNotEmpty) {
      callerRingtone.startRing();

      if (isGroupCall) {
        /// group call, enter room directly
        callingMachine.stateOnlineAudioVideo.enter();
      } else {
        /// single call
        if (ZegoCallType.voiceCall == invitationData.type) {
          callingMachine.stateCallingWithVoice.enter();
        } else {
          if (prebuiltConfigQuery(invitationData).turnOnCameraWhenJoining) {
            ZegoUIKit.instance.turnCameraOn(true);
          }

          callingMachine.stateCallingWithVideo.enter();
        }
      }
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation(String code, String message) {
    ZegoLoggerService.logInfo(
      'local accept invitation, code:$code, message:$message',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager
        .instance.invitationEvents?.onIncomingCallAcceptButtonPressed
        ?.call();

    calleeRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onLocalRefuseInvitation(String code, String message) {
    ZegoLoggerService.logInfo(
      'local refuse invitation, code:$code, message:$message',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager
        .instance.invitationEvents?.onIncomingCallDeclineButtonPressed
        ?.call();

    restoreToIdle();
  }

  void onLocalCancelInvitation(
      String code, String message, List<String> errorInvitees) {
    ZegoLoggerService.logInfo(
      'local cancel invitation, code:$code, message:$message, error invitees, $errorInvitees',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager
        .instance.invitationEvents?.onOutgoingCallCancelButtonPressed
        ?.call();

    invitingInvitees.clear();

    restoreToIdle();
  }

  ///
  void onInvitationReceived(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final int type = params['type']!; // call type
    final String data = params['data']!; // extended field

    /// zim call id
    final invitationID = params['invitation_id'] as String? ?? '';

    ZegoLoggerService.logInfo(
      'on invitation received, data:${inviter.toString()}, $type $data',
      tag: 'call',
      subTag: 'page manager',
    );

    if (invitationData.callID.isNotEmpty ||
        CallingState.kIdle != callingMachine.getPageState()) {
      ZegoLoggerService.logInfo(
        'auto refuse this call, because is busy, '
        'is inviting: ${invitationData.callID.isNotEmpty}, '
        'current state: ${callingMachine.getPageState()}',
        tag: 'call',
        subTag: 'page manager',
      );

      ZegoUIKit()
          .getSignalingPlugin()
          .refuseInvitation(
              inviterID: inviter.id,
              data: const JsonEncoder().convert({
                'reason': 'busy',
                'invitation_id': invitationID,
              }))
          .then((result) {
        ZegoLoggerService.logInfo(
          'auto refuse result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });

      return;
    }

    final invitationInternalData = InvitationInternalData.fromJson(data);
    invitationData.customData = invitationInternalData.customData;
    invitationData.callID = invitationInternalData.callID;
    invitationData.invitationID = invitationID;
    invitationData.invitees = List.from(invitationInternalData.invitees);
    invitationData.inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name);
    invitationData.type = ZegoCallTypeExtension.mapValue[type] as ZegoCallType;

    if (appInBackground) {
      ZegoLoggerService.logInfo(
        'app in background, create notification',
        tag: 'call',
        subTag: 'page manager',
      );

      if (Platform.isAndroid) {
        calleeRingtone.startRing(); //  ios will crash
      }
      AwesomeNotifications()
          .createNotification(
              content: NotificationContent(
                  id: Random().nextInt(2147483647),
                  channelKey: channelKey,
                  title: invitationData.inviter?.name ?? 'inviter',
                  wakeUpScreen: true,
                  body: ZegoCallType.videoCall == invitationData.type
                      ? ((invitationData.invitees.length > 1
                              ? innerText?.incomingGroupVideoCallDialogMessage
                              : innerText?.incomingVideoCallDialogMessage) ??
                          'Incoming video call...')
                      : ((invitationData.invitees.length > 1
                              ? innerText?.incomingGroupVoiceCallDialogMessage
                              : innerText?.incomingVoiceCallDialogMessage) ??
                          'Incoming voice call...'),
                  actionType: ActionType.Default))
          .onError((error, stackTrace) {
        ZegoLoggerService.logError(
          error.toString(),
          tag: 'create notification',
          subTag: 'page manager',
        );
        return true;
      });
    } else {
      showNotificationOnInvitationReceived();
    }
  }

  void showNotificationOnInvitationReceived() {
    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    calleeRingtone.startRing();

    ZegoInvitationPageManager.instance.invitationEvents?.onIncomingCallReceived
        ?.call(
            invitationData.callID,
            ZegoCallUser(
              invitationData.inviter?.id ?? '',
              invitationData.inviter?.name ?? '',
            ),
            invitationData.type,
            invitationData.invitees
                .map((user) => ZegoCallUser(user.id, user.name))
                .toList());

    showInvitationTopSheet();
  }

  void onInvitationAccepted(Map params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation accepted, data:${invitee.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    final inviteeIndex =
        invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitation accepted, but invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$invitingInvitees',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    ZegoInvitationPageManager.instance.invitationEvents?.onOutgoingCallAccepted
        ?.call(invitationData.callID, ZegoCallUser(invitee.id, invitee.name));

    invitingInvitees.removeAt(inviteeIndex);

    callerRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onInvitationTimeout(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation timeout, data:${inviter.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager.instance.invitationEvents?.onIncomingCallTimeout
        ?.call(invitationData.callID, ZegoCallUser(inviter.id, inviter.name));

    invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationResponseTimeout(Map params) {
    final List<ZegoUIKitUser> invitees = params['invitees']!;
    final String data = params['data']!; // extended field

    for (final timeoutInvitee in invitees) {
      invitingInvitees
          .removeWhere((invitee) => timeoutInvitee.id == invitee.id);
    }
    ZegoLoggerService.logInfo(
      'on invitation response timeout, data: $data, '
      'invitees:${invitees.map((e) => e.toString())}, '
      'inviting invitees: ${invitingInvitees.map((e) => e.toString())}',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager.instance.invitationEvents?.onOutgoingCallTimeout
        ?.call(invitationData.callID,
            invitees.map((user) => ZegoCallUser(user.id, user.name)).toList());

    if (isGroupCall) {
      if (invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'invitation timeout, all invitee timeout',
          tag: 'call',
          subTag: 'page manager',
        );

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }
  }

  void onInvitationRefused(Map params) {
    final ZegoUIKitUser invitee = params['invitee']!;
    final String data = params['data']!; // extended field

    final inviteeIndex =
        invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      ZegoLoggerService.logInfo(
        'invitation refused, but invitee is not in list, '
        'invitee:{${invitee.id}, ${invitee.name}}, '
        'list:$invitingInvitees',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    final dict = jsonDecode(data) as Map<String, dynamic>;
    final refusedInvitationID = dict['invitation_id'] as String? ?? '';
    if (refusedInvitationID.isNotEmpty &&
        invitationData.invitationID != refusedInvitationID) {
      ZegoLoggerService.logInfo(
        'invitation refused, but invitation id is not current, '
        'current id:${invitationData.invitationID}, '
        'refused id:$refusedInvitationID',
        tag: 'call',
        subTag: 'page manager',
      );
      return;
    }

    if ('busy' == (dict['reason'] as String)) {
      ZegoInvitationPageManager
          .instance.invitationEvents?.onOutgoingCallDeclined
          ?.call(invitationData.callID, ZegoCallUser(invitee.id, invitee.name));
    } else {
      /// "decline"
      ZegoInvitationPageManager
          .instance.invitationEvents?.onOutgoingCallRejectedCauseBusy
          ?.call(invitationData.callID, ZegoCallUser(invitee.id, invitee.name));
    }

    invitingInvitees.removeAt(inviteeIndex);

    ZegoLoggerService.logInfo(
      'on invitation refused, data: $data, '
      'invitee:${invitee.toString()}, '
      'inviting invitees: ${invitingInvitees.map((e) => e.toString())}',
      tag: 'call',
      subTag: 'page manager',
    );

    if (isGroupCall) {
      if (invitingInvitees.isEmpty && isNobodyAccepted) {
        ZegoLoggerService.logInfo(
          'invitation refuse, all refuse',
          tag: 'call',
          subTag: 'page manager',
        );

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }
  }

  void onInvitationCanceled(Map params) {
    final ZegoUIKitUser inviter = params['inviter']!;
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation canceled, data:${inviter.toString()}, $data',
      tag: 'call',
      subTag: 'page manager',
    );

    ZegoInvitationPageManager.instance.invitationEvents?.onIncomingCallCanceled
        ?.call(invitationData.callID, ZegoCallUser(inviter.id, inviter.name));

    if (appInBackground) {
      /// clear notifications
      AwesomeNotifications().cancelAll();
    }

    restoreToIdle();
  }

  void onHangUp() {
    ZegoLoggerService.logInfo(
      'on hang up',
      tag: 'call',
      subTag: 'page manager',
    );

    if (isNobodyAccepted) {
      ZegoUIKit()
          .getSignalingPlugin()
          .cancelInvitation(
              invitees: invitingInvitees.map((user) => user.id).toList(),
              data: '')
          .then((result) {
        ZegoLoggerService.logInfo(
          'hang up cancel result, $result',
          tag: 'call',
          subTag: 'page manager',
        );
      });
    }

    restoreToIdle();
  }

  void onPrebuiltCallPageDispose() {
    ZegoLoggerService.logInfo(
      'prebuilt call page dispose',
      tag: 'call',
      subTag: 'page manager',
    );

    invitingInvitees.clear();

    restoreToIdle(needPop: false);
  }

  void restoreToIdle({bool needPop = true}) {
    ZegoLoggerService.logInfo(
      'invitation page service to be idle',
      tag: 'call',
      subTag: 'page manager',
    );

    callerRingtone.stopRing();
    calleeRingtone.stopRing();

    ZegoUIKit.instance.turnCameraOn(false);

    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine.machine.current?.identifier ?? CallingState.kIdle)) {
      ZegoLoggerService.logInfo(
        'restore to idle, current state:${callingMachine.machine.current?.identifier}',
        tag: 'call',
        subTag: 'page manager',
      );

      if (needPop) {
        Navigator.of(contextQuery()).pop();
      }

      callingMachine.stateIdle.enter();
    }

    invitationData = ZegoCallInvitationData.empty();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoCallType.voiceCall == invitationData.type) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      return;
    }

    invitationTopSheetVisibility = true;

    showTopModalSheet(
      contextQuery(),
      GestureDetector(
        onTap: onInvitationTopSheetEmptyClicked,
        child: ZegoCallInvitationDialog(
          invitationData: invitationData,
          avatarBuilder: prebuiltConfigQuery(invitationData).avatarBuilder,
          showDeclineButton: showDeclineButton,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      Navigator.of(contextQuery()).pop();

      invitationTopSheetVisibility = false;
    }
  }

  void didChangeAppLifecycleState(bool isAppInBackground) {
    ZegoLoggerService.logInfo(
      'didChangeAppLifecycleState, '
      'is app in background: previous:$appInBackground, current: $isAppInBackground, '
      'call machine page state:${callingMachine.getPageState()}, '
      'invitation data:${invitationData.toString()}',
      tag: 'call',
      subTag: 'page manager',
    );

    final hasReceivedInvitation = invitationData.callID.isNotEmpty &&
        invitationData.inviter?.id != ZegoUIKit().getLocalUser().id;
    if (CallingState.kIdle == callingMachine.getPageState() &&
        appInBackground &&
        !isAppInBackground &&
        hasReceivedInvitation) {
      ZegoLoggerService.logInfo(
        'had invitation in background before, show notification now',
        tag: 'call',
        subTag: 'page manager',
      );
      showNotificationOnInvitationReceived();
    }

    if (!isAppInBackground) {
      /// clear notifications
      AwesomeNotifications().cancelAll();
    }

    appInBackground = isAppInBackground;
  }
}
