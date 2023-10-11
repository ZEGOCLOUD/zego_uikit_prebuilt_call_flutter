// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

// Package imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter_callkit_incoming_yoer/entities/call_event.dart';
import 'package:flutter_callkit_incoming_yoer/flutter_callkit_incoming.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/callkit/callkit_incoming_wrapper.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/shared_pref_defines.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zpns/zego_zpns.dart';

const backgroundMessageIsolatePortName = 'bg_msg_isolate_port';

/// @nodoc
///
/// [Android] Silent Notification event notify
///
/// Note: @pragma('vm:entry-point') must be placed on a function to indicate that it can be parsed, allocated, or called directly from native or VM code in AOT mode.
@pragma('vm:entry-point')
Future<void> onBackgroundMessageReceived(ZPNsMessage message) async {
  ZegoLoggerService.logInfo(
    'on background message received: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}',
    tag: 'call',
    subTag: 'background message',
  );

  final registeredIsolatePort =
      IsolateNameServer.lookupPortByName(backgroundMessageIsolatePortName);
  final isAppRunning = null != registeredIsolatePort;
  ZegoLoggerService.logInfo(
    'isAppRunning:$isAppRunning',
    tag: 'call',
    subTag: 'background message',
  );
  if (isAppRunning) {
    /// android callkit拉起两个app的问题
    /// 如果app还存在，那么就放弃这次离线通知
    /// 激活当前app, 初始化zim，等zim的在线补发
    ///
    /// after app being screen-locked for more than 10 minutes, the app was not
    /// killed(suspended) but the zpns login timed out, so that's why receive
    /// offline call when app was alive.
    ///
    /// At this time, because the fcm push will make the Dart open another isolate (thread) to process,
    /// it will cause the problem of double opening of the app.
    ///
    /// So, send this offline call to [ZegoUIKitPrebuiltCallInvitationService] to handle.
    ZegoLoggerService.logInfo(
      'app has another isolate(${registeredIsolatePort.hashCode}), '
      'send command to deal with this background message',
      tag: 'call',
      subTag: 'background message',
    );
    registeredIsolatePort.send(message.extras);
    return;
  }

  final backgroundPort = ReceivePort();
  IsolateNameServer.registerPortWithName(
    backgroundPort.sendPort,
    backgroundMessageIsolatePortName,
  );
  backgroundPort.listen((dynamic message) async {
    final messageExtras = message as Map<String, Object?>? ?? {};

    ZegoLoggerService.logInfo(
      'current port(${backgroundPort.hashCode}) receive, '
      'message:$message, extra:$messageExtras',
      tag: 'call',
      subTag: 'background message',
    );

    _onBackgroundMessageReceived(
      messageExtras: messageExtras,
      fromOtherIsolate: true,
      backgroundPort: backgroundPort,
    );
  });
  ZegoLoggerService.logInfo(
    'register and listen port(${backgroundPort.hashCode}), '
    'send command to deal with this background message',
    tag: 'call',
    subTag: 'background message',
  );

  _onBackgroundMessageReceived(
    messageExtras: message.extras,
    fromOtherIsolate: false,
    backgroundPort: backgroundPort,
  );
}

Future<void> _onBackgroundMessageReceived({
  required Map<String, Object?> messageExtras,
  required bool fromOtherIsolate,
  required ReceivePort backgroundPort,
}) async {
  /// maybe installed, but offline after 5 minutes, so received onBackgroundMessageReceived
  /// so don't install if had installed
  final signalingPluginNeedInstalled = ValueNotifier<bool>(
      null == ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling));
  ZegoLoggerService.logInfo(
    'signaling plugin need installed:$signalingPluginNeedInstalled',
    tag: 'call',
    subTag: 'background message',
  );
  if (signalingPluginNeedInstalled.value) {
    await _installSignalingPlugin();
  }

  final payload = messageExtras['payload'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
  final operationType = payloadMap['operation_type'] as String? ?? '';

  ZegoLoggerService.logInfo(
    'operationType:$operationType',
    tag: 'call',
    subTag: 'background message',
  );

  /// offline cancel invitation
  if ('cancel_invitation' == operationType) {
    /// offline call cancel data format:
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

    final callID = payloadMap['call_id'] as String? ?? '';
    await _onBackgroundInvitationCanceled(callID);
  } else {
    await _onBackgroundOfflineCall(
      messageExtras: messageExtras,
      payloadMap: payloadMap,
      signalingPluginInstalled: signalingPluginNeedInstalled,
      fromOtherIsolate: fromOtherIsolate,
      backgroundPort: backgroundPort,
    );
  }
}

