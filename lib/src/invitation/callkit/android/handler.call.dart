// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/internal/reporter.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/cache/cache.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/android/entry_point.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/callkit_incoming.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';

/// TODO: Unpack to solve the strong dependency issue of signalin

class ZegoCallAndroidCallBackgroundMessageHandler {
  ReceivePort? backgroundPort;
  bool messageFromIsolate = false;

  void init({required ReceivePort? port, required bool messageFromIsolate}) {
    ZegoLoggerService.logInfo(
      'init, '
      'isolate port:${backgroundPort.hashCode}, '
      'message from isolate:, $messageFromIsolate, ',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    backgroundPort = port;
    this.messageFromIsolate = messageFromIsolate;
  }

  Future<void> handle(
    ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
  ) async {
    /// offline cancel invitation
    if (BackgroundMessageType.cancelInvitation == message.type) {
      await _cancelCallInvitation(message.invitationID);

      /// when offline is cancelled, you will receive two notifications: one is
      /// the online cancellation notification, and the other is the offline cancellation notification.

      /// when offline is cancelled, the isolate needs to be closed.
      /// otherwise, it will be registered and considered as active.
      closeIsolate();
    } else {
      final appSign = await getPreferenceString(
        serializationKeyAppSign,
        withDecode: true,
      );

      /// maybe installed, but if app offline after 5 minutes,
      /// it will received onBackgroundMessageReceived,
      /// so don't install if had installed(app offline, not killed)
      final signalingPluginNeedInstalled = ValueNotifier<bool>(
        null == ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling),
      );
      ZegoLoggerService.logInfo(
        'signaling plugin need installed:$signalingPluginNeedInstalled',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );
      if (signalingPluginNeedInstalled.value) {
        await _installSignalingPlugin(
          handlerInfo: message.handlerInfo,
          appSign: appSign,
        );
      }

      await _handleMessage(
        message: message,
        appSign: appSign,
        signalingPluginInstalled: signalingPluginNeedInstalled,
      );
    }
  }

