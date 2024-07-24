// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_callkit_incoming_yoer/entities/call_event.dart';
import 'package:flutter_callkit_incoming_yoer/flutter_callkit_incoming.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zpns/zego_zpns.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/channel/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/channel/platform_interface.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/isolate_name_server_guard.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/notification/notification_manager.dart';

const backgroundMessageIsolatePortName = 'bg_msg_isolate_port';
const backgroundMessageIsolateCloseCommand = 'close';
StreamSubscription<CallEvent?>? flutterCallkitIncomingStreamSubscription;

/// @nodoc
///
/// [Android] Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(ZPNsMessage message) async {
  ZegoLoggerService.logInfo(
    'on message received: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}, ',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  final isZegoMessage = message.extras.keys.contains('zego');
  if (!isZegoMessage) {
    ZegoLoggerService.logInfo(
      'is not zego protocol, drop it',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    return;
  }

  final registeredIsolatePort =
      IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
  final isAppRunning = null != registeredIsolatePort;
  ZegoLoggerService.logInfo(
    'isolate: ${registeredIsolatePort?.hashCode}, isAppRunning:$isAppRunning',
    tag: 'call-invitation',
    subTag: 'offline, isolate',
  );
  if (isAppRunning) {
    // await ZegoCallPluginPlatform.instance.activeAppToForeground();

    /// after app being screen-locked for more than 10 minutes, the app was not
    /// killed(suspended) but the zpns login timed out, so that's why receive
    /// offline call when app was alive.
    ///
    /// At this time, because the fcm push will make the Dart open another isolate (thread) to process,
    /// it will cause the problem of double opening of the app.
    ///
    /// So, send this offline call to [ZegoUIKitPrebuiltCallInvitationService] to handle.
    ZegoLoggerService.logInfo(
      'isolate: app has another isolate(${registeredIsolatePort.hashCode}), '
      'send command to deal with this background message',
      tag: 'call-invitation',
      subTag: 'offline, isolate',
    );
    registeredIsolatePort.send(jsonEncode({
      'title': message.title,
      'extras': message.extras,
    }));
    return;
  }

  final backgroundPort = ReceivePort();
  IsolateNameServer.registerPortWithName(
    backgroundPort.sendPort,
    backgroundMessageIsolatePortName,
  );

  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(ZegoCallIsolateNameServerGuard(
    backgroundPort: backgroundPort,
    portName: backgroundMessageIsolatePortName,
  ));

  ZegoLoggerService.logInfo(
    'isolate: backgroundPort(${backgroundPort.hashCode}),registerPortWithName backgroundPort.sendPort(${backgroundPort.sendPort.hashCode})'
    'message:$message',
    tag: 'call-invitation',
    subTag: 'offline, isolate',
  );

  backgroundPort.listen((dynamic message) async {
    ZegoLoggerService.logInfo(
      'isolate: current port(${backgroundPort.hashCode}) receive, backgroundPort.sendPort(${backgroundPort.sendPort.hashCode})'
      'message:$message',
      tag: 'call-invitation',
      subTag: 'offline, isolate',
    );

    /// this will fix the issue that when offline call dialog popup, user click app icon to open app,
    if (message is String && message == backgroundMessageIsolateCloseCommand) {
      ZegoLoggerService.logInfo(
        'isolate: close port command received, also cancel the flutterCallkitIncomingStreamSubscription(${flutterCallkitIncomingStreamSubscription?.hashCode})',
        tag: 'call-invitation',
        subTag: 'offline, isolate',
      );
      flutterCallkitIncomingStreamSubscription?.cancel();
      flutterCallkitIncomingStreamSubscription = null;
      backgroundPort.close();
      return;
    }

    final messageMap = jsonDecode(message) as Map<String, dynamic>;

    final messageTitle = messageMap['title'] as String? ?? '';
    final messageExtras = messageMap['extras'] as Map<String, Object?>? ?? {};

    _onBackgroundMessageReceived(
      messageTitle: messageTitle,
      messageExtras: messageExtras,
      fromOtherIsolate: true,
      backgroundPort: backgroundPort,
    );
  });
  ZegoLoggerService.logInfo(
    'isolate: register and listen port(${backgroundPort.hashCode}), '
    'send command to deal with this background message',
    tag: 'call-invitation',
    subTag: 'offline, isolate',
  );

  _onBackgroundMessageReceived(
    messageTitle: message.title,
    messageExtras: message.extras,
    fromOtherIsolate: false,
    backgroundPort: backgroundPort,
  );
}

Future<void> _onBackgroundMessageReceived({
  required String messageTitle,
  required Map<String, Object?> messageExtras,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
}) async {
  final payload = messageExtras['payload'] as String? ?? '';
  var payloadMap = <String, dynamic>{};
  try {
    payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};
  } catch (e) {
    ZegoLoggerService.logError(
      'payload， json decode data exception:$e',
      tag: 'call-invitation',
      subTag: 'offline',
    );
  }

  final operationType = BackgroundMessageTypeExtension.fromText(
      payloadMap[ZegoCallInvitationProtocolKey.operationType] as String? ?? '');

  final handlerInfoJson =
      await getPreferenceString(serializationKeyHandlerInfo);
  ZegoLoggerService.logInfo(
    'parsing handler info:$handlerInfoJson',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  final handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);
  ZegoLoggerService.logInfo(
    'parsing handler object:$handlerInfo',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  if (BackgroundMessageType.textMessage == operationType ||
      BackgroundMessageType.mediaMessage == operationType) {
    _onBackgroundIMMessageReceived(
      messageTitle: messageTitle,
      messageExtras: messageExtras,
      fromOtherIsolate: fromOtherIsolate,
      backgroundPort: backgroundPort,
      payloadMap: payloadMap,
      handlerInfo: handlerInfo,
    );

    return;
  }

  /// operation type is empty, is send/cancel request
  _onBackgroundCallMessageReceived(
    messageTitle: messageTitle,
    messageExtras: messageExtras,
    fromOtherIsolate: fromOtherIsolate,
    backgroundPort: backgroundPort,
    payloadMap: payloadMap,
    handlerInfo: handlerInfo,
  );
}

// title:zimkit title, content:,
// extras:{zego: {"version":1,"zpns_request_id":"6858191685210283321"},
// body: zimkit content,
// title: zimkit title,
// payload: zimkit payload}
Future<void> _onBackgroundIMMessageReceived({
  required String messageTitle,
  required Map<String, Object?> messageExtras,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
  required Map<String, dynamic> payloadMap,
  required HandlerPrivateInfo? handlerInfo,
}) async {
  final body = messageExtras['body'] as String? ?? '';

  final conversationID = payloadMap['id'] as String? ?? '';
  final conversationTypeIndex = payloadMap['type'] as int? ?? -1;

  final senderInfo = payloadMap['sender'] as Map<String, dynamic>? ?? {};
  // final senderID = senderInfo['id'] as String? ?? '';
  final senderName = senderInfo['name'] as String? ?? '';

  ZegoLoggerService.logInfo(
    'im message received, '
    'body:$body, conversationID:$conversationID, '
    'conversationTypeIndex:$conversationTypeIndex',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  var channelID =
      handlerInfo?.androidMessageChannelID ?? defaultMessageChannelID;
  if (channelID.isEmpty) {
    channelID = defaultMessageChannelID;
  }
  await ZegoCallPluginPlatform.instance.addLocalIMNotification(
    ZegoSignalingPluginLocalIMNotificationConfig(
      id: Random().nextInt(2147483647),
      channelID: channelID,
      title: senderName,
      content: body,
      vibrate: handlerInfo?.androidMessageVibrate ?? false,
      iconSource: ZegoCallInvitationNotificationManager.getIconSource(
        handlerInfo?.androidMessageIcon ?? '',
      ),
      soundSource: ZegoCallInvitationNotificationManager.getSoundSource(
        handlerInfo?.androidMessageSound ?? '',
      ),
      clickCallback: () async {
        await ZegoCallPluginPlatform.instance.activeAppToForeground();
        await ZegoCallPluginPlatform.instance.requestDismissKeyguard();
      },
    ),
  );

  ZegoLoggerService.logInfo(
    'isolate: clear IsolateNameServer, port:${backgroundPort.hashCode}',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  backgroundPort.close();
  IsolateNameServer.removePortNameMapping(
    backgroundMessageIsolatePortName,
  );
}

Future<void> _onBackgroundCallMessageReceived({
  required String messageTitle,
  required Map<String, Object?> messageExtras,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
  required Map<String, dynamic> payloadMap,
  required HandlerPrivateInfo? handlerInfo,
}) async {
  final operationType = BackgroundMessageTypeExtension.fromText(
      payloadMap[ZegoCallInvitationProtocolKey.operationType] as String? ?? '');

  ZegoLoggerService.logInfo(
    'call message received, '
    'operationType:${operationType.text}, ',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  /// offline cancel invitation
  if (BackgroundMessageType.cancelInvitation == operationType) {
    /// offline call cancel data format:
    ///
    /// zego_uikit_prebuilt_call/lib/src/invitation/pages/page_manager.dart#cancelGroupCallInvitation
    ///
    /// title:,
    /// content:,
    /// extras:
    /// {
    ///   "body": ”“,
    ///   "title": ”“,
    ///   "payload": {
    ///     "call_id": "call_073493_1693908313900",
    ///     "operation_type": "cancel_invitation"
    ///   },
    ///   "call_id": 4172113646365410763
    /// }
    final callID =
        payloadMap[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
    await _onBackgroundInvitationCanceled(callID);

    /// when offline is cancelled, you will receive two notifications: one is
    /// the online cancellation notification, and the other is the offline cancellation notification.

    /// when offline is cancelled, the isolate needs to be closed.
    /// otherwise, it will be registered and considered as active.
    ZegoLoggerService.logInfo(
      'isolate: clear IsolateNameServer, port:${backgroundPort.hashCode}',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    backgroundPort.close();
    IsolateNameServer.removePortNameMapping(
      backgroundMessageIsolatePortName,
    );
  } else {
    /// maybe installed, but if app offline after 5 minutes,
    /// it will received onBackgroundMessageReceived,
    /// so don't install if had installed(app offline, not killed)
    final signalingPluginNeedInstalled = ValueNotifier<bool>(
      null == ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling),
    );
    ZegoLoggerService.logInfo(
      'signaling plugin need installed:$signalingPluginNeedInstalled',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    if (signalingPluginNeedInstalled.value) {
      await _installSignalingPlugin(
        handlerInfo: handlerInfo,
      );
    }

    await _onBackgroundOfflineCall(
      messageExtras: messageExtras,
      payloadMap: payloadMap,
      signalingPluginInstalled: signalingPluginNeedInstalled,
      fromOtherIsolate: fromOtherIsolate,
      backgroundPort: backgroundPort,
      handlerInfo: handlerInfo,
    );
  }
}

Future<void> _onBackgroundInvitationCanceled(String callID) async {
  ZegoLoggerService.logInfo(
    'background offline call cancel, callID:$callID',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  await getOfflineCallKitCallID().then((cacheCallID) async {
    ZegoLoggerService.logInfo(
      'background offline call cancel, cacheCallID:$cacheCallID',
      tag: 'call-invitation',
      subTag: 'offline',
    );

    if (cacheCallID == callID) {
      ZegoLoggerService.logInfo(
        'background offline call cancel, callID is same as cacheCallID, clear...',
        tag: 'call-invitation',
        subTag: 'offline',
      );

      await clearAllCallKitCalls();
    }
  });
}

Future<void> _onBackgroundOfflineCall({
  required Map<String, Object?> messageExtras,
  required Map<String, dynamic> payloadMap,
  required ValueNotifier<bool> signalingPluginInstalled,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
  required HandlerPrivateInfo? handlerInfo,
}) async {
  /// offline call data format:
  ///
  /// payload:zego_uikit/lib/src/plugins/signaling/impl/service/invitation_service.dart#sendInvitation
  /// payload.data:zego_uikit_prebuilt_call/lib/src/invitation/internal/protocols.dart#InvitationSendRequestData.toJson
  ///
  /// cancel:
  /// zego_uikit_prebuilt_call/lib/src/invitation/pages/page_manager.dart#cancelGroupCallInvitation
  ///
  /// title:user_378508
  /// content:
  /// extras:
  /// {
  /// 	body: Incoming video call...,
  /// 	title: user_378508,
  /// 	payload: {
  /// 		"inviter_name": "user_378508",
  /// 		"type": 1,
  /// 		"data": {
  ///             	"call_id": "call_378508_1681123982106",
  ///             	"invitees": [{
  ///             		"user_id": "553625",
  ///             		"user_name": "user_553625"
  ///             	}],
  ///             	"custom_data": ""
  ///             }
  /// 	}
  /// }

  ZegoLoggerService.logInfo(
    'background offline call, '
    'from other isolate:$fromOtherIsolate, '
    'messageExtras:$messageExtras, '
    'payloadMap:$payloadMap, ',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  // messageExtras:{
  // zego: {"call_id":"8827488227325211473","version":1,"zpns_request_id":"8252960554030856365"},
  // body: Incoming voice call...,
  // title: user_870125,
  // payload: {"inviter_id":"870125","inviter_name":"user_870125","type":0,"data":"{\"call_id\":\"call_870125_1715156717811\",\"invitees\":[{\"user_id\":\"946042\",\"user_name\":\"user_946042\"}],\"timeout\":60,\"timestamp\":1715156716097,\"custom_data\":\"\"}"}, call_id: 8827488227325211473},
  // payloadMap:{inviter_id: 870125, inviter_name: user_870125, type: 0, data: {"call_id":"call_870125_1715156717811","invitees":[{"user_id":"946042","user_name":"user_946042"}],"timeout":60,""custom_data":""}}, }  {08/05/2024 16:25:36}  {INFO}

  final invitationID =
      messageExtras[ZegoCallInvitationProtocolKey.callID] as String? ?? '';

  ZegoLoggerService.logInfo(
    'background offline call, '
    'invitationID:$invitationID, ',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  var inviter = ZegoUIKitUser.empty();
  String payloadCustomData = '';
  int invitationType = -1;
  if (handlerInfo?.canInvitingInCalling ?? true) {
    final sendProtocol =
        ZegoUIKitAdvanceInvitationSendProtocol.fromJson(payloadMap);
    inviter = sendProtocol.inviter;
    payloadCustomData = sendProtocol.customData;
    invitationType = sendProtocol.type;
  } else {
    final sendProtocol = ZegoUIKitInvitationSendProtocol.fromJson(payloadMap);
    inviter = sendProtocol.inviter;
    payloadCustomData = sendProtocol.customData;
    invitationType = sendProtocol.type;
  }

  ///
  final callType = ZegoCallTypeExtension.mapValue[invitationType] ??
      ZegoCallInvitationType.voiceCall;
  final callSendRequestProtocol =
      ZegoCallInvitationSendRequestProtocol.fromJson(payloadCustomData);

  final signalingSubscriptions = <StreamSubscription<dynamic>>[];
  _listenFlutterCallkitIncomingEvent(
    invitationID: invitationID,
    inviter: inviter,
    callType: callType,
    payloadData: payloadCustomData,
    signalingPluginNeedUninstalled: signalingPluginInstalled,
    signalingSubscriptions: signalingSubscriptions,
    backgroundPort: backgroundPort,
    handlerInfo: handlerInfo,
  );
  _listenSignalingEvents(
    signalingSubscriptions,
    handlerInfo: handlerInfo,
  );

  /// cache and do when app run
  setOfflineCallKitCallID(callSendRequestProtocol.callID);
  await setOfflineCallKitCacheParams(
    ZegoCallInvitationOfflineCallKitCacheParameterProtocol(
      invitationID: invitationID,
      inviter: inviter,
      callType: callType,
      payloadData: payloadCustomData,
      accept: true,
    ),
  );

  if (fromOtherIsolate) {
    /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
    await ZegoCallPluginPlatform.instance.activeAppToForeground();
    await ZegoCallPluginPlatform.instance.requestDismissKeyguard();
  } else {
    await showCallkitIncoming(
      caller: inviter,
      callType: callType,
      sendRequestProtocol: callSendRequestProtocol,
      title: messageExtras['title'] as String? ?? '',
      body: messageExtras['body'] as String? ?? '',
    );
  }
}

void _listenFlutterCallkitIncomingEvent({
  required String invitationID,
  required ZegoUIKitUser inviter,
  required ZegoCallInvitationType callType,
  required String payloadData,
  required ValueNotifier<bool> signalingPluginNeedUninstalled,
  required List<StreamSubscription<dynamic>> signalingSubscriptions,
  required ReceivePort backgroundPort,
  required HandlerPrivateInfo? handlerInfo,
}) {
  flutterCallkitIncomingStreamSubscription =
      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    // check isolate
    // After receiving the offline pop-up window,
    // if the user directly clicks the app icon to open the app, the main isolate will register the desired isolate
    // to the IsolateNameServer. So here we can use this to determine whether we need to ignore the old event.
    final lookup =
        IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
    ZegoLoggerService.logInfo(
      'isolate: FlutterCallkitIncoming.onEvent, lookupPortResult(${lookup?.hashCode}),backgroundPort(${backgroundPort.hashCode}),backgroundPort!.sendPort(${backgroundPort.sendPort.hashCode})',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    if ((lookup != null) &&
        (lookup.hashCode != backgroundPort.sendPort.hashCode)) {
      ZegoLoggerService.logWarn(
        'isolate: isolate changed, cause of app opened! ignore this event',
        tag: 'call-invitation',
        subTag: 'offline',
      );
      return;
    }

    if (null == event) {
      ZegoLoggerService.logError(
        'android callkit incoming event is null',
        tag: 'call-invitation',
        subTag: 'offline',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'android callkit incoming event, event:${event.event}, body:${event.body}',
      tag: 'call-invitation',
      subTag: 'offline',
    );

    switch (event.event) {
      case Event.actionCallAccept:

        /// After launching the app, will check in the [ZegoUIKitPrebuiltCallInvitationService.init] method.
        /// If there is exist an OfflineCallKitParams, simulate accepting the online call and join the room directly.

        ZegoLoggerService.logInfo(
          'accept, write accept to local, wait direct accept and enter call in ZegoUIKitPrebuiltCallInvitationService.init',
          tag: 'call-invitation',
          subTag: 'offline',
        );

        break;
      case Event.actionCallDecline:
        await clearOfflineCallKitCacheParams();
        await clearOfflineCallKitCallID();

        if (handlerInfo?.canInvitingInCalling ?? true) {
          await ZegoUIKit()
              .getSignalingPlugin()
              .refuseAdvanceInvitationByInvitationID(
                invitationID: invitationID,
                data: ZegoCallInvitationRejectRequestProtocol(
                  reason: ZegoCallInvitationProtocolKey.refuseByDecline,
                ).toJson(),
              );
        } else {
          await ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
                invitationID: invitationID,
                data: ZegoCallInvitationRejectRequestProtocol(
                  reason: ZegoCallInvitationProtocolKey.refuseByDecline,
                ).toJson(),
              );
        }
        break;
      case Event.actionCallTimeout:
        await clearOfflineCallKitCacheParams();
        await clearOfflineCallKitCallID();
        break;
      default:
        break;
    }

    switch (event.event) {
      case Event.actionCallAccept:
      case Event.actionCallDecline:
      case Event.actionCallEnded:
      case Event.actionCallTimeout:
        ZegoLoggerService.logInfo(
          'isolate: clear IsolateNameServer, port:${backgroundPort.hashCode}',
          tag: 'call-invitation',
          subTag: 'offline',
        );
        backgroundPort.close();
        IsolateNameServer.removePortNameMapping(
          backgroundMessageIsolatePortName,
        );

        for (final subscription in signalingSubscriptions) {
          subscription.cancel();
        }

        ZegoLoggerService.logInfo(
          'clear signaling plugin, '
          'signaling plugin need uninstalled:${signalingPluginNeedUninstalled.value}',
          tag: 'call-invitation',
          subTag: 'offline',
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
  required HandlerPrivateInfo? handlerInfo,
}) {
  if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) == null) {
    ZegoLoggerService.logInfo(
      "signaling plugin is null, couldn't listen",
      tag: 'call-invitation',
      subTag: 'offline',
    );

    return;
  }

  ZegoUIKit().getSignalingPlugin().setThroughMessageHandler(_onThroughMessage);

  if (handlerInfo?.canInvitingInCalling ?? true) {
    signalingSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationCanceledStream()
          .listen(_onInvitationCanceled))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getAdvanceInvitationTimeoutStream()
          .listen(_onInvitationTimeout));
  } else {
    signalingSubscriptions
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationCanceledStream()
          .listen(_onInvitationCanceled))
      ..add(ZegoUIKit()
          .getSignalingPlugin()
          .getInvitationTimeoutStream()
          .listen(_onInvitationTimeout));
  }
}

void _onInvitationTimeout(Map<String, dynamic> params) {
  final ZegoUIKitUser inviter = params['inviter']!;
  final String data = params['data']!; // extended field

  ZegoLoggerService.logInfo(
    'on invitation timeout, inviter:$inviter, data:$data',
    tag: 'call-invitation',
    subTag: 'offline',
  );
}

Future<void> _onInvitationCanceled(Map<String, dynamic> params) async {
  final ZegoUIKitUser inviter = params['inviter']!;
  final String data = params['data']!; // extended field

  ZegoLoggerService.logInfo(
    'on invitation canceled, inviter:$inviter, data:$data',
    tag: 'call-invitation',
    subTag: 'offline',
  );

  final dataMap = jsonDecode(data) as Map<String, dynamic>;
  final callID = dataMap[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
  await _onBackgroundInvitationCanceled(callID);
}

Future<void> _installSignalingPlugin({
  required HandlerPrivateInfo? handlerInfo,
}) async {
  final appSign = await getPreferenceString(
    serializationKeyAppSign,
    withDecode: true,
  );
  if (null == handlerInfo) {
    removePreferenceValue(serializationKeyHandlerInfo);

    ZegoLoggerService.logInfo(
      'install signaling plugin, but handler info parse failed',
      tag: 'call-invitation',
      subTag: 'offline',
    );
    return;
  }

  ZegoLoggerService.logInfo(
    'install signaling plugin, handler info:$handlerInfo',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

  ZegoLoggerService.logInfo(
    'init signaling plugin',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  await ZegoUIKit().getSignalingPlugin().init(
        int.tryParse(handlerInfo.appID) ?? 0,
        appSign: appSign,
      );

  ZegoLoggerService.logInfo(
    'login signaling plugin',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  await ZegoUIKit().getSignalingPlugin().login(
        id: handlerInfo.userID,
        name: handlerInfo.userName,
        token: handlerInfo.token,
      );

  ZegoLoggerService.logInfo(
    'enable notify',
    tag: 'call-invitation',
    subTag: 'offline',
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
    subTag: 'offline',
  );

  /// force kill the signaling SDK, otherwise it will keep running in the
  /// background.
  /// Otherwise, sdk will keep receiving online calls even in offline status.
  await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: true);

  ZegoUIKit().uninstallPlugins([ZegoUIKitSignalingPlugin()]);
}

void _onThroughMessage(
  ZPNsMessage message,
) {
  ZegoLoggerService.logInfo(
    'on through message: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}',
    tag: 'call-invitation',
    subTag: 'offline',
  );
  // title:, content:, extras:{payload: {"call_id":"call_073493_1694085825032","operation_type":"cancel_invitation"}, body: , title: , call_id: 3789618859125027445}

  final payload = message.extras['payload'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
  final operationType =
      payloadMap[ZegoCallInvitationProtocolKey.operationType] as String? ?? '';

  /// cancel invitation
  if (BackgroundMessageType.cancelInvitation.text == operationType) {
    final callID =
        payloadMap[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
    _onBackgroundInvitationCanceled(callID);
  }
}

class HandlerPrivateInfo {
  String appID;
  String token;
  String userID;
  String userName;
  bool? isIOSSandboxEnvironment;
  bool enableIOSVoIP;
  int certificateIndex;
  String appName;
  bool canInvitingInCalling;

  /// call
  String androidCallChannelID;
  String androidCallChannelName;
  String androidCallIcon;
  String androidCallSound;
  bool androidCallVibrate;

  /// message
  String androidMessageChannelID;
  String androidMessageChannelName;
  String androidMessageIcon;
  String androidMessageSound;
  bool androidMessageVibrate;

  HandlerPrivateInfo({
    required this.appID,
    required this.token,
    required this.userID,
    required this.userName,
    required this.canInvitingInCalling,
    this.isIOSSandboxEnvironment,
    this.enableIOSVoIP = true,
    this.certificateIndex = 1,
    this.appName = '',
    this.androidCallChannelID = '',
    this.androidCallChannelName = '',
    this.androidCallIcon = '',
    this.androidCallSound = '',
    this.androidCallVibrate = true,
    this.androidMessageChannelID = '',
    this.androidMessageChannelName = '',
    this.androidMessageIcon = '',
    this.androidMessageSound = '',
    this.androidMessageVibrate = false,
  });

  factory HandlerPrivateInfo.fromJson(Map<String, dynamic> json) {
    return HandlerPrivateInfo(
      appID: json['aid'],
      token: json['tkn'],
      userID: json['uid'],
      userName: json['un'],
      isIOSSandboxEnvironment: json['isse'],
      enableIOSVoIP: json['eiv'] ?? true,
      certificateIndex: json['ci'] ?? 1,
      appName: json['an'] ?? '',
      canInvitingInCalling: json['ciic'] ?? '',
      androidCallChannelID: json['aci'] ?? '',
      androidCallChannelName: json['acn'] ?? '',
      androidCallIcon: json['ai'] ?? '',
      androidCallSound: json['as'] ?? '',
      androidCallVibrate: json['av'] ?? '',
      androidMessageChannelID: json['amci'] ?? '',
      androidMessageChannelName: json['amcn'] ?? '',
      androidMessageIcon: json['ami'] ?? '',
      androidMessageSound: json['ams'] ?? '',
      androidMessageVibrate: json['amv'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': appID,
      'tkn': token,
      'uid': userID,
      'un': userName,
      'isse': isIOSSandboxEnvironment,
      'eiv': enableIOSVoIP,
      'ci': certificateIndex,
      'an': appName,
      'ciic': canInvitingInCalling,
      'aci': androidCallChannelID,
      'acn': androidCallChannelName,
      'ai': androidCallIcon,
      'as': androidCallSound,
      'av': androidCallVibrate,
      'amci': androidMessageChannelID,
      'amcn': androidMessageChannelName,
      'ams': androidMessageSound,
      'ami': androidMessageIcon,
      'amv': androidMessageVibrate,
    };
  }

  @override
  String toString() {
    return 'HandlerPrivateInfo{'
        'appID:$appID,'
        'has token:${token.isNotEmpty},'
        'userID:$userID,'
        'userName:$userName,'
        'isIOSSandboxEnvironment:$isIOSSandboxEnvironment,'
        'enableIOSVoIP:$enableIOSVoIP,'
        'certificateIndex:$certificateIndex,'
        'appName:$appName,'
        'canInvitingInCalling:$canInvitingInCalling,'
        'androidCallChannelID:$androidCallChannelID,'
        'androidCallChannelName:$androidCallChannelName,'
        'androidCallIcon:$androidCallIcon,'
        'androidCallSound:$androidCallSound,'
        'androidCallVibrate:$androidCallVibrate,'
        'androidMessageChannelID:$androidMessageChannelID,'
        'androidMessageChannelName:$androidMessageChannelName,'
        'androidMessageSound:$androidMessageSound,'
        'androidMessageIcon:$androidMessageIcon,'
        'androidMessageVibrate:$androidMessageVibrate,'
        '}';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  static HandlerPrivateInfo? fromJsonString(String jsonString) {
    Map<String, dynamic>? jsonMap;
    try {
      jsonMap = jsonDecode(jsonString);
    } catch (e) {
      ZegoLoggerService.logInfo(
        'parsing handler info exception:$e',
        tag: 'call-invitation',
        subTag: 'call invitation service',
      );
    }

    return null == jsonMap ? null : HandlerPrivateInfo.fromJson(jsonMap);
  }
}