Future<void> _onBackgroundInvitationCanceled(String callID) async {
  ZegoLoggerService.logInfo(
    'background offline call cancel, callID:$callID',
    tag: 'call',
    subTag: 'background message',
  );

  await getOfflineCallKitCallID().then((cacheCallID) async {
    ZegoLoggerService.logInfo(
      'background offline call cancel, cacheCallID:$cacheCallID',
      tag: 'call',
      subTag: 'background message',
    );

    if (cacheCallID == callID) {
      ZegoLoggerService.logInfo(
        'background offline call cancel, callID is same as cacheCallID, clear...',
        tag: 'call',
        subTag: 'background message',
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
}) async {
  /// offline call data format:
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
    'background offline call, from other isolate:$fromOtherIsolate',
    tag: 'call',
    subTag: 'background message',
  );

  final invitationID = messageExtras['call_id'] as String? ?? '';
  final inviter = ZegoUIKitUser(
      id: payloadMap['inviter_id'] as String? ?? '',
      name: payloadMap['inviter_name'] as String? ?? '');
  final callType = ZegoCallTypeExtension.mapValue[payloadMap['type'] as int?] ??
      ZegoCallType.voiceCall;
  final payloadData = payloadMap['data'] as String? ?? '';
  final invitationInternalData = InvitationInternalData.fromJson(payloadData);

  final signalingSubscriptions = <StreamSubscription<dynamic>>[];
  _listenFlutterCallkitIncomingEvent(
    invitationID: invitationID,
    inviter: inviter,
    callType: callType,
    payloadData: payloadData,
    signalingPluginNeedUninstalled: signalingPluginInstalled,
    signalingSubscriptions: signalingSubscriptions,
    backgroundPort: backgroundPort,
  );
  _listenSignalingEvents(signalingSubscriptions);

  /// cache and do when app run
  setOfflineCallKitCallID(invitationInternalData.callID);
  await setOfflineCallKitParams(jsonEncode({
    'invitation_id': invitationID,
    'inviter': inviter,
    'type': callType.value,
    'data': payloadData,
  }));

  if (fromOtherIsolate) {
    /// the app is in the background or locked, brought to the foreground and prompt the user to unlock it
    await ZegoUIKit().getSignalingPlugin().activeAppToForeground();
    await ZegoUIKit().getSignalingPlugin().requestDismissKeyguard();
  } else {
    await showCallkitIncoming(
      caller: inviter,
      callType: callType,
      invitationInternalData: invitationInternalData,
      title: messageExtras['title'] as String? ?? '',
      body: messageExtras['body'] as String? ?? '',
    );
  }
}

void _listenFlutterCallkitIncomingEvent({
  required String invitationID,
  required ZegoUIKitUser inviter,
  required ZegoCallType callType,
  required String payloadData,
  required ValueNotifier<bool> signalingPluginNeedUninstalled,
  required List<StreamSubscription<dynamic>> signalingSubscriptions,
  required ReceivePort backgroundPort,
}) {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    if (null == event) {
      ZegoLoggerService.logError(
        'android callkit incoming event is null',
        tag: 'call',
        subTag: 'background message',
      );

      return;
    }

    ZegoLoggerService.logInfo(
      'android callkit incoming event, event:${event.event}, body:${event?.body}',
      tag: 'call',
      subTag: 'background message',
    );

    switch (event.event) {
      case Event.actionCallAccept:

        /// After launching the app, will check in the [ZegoUIKitPrebuiltCallInvitationService.init] method.
        /// If there is exist an OfflineCallKitParams, simulate accepting the online call and join the room directly.

        ZegoLoggerService.logInfo(
          'accept, wait direct accept and enter call in ZegoUIKitPrebuiltCallInvitationService.init',
          tag: 'call',
          subTag: 'background message',
        );

        break;
      case Event.actionCallDecline:
        await clearOfflineCallKitCallID();
        await clearOfflineCallKitParams();

        await ZegoUIKit().getSignalingPlugin().refuseInvitationByInvitationID(
              invitationID: invitationID,
              data: '{"reason":"decline"}',
            );
        break;
      case Event.actionCallTimeout:
        await clearOfflineCallKitCallID();
        await clearOfflineCallKitParams();
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
          'clear IsolateNameServer, port:${backgroundPort.hashCode}',
          tag: 'call',
          subTag: 'background message',
        );
        backgroundPort.close();
        IsolateNameServer.removePortNameMapping(
            backgroundMessageIsolatePortName);

        for (final subscription in signalingSubscriptions) {
          subscription.cancel();
        }

        ZegoLoggerService.logInfo(
          'clear signaling plugin, need uninstalled:$signalingPluginNeedUninstalled',
          tag: 'call',
          subTag: 'background message',
        );
        if (signalingPluginNeedUninstalled.value) {
          signalingPluginNeedUninstalled.value = false;
          await _uninstallSignalingPlugin();
        }
        break;
      default:
        break;
    }
  });
}