  Future<void> _cancelCallInvitation(String callID) async {
    ZegoLoggerService.logInfo(
      'background offline call cancel, callID:$callID',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    await ZegoUIKitCallCache().offlineCallKit.getCallID().then((
      cacheCallID,
    ) async {
      ZegoLoggerService.logInfo(
        'background offline call cancel, cacheCallID:$cacheCallID',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );

      if (cacheCallID == callID) {
        ZegoLoggerService.logInfo(
          'background offline call cancel, callID is same as cacheCallID, clear...',
          tag: 'call-invitation',
          subTag: 'offline, call handler',
        );

        await clearAllCallKitCalls();
      }
    });
  }

  Future<void> _refuseCallInvitation({
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
  }) async {
    await ZegoUIKitCallCache().offlineCallKit.clearCacheParams();
    await ZegoUIKitCallCache().offlineCallKit.clearCallID();

    if (message.isAdvanceMode) {
      await ZegoUIKit()
          .getSignalingPlugin()
          .refuseAdvanceInvitationByInvitationID(
            invitationID: message.invitationID,
            data: ZegoCallInvitationRejectRequestProtocol(
              reason: ZegoCallInvitationProtocolKey.refuseByDecline,
            ).toJson(),
          );
    } else {
      await ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
            invitationID: message.invitationID,
            data: ZegoCallInvitationRejectRequestProtocol(
              reason: ZegoCallInvitationProtocolKey.refuseByDecline,
            ).toJson(),
          );
    }

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: message.invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionRefuse,
        ZegoUIKitReporter.eventKeyAppState:
            ZegoUIKitReporter.eventKeyAppStateBackground,
      },
    );
  }

  Future<void> _acceptCallInvitation({
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
    required String appSign,
    required String callID,
  }) async {
    ZegoLoggerService.logInfo(
      'accept, ',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    /// After setting, in the scenario of network disconnection,
    /// for calls that have been canceled/ended,
    /// zim says it will return the cancel/end event
    await ZegoUIKit()
        .getSignalingPlugin()
        .setAdvancedConfig('zim_voip_call_id', message.invitationID)
        .then((_) {
      ZegoLoggerService.logInfo(
        'set advanced config done',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );
    });

    ZegoUIKit().reporter().report(
      event: ZegoCallReporter.eventCalleeRespondInvitation,
      params: {
        ZegoUIKitSignalingReporter.eventKeyInvitationID: message.invitationID,
        ZegoCallReporter.eventKeyAction: ZegoCallReporter.eventKeyActionAccept,
        ZegoUIKitReporter.eventKeyAppState:
            ZegoUIKitReporter.eventKeyAppStateBackground,
      },
    );

    _initUIKITOnAcceptCallInvitation(
      message: message,
      appSign: appSign,
      callID: callID,
    );

    final result = message.isAdvanceMode
        ? await ZegoUIKit().getSignalingPlugin().acceptAdvanceInvitation(
              inviterID: message.inviter.id,
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
              invitationID: message.invitationID,
            )
        : await ZegoUIKit().getSignalingPlugin().acceptInvitation(
              inviterID: message.inviter.id,
              data: ZegoCallInvitationAcceptRequestProtocol().toJson(),
              targetInvitationID: message.invitationID,
            );
    ZegoLoggerService.logInfo(
      'accept done',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    await clearAllCallKitCalls();

    if (result.error?.code.isNotEmpty ?? false) {
      ZegoLoggerService.logInfo(
        'accept failed, '
        'error code:${result.error?.code}, '
        'error message:${result.error?.message}, ',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );

      await ZegoUIKitCallCache().offlineCallKit.clearCacheParams();
      await ZegoUIKitCallCache().offlineCallKit.clearCallID();

      return;
    }
  }

  Future<void> _initUIKITOnAcceptCallInvitation({
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
    required String appSign,
    required String callID,
  }) async {
    ZegoLoggerService.logInfo(
      'try init ZegoUIKit on accept',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    await ZegoUIKit()
        .init(
      appID: int.tryParse(message.handlerInfo?.appID ?? '') ?? 0,
      appSign: appSign,
      token: message.handlerInfo?.token ?? '',
    )
        .then((_) async {
      ZegoLoggerService.logInfo(
        'init ZegoUIKit done, try join room',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );

      ZegoUIKit().login(
        message.handlerInfo?.userID ?? '',
        message.handlerInfo?.userName ?? '',
      );

      await ZegoUIKit().joinRoom(callID, keepWakeScreen: false).then((_) {
        ZegoUIKit().turnMicrophoneOn(true);
      });
    });
  }

  Future<void> _handleMessage({
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
    required String appSign,
    required ValueNotifier<bool> signalingPluginInstalled,
  }) async {
    message.parseCallInvitationInfo();

    final callSendRequestProtocol =
        ZegoCallInvitationSendRequestProtocol.fromJson(message.customData);

    ZegoLoggerService.logInfo(
      'handle message, '
      'from other isolate:$messageFromIsolate, '
      'message:$message, '
      'protocol:${callSendRequestProtocol.toJson()}, ',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    final signalingSubscriptions = <StreamSubscription<dynamic>>[];
    _listenFlutterCallkitIncomingEvent(
      message: message,
      signalingPluginNeedUninstalled: signalingPluginInstalled,
      signalingSubscriptions: signalingSubscriptions,
      appSign: appSign,
      callID: callSendRequestProtocol.callID,
    );
    _listenSignalingEvents(signalingSubscriptions, message: message);

    /// cache and check when app run
    await ZegoUIKitCallCache().offlineCallKit.setCallID(
          callSendRequestProtocol.callID,
        );
    await ZegoUIKitCallCache().offlineCallKit.setCacheParams(
          ZegoCallInvitationOfflineCallKitCacheParameterProtocol(
            invitationID: message.invitationID,
            inviter: message.inviter,
            callID: callSendRequestProtocol.callID,
            callType: message.callType,
            payloadData: message.customData,
            timeoutSeconds: 60,
            accept: true,
          ),
        );

    if (messageFromIsolate) {
      /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
      await ZegoUIKit().activeAppToForeground();
      await ZegoUIKit().requestDismissKeyguard();
    } else {
      final handlerInfoJson = await getPreferenceString(
        serializationKeyHandlerInfo,
      );
      ZegoLoggerService.logInfo(
        'parsing handler info:$handlerInfoJson',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );
      final handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);

      var callChannelName =
          handlerInfo?.androidCallChannelName ?? defaultCallChannelName;
      var missedCallChannelName = handlerInfo?.androidMissedCallChannelName ??
          defaultMissedCallChannelName;

      await showCallkitIncoming(
        caller: message.inviter,
        callType: message.callType,
        callID: callSendRequestProtocol.callID,
        timeoutSeconds: callSendRequestProtocol.timeout,
        callChannelName: callChannelName,
        missedCallChannelName: missedCallChannelName,
        title: message.extras['title'] as String? ?? '',
        body: message.extras['body'] as String? ?? '',
      );
    }
  }

  void _listenFlutterCallkitIncomingEvent({
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
    required ValueNotifier<bool> signalingPluginNeedUninstalled,
    required List<StreamSubscription<dynamic>> signalingSubscriptions,
    required String appSign,
    required String callID,
  }) {
    flutterCallkitIncomingStreamSubscription =
        FlutterCallkitIncoming.onEvent.listen((
      CallEvent? event,
    ) async {
      /// check isolate
      /// After receiving the offline pop-up window,
      /// if the user directly clicks the app icon to open the app, the main
      /// isolate will register the desired isolate
      /// to the IsolateNameServer. So here we can use this to determine
      /// whether we need to ignore the old event.
      final lookup = IsolateNameServer.lookupPortByName(
        backgroundMessageIsolatePortName,
      );
      ZegoLoggerService.logInfo(
        'FlutterCallkitIncoming.onEvent, '
        'lookupPortResult(${lookup?.hashCode}), '
        'backgroundPort(${backgroundPort?.hashCode}), '
        'backgroundPort!.sendPort(${backgroundPort?.sendPort.hashCode}), ',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );
      if ((lookup != null) &&
          (lookup.hashCode != backgroundPort?.sendPort.hashCode)) {
        ZegoLoggerService.logWarn(
          'isolate: isolate changed, cause of app opened! ignore this event',
          tag: 'call-invitation',
          subTag: 'offline, call handler',
        );
        return;
      }

      if (null == event) {
        ZegoLoggerService.logError(
          'android callkit incoming event is null',
          tag: 'call-invitation',
          subTag: 'offline, call handler',
        );

        return;
      }

      ZegoLoggerService.logInfo(
        'android callkit incoming event, event:${event.event}, body:${event.body}',
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );

      switch (event.event) {
        case Event.actionCallAccept:
          // /// todo 这里逻辑也要改，prebuilt-call 里面就不用再同意了
          /// After launching the app, will check in the [ZegoUIKitPrebuiltCallInvitationService.init] method.
          /// If there is exist an OfflineCallKitParams, simulate accepting the online call and join the room directly.
          /// write accept to local, wait direct accept and enter call in ZegoUIKitPrebuiltCallInvitationService.init

          await _acceptCallInvitation(
            message: message,
            appSign: appSign,
            callID: callID,
          );

          break;
        case Event.actionCallDecline:
        case Event.actionCallTimeout:
          await _refuseCallInvitation(message: message);
          break;
        default:
          break;
      }

      switch (event.event) {
        case Event.actionCallAccept:
        case Event.actionCallDecline:
        case Event.actionCallEnded:
        case Event.actionCallTimeout:
          closeIsolate();

          for (final subscription in signalingSubscriptions) {
            subscription.cancel();
          }

          ZegoLoggerService.logInfo(
            'clear signaling plugin, '
            'signaling plugin need uninstalled:${signalingPluginNeedUninstalled.value}',
            tag: 'call-invitation',
            subTag: 'offline, call handler',
          );
          if (signalingPluginNeedUninstalled.value) {
            signalingPluginNeedUninstalled.value = false;
            await _uninstallSignalingPlugin(); // todo judge app is running or not?
          }
          break;
        default:
          break;
      }
    });
  }

  void _listenSignalingEvents(
    List<StreamSubscription<dynamic>> signalingSubscriptions, {
    required ZegoCallAndroidCallBackgroundMessageHandlerMessage message,
  }) {
    if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) == null) {
      ZegoLoggerService.logInfo(
        "signaling plugin is null, couldn't listen",
        tag: 'call-invitation',
        subTag: 'offline, call handler',
      );

      return;
    }

    ZegoUIKit().getSignalingPlugin().setThroughMessageHandler(
          _onThroughMessage,
        );

    if (message.isAdvanceMode) {
      signalingSubscriptions
        ..add(
          ZegoUIKit()
              .getSignalingPlugin()
              .getAdvanceInvitationCanceledStream()
              .listen(_onInvitationCanceled),
        )
        ..add(
          ZegoUIKit()
              .getSignalingPlugin()
              .getAdvanceInvitationTimeoutStream()
              .listen(_onInvitationTimeout),
        );
    } else {
      signalingSubscriptions
        ..add(
          ZegoUIKit().getSignalingPlugin().getInvitationCanceledStream().listen(
                _onInvitationCanceled,
              ),
        )
        ..add(
          ZegoUIKit().getSignalingPlugin().getInvitationTimeoutStream().listen(
                _onInvitationTimeout,
              ),
        );
    }
  }

  void _onInvitationTimeout(Map<String, dynamic> params) async {
    ZegoLoggerService.logInfo(
      'params:$params, ',
      tag: 'call-invitation',
      subTag: 'call handler, on invitation timeout',
    );

    clearAllCallKitCalls();

    await _addMissedCallNotification(params);
  }

  Future<void> _addMissedCallNotification(Map<String, dynamic> params) async {
    final handlerInfoJson = await getPreferenceString(
      serializationKeyHandlerInfo,
    );
    ZegoLoggerService.logInfo(
      'parsing handler info:$handlerInfoJson',
      tag: 'call-invitation',
      subTag: 'call handler, missed call',
    );
    final handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);
    ZegoLoggerService.logInfo(
      'parsing handler object:$handlerInfo',
      tag: 'call-invitation',
      subTag: 'call handler, missed call',
    );

    if (!(handlerInfo?.androidMissedCallEnabled ?? true)) {
      ZegoLoggerService.logInfo(
        'not enabled',
        tag: 'call-invitation',
        subTag: 'call handler, missed call',
      );

      return;
    }

    final String data = params['data']!; // extended field
    final callType =
        ZegoCallTypeExtension.mapValue[params['type'] as int? ?? 0] ??
            ZegoCallInvitationType.voiceCall;
    final invitationID = params['invitation_id'] as String? ?? '';

    final sendRequestProtocol = ZegoCallInvitationSendRequestProtocol.fromJson(
      data,
    );

    var inviter = ZegoUIKitUser.empty();
    if (params['inviter'] is ZegoUIKitUser) {
      inviter = params['inviter']!;
    } else if (params['inviter'] is Map<String, dynamic>) {
      inviter = ZegoUIKitUser.fromJson(
        params['inviter'] as Map<String, dynamic>,
      );
    }
    inviter.name = sendRequestProtocol.inviterName;

    var channelID =
        handlerInfo?.androidMissedCallChannelID ?? defaultMissedCallChannelKey;
    if (channelID.isEmpty) {
      channelID = defaultMissedCallChannelKey;
    }

    final groupMissedCallContent = ZegoCallInvitationType.videoCall == callType
        ? handlerInfo?.missedGroupVideoCallNotificationContent ??
            'Group Video Call'
        : handlerInfo?.missedGroupAudioCallNotificationContent ??
            'Group Audio Call';
    final oneOnOneMissedCallContent =
        ZegoCallInvitationType.videoCall == callType
            ? handlerInfo?.missedVideoCallNotificationContent ?? 'Video Call'
            : handlerInfo?.missedAudioCallNotificationContent ?? 'Audio Call';

    final notificationID = Random().nextInt(2147483647);
    ZegoCallInvitationData callInvitationData = ZegoCallInvitationData(
      callID: sendRequestProtocol.callID,
      invitationID: invitationID,
      type: callType,
      invitees: sendRequestProtocol.invitees,
      inviter: inviter,
      customData: sendRequestProtocol.customData,
      timeoutSeconds: sendRequestProtocol.timeout,
    );
    await ZegoUIKitCallCache().missedCall.addNotification(
          notificationID,
          callInvitationData,
        );

    await ZegoCallPluginPlatform.instance.showNormalNotification(
      ZegoCallNormalNotificationConfig(
        id: notificationID,
        channelID: channelID,
        title: handlerInfo?.missedCallNotificationTitle ?? 'Missed Call',
        content:
            '${sendRequestProtocol.inviterName} ${sendRequestProtocol.invitees.length > 1 ? groupMissedCallContent : oneOnOneMissedCallContent}',
        vibrate: handlerInfo?.androidMissedCallVibrate ?? false,
        iconSource: ZegoCallInvitationNotificationManager.getIconSource(
          handlerInfo?.androidMissedCallIcon ?? '',
        ),
        soundSource: ZegoCallInvitationNotificationManager.getSoundSource(
          handlerInfo?.androidMissedCallSound ?? '',
        ),
        clickCallback: (int notificationID) async {
          ZegoLoggerService.logInfo(
            'notification clicked, notificationID:$notificationID',
            tag: 'call-invitation',
            subTag: 'call handler, missed call',
          );

          await ZegoUIKitCallCache()
              .missedCall
              .setNotificationID(notificationID)
              .then((_) async {
            await ZegoUIKit().activeAppToForeground();
            await ZegoUIKit().requestDismissKeyguard();
          });
        },
      ),
    );
  }

  Future<void> _onInvitationCanceled(Map<String, dynamic> params) async {
    var inviter = ZegoUIKitUser.empty();
    if (params['inviter'] is ZegoUIKitUser) {
      inviter = params['inviter']!;
    } else if (params['inviter'] is Map<String, dynamic>) {
      inviter = ZegoUIKitUser.fromJson(
        params['inviter'] as Map<String, dynamic>,
      );
    }
    final String data = params['data']!; // extended field

    ZegoLoggerService.logInfo(
      'on invitation canceled, inviter:$inviter, data:$data',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    final dataMap = jsonDecode(data) as Map<String, dynamic>;
    final callID =
        dataMap[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
    await _cancelCallInvitation(callID);
  }

  Future<void> _installSignalingPlugin({
    required HandlerPrivateInfo? handlerInfo,
    required String appSign,
  }) async {
    if (null == handlerInfo) {
      removePreferenceValue(serializationKeyHandlerInfo);

      ZegoLoggerService.logInfo(
        'but handler info parse failed',
        tag: 'call-invitation',
        subTag: 'call handler, install signaling plugin',
      );
      return;
    }

    ZegoLoggerService.logInfo(
      'handler info:$handlerInfo',
      tag: 'call-invitation',
      subTag: 'call handler, install signaling plugin',
    );

    /// TODO: Unpack to solve the strong dependency issue of signaling
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);
    // ZegoUIKit().installPlugins(
    //   /// This is incorrect because ZegoUIKitPrebuiltCallInvitationService will not be initialized when offline
    //   ///, so the ZegoUIKitSignalingPlugin() object was not correctly included, resulting in the signaling plugin not being successfully installed
    //   ZegoUIKitPrebuiltCallInvitationService()
    //       .private
    //       .plugins
    //       .where((e) => e.getPluginType() == ZegoUIKitPluginType.signaling)
    //       .toList(),
    // );

    ZegoLoggerService.logInfo(
      'try init',
      tag: 'call-invitation',
      subTag: 'call handler, install signaling plugin',
    );
    await ZegoUIKit().getSignalingPlugin().init(
          int.tryParse(handlerInfo.appID) ?? 0,
          appSign: appSign,
        );

    ZegoLoggerService.logInfo(
      'login signaling plugin',
      tag: 'call-invitation',
      subTag: 'call handler, install signaling plugin',
    );
    await ZegoUIKit().getSignalingPlugin().login(
          id: handlerInfo.userID,
          name: handlerInfo.userName,
          token: handlerInfo.token,
        );

    ZegoLoggerService.logInfo(
      'enable notify',
      tag: 'call-invitation',
      subTag: 'call handler, install signaling plugin',
    );
    await ZegoUIKit()
        .getSignalingPlugin()
        .enableNotifyWhenAppRunningInBackgroundOrQuit(
          true,
          isIOSSandboxEnvironment: handlerInfo.isIOSSandboxEnvironment,
          enableIOSVoIP: handlerInfo.enableIOSVoIP,
          certificateIndex: handlerInfo.certificateIndex,
          appName: handlerInfo.appName,
          androidChannelID: handlerInfo.androidCallChannelID,
          androidChannelName: handlerInfo.androidCallChannelName,

          /// not need to get abs uri like ZegoNotificationManager.getSoundSource(handlerInfo.androidCallSound),
          /// zim will add prefix like ${android.resource://" + application.getPackageName() + androidSound}
          androidSound: handlerInfo.androidCallSound.isEmpty
              ? ''
              : '/raw/${handlerInfo.androidCallSound}',
        );
  }

  Future<void> _uninstallSignalingPlugin() async {
    ZegoLoggerService.logInfo(
      'uninstall signaling plugin',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );

    /// force kill the signaling SDK, otherwise it will keep running in the
    /// background.
    /// Otherwise, sdk will keep receiving online calls even in offline status.
    await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: true);

    /// TODO: Unpack to solve the strong dependency issue of signaling
    ZegoUIKit().uninstallPlugins([ZegoUIKitSignalingPlugin()]);
    // ZegoUIKit().uninstallPlugins(
    //   ZegoUIKitPrebuiltCallInvitationService()
    //       .private
    //       .plugins
    //       .where((e) => e.getPluginType() == ZegoUIKitPluginType.signaling)
    //       .toList(),
    // );
  }

  void _onThroughMessage(ZegoSignalingPluginMessage message) {
    ZegoLoggerService.logInfo(
      'on through message: '
      'title:${message.title}, '
      'content:${message.content}, '
      'extras:${message.extras}',
      tag: 'call-invitation',
      subTag: 'offline, call handler',
    );
    // title:, content:, extras:{payload: {"call_id":"call_073493_1694085825032","operation_type":"cancel_invitation"}, body: , title: , call_id: 3789618859125027445}

    final payload = message.extras['payload'] as String? ?? '';
    final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
    final operationType =
        payloadMap[ZegoCallInvitationProtocolKey.operationType] as String? ??
            '';

    /// cancel invitation
    if (BackgroundMessageType.cancelInvitation.text == operationType) {
      final callID =
          payloadMap[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
      _cancelCallInvitation(callID);
    }
  }

  void closeIsolate() {
    ZegoLoggerService.logInfo(
      'close'
      'port:${backgroundPort?.hashCode}',
      tag: 'call-invitation',
      subTag: 'call handler, isolate',
    );

    backgroundPort?.close();
    backgroundPort = null;

    IsolateNameServer.removePortNameMapping(backgroundMessageIsolatePortName);
  }
}