void _listenSignalingEvents(
  List<StreamSubscription<dynamic>> signalingSubscriptions,
) {
  if (ZegoPluginAdapter().getPlugin(ZegoUIKitPluginType.signaling) == null) {
    ZegoLoggerService.logInfo(
      "signaling plugin is null, couldn't listen",
      tag: 'call',
      subTag: 'background message',
    );

    return;
  }

  ZegoUIKit().getSignalingPlugin().setThroughMessageHandler(_onThroughMessage);

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

void _onInvitationTimeout(Map<String, dynamic> params) {
  final ZegoUIKitUser inviter = params['inviter']!;
  final String data = params['data']!; // extended field

  ZegoLoggerService.logInfo(
    'on invitation timeout, inviter:$inviter, data:$data',
    tag: 'call',
    subTag: 'background message',
  );
}

Future<void> _onInvitationCanceled(Map<String, dynamic> params) async {
  final ZegoUIKitUser inviter = params['inviter']!;
  final String data = params['data']!; // extended field

  ZegoLoggerService.logInfo(
    'on invitation canceled, inviter:$inviter, data:$data',
    tag: 'call',
    subTag: 'background message',
  );

  final dataMap = jsonDecode(data) as Map<String, dynamic>;
  final callID = dataMap['call_id'] as String? ?? '';
  await _onBackgroundInvitationCanceled(callID);
}

Future<void> _installSignalingPlugin() async {
  final appSign = await getPreferenceString(
    serializationKeyAppSign,
    withDecode: true,
  );
  final handlerInfoJson =
      await getPreferenceString(serializationKeyHandlerInfo);
  ZegoLoggerService.logInfo(
    'install signaling plugin, parsing handler info:$handlerInfoJson',
    tag: 'call',
    subTag: 'background message',
  );
  final handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);
  if (null == handlerInfo) {
    removePreferenceValue(serializationKeyHandlerInfo);

    ZegoLoggerService.logInfo(
      'install signaling plugin, but handler info parse failed',
      tag: 'call',
      subTag: 'background message',
    );
    return;
  }

  ZegoLoggerService.logInfo(
    'install signaling plugin, handler info:$handlerInfo',
    tag: 'call',
    subTag: 'background message',
  );
  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

  ZegoLoggerService.logInfo(
    'init signaling plugin',
    tag: 'call',
    subTag: 'background message',
  );
  await ZegoUIKit()
      .getSignalingPlugin()
      .init(int.tryParse(handlerInfo.appID) ?? 0, appSign: appSign);

  ZegoLoggerService.logInfo(
    'login signaling plugin',
    tag: 'call',
    subTag: 'background message',
  );
  await ZegoUIKit().getSignalingPlugin().login(
        id: handlerInfo.userID,
        name: handlerInfo.userName,
      );

  ZegoLoggerService.logInfo(
    'enable notify',
    tag: 'call',
    subTag: 'background message',
  );
  await ZegoUIKit()
      .getSignalingPlugin()
      .enableNotifyWhenAppRunningInBackgroundOrQuit(
        true,
        isIOSSandboxEnvironment: handlerInfo.isIOSSandboxEnvironment,
        enableIOSVoIP: handlerInfo.enableIOSVoIP,
        certificateIndex: handlerInfo.certificateIndex,
        appName: handlerInfo.appName,
        androidChannelID: handlerInfo.androidChannelID,
        androidChannelName: handlerInfo.androidChannelName,
        androidSound: '/raw/${handlerInfo.androidSound}',
      );
}

Future<void> _uninstallSignalingPlugin() async {
  ZegoLoggerService.logInfo(
    'uninstall signaling plugin',
    tag: 'call',
    subTag: 'background message',
  );

  /// force kill the signaling SDK, otherwise it will keep running in the
  /// background.
  /// Otherwise, sdk will keep receiving online calls even in offline status.
  await ZegoUIKit().getSignalingPlugin().uninit(forceDestroy: true);

  ZegoUIKit().uninstallPlugins([ZegoUIKitSignalingPlugin()]);
}

void _onThroughMessage(
  ZPNsMessage message,
  Function? iOSOnThroughMessageReceivedCompletion,
) {
  ZegoLoggerService.logInfo(
    'on through message: '
    'title:${message.title}, '
    'content:${message.content}, '
    'extras:${message.extras}',
    tag: 'call',
    subTag: 'background message',
  );
  // title:, content:, extras:{payload: {"call_id":"call_073493_1694085825032","operation_type":"cancel_invitation"}, body: , title: , call_id: 3789618859125027445}

  final payload = message.extras['payload'] as String? ?? '';
  final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
  final operationType = payloadMap['operation_type'] as String? ?? '';

  /// cancel invitation
  if ('cancel_invitation' == operationType) {
    final callID = payloadMap['call_id'] as String? ?? '';
    _onBackgroundInvitationCanceled(callID);
  }
}

class HandlerPrivateInfo {
  String appID;
  String userID;
  String userName;
  bool isIOSSandboxEnvironment;
  bool enableIOSVoIP;
  int certificateIndex;
  String appName;
  String androidChannelID;
  String androidChannelName;
  String androidSound;

  HandlerPrivateInfo({
    required this.appID,
    required this.userID,
    required this.userName,
    this.isIOSSandboxEnvironment = false,
    this.enableIOSVoIP = true,
    this.certificateIndex = 1,
    this.appName = '',
    this.androidChannelID = '',
    this.androidChannelName = '',
    this.androidSound = '',
  });

  factory HandlerPrivateInfo.fromJson(Map<String, dynamic> json) {
    return HandlerPrivateInfo(
      appID: json['aid'],
      userID: json['uid'],
      userName: json['un'],
      isIOSSandboxEnvironment: json['isse'] ?? false,
      enableIOSVoIP: json['eiv'] ?? true,
      certificateIndex: json['ci'] ?? 1,
      appName: json['an'] ?? '',
      androidChannelID: json['aci'] ?? '',
      androidChannelName: json['acn'] ?? '',
      androidSound: json['as'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aid': appID,
      'uid': userID,
      'un': userName,
      'isse': isIOSSandboxEnvironment,
      'eiv': enableIOSVoIP,
      'ci': certificateIndex,
      'an': appName,
      'aci': androidChannelID,
      'acn': androidChannelName,
      'as': androidSound,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
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
        tag: 'call',
        subTag: 'call invitation service',
      );
    }

    return null == jsonMap ? null : HandlerPrivateInfo.fromJson(jsonMap);
  }
}
