// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/protocols.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/shared_pref_defines.dart';

const backgroundMessageIsolatePortName = 'bg_msg_isolate_port';
const backgroundMessageIsolateCloseCommand = 'close';

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

  /// missed call
  bool androidMissedCallEnabled;
  String androidMissedCallChannelID;
  String androidMissedCallChannelName;
  String androidMissedCallIcon;
  String androidMissedCallSound;
  bool androidMissedCallVibrate;
  String missedCallNotificationTitle;
  String missedGroupVideoCallNotificationContent;
  String missedGroupAudioCallNotificationContent;
  String missedVideoCallNotificationContent;
  String missedAudioCallNotificationContent;

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
    this.androidMissedCallEnabled = true,
    this.androidMissedCallChannelID = '',
    this.androidMissedCallChannelName = '',
    this.androidMissedCallIcon = '',
    this.androidMissedCallSound = '',
    this.androidMissedCallVibrate = false,
    this.missedCallNotificationTitle = '',
    this.missedGroupVideoCallNotificationContent = '',
    this.missedGroupAudioCallNotificationContent = '',
    this.missedVideoCallNotificationContent = '',
    this.missedAudioCallNotificationContent = '',
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
      androidMissedCallEnabled: json['amdce'] ?? '',
      androidMissedCallChannelID: json['amdcci'] ?? '',
      androidMissedCallChannelName: json['amdccn'] ?? '',
      androidMissedCallIcon: json['amdci'] ?? '',
      androidMissedCallSound: json['amdcs'] ?? '',
      androidMissedCallVibrate: json['amdcv'] ?? '',
      missedCallNotificationTitle: json['amdnt'] ?? '',
      missedGroupVideoCallNotificationContent: json['amdncgv'] ?? '',
      missedGroupAudioCallNotificationContent: json['amdncga'] ?? '',
      missedVideoCallNotificationContent: json['amdncv'] ?? '',
      missedAudioCallNotificationContent: json['amdnca'] ?? '',
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
      'amdce': androidMissedCallEnabled,
      'amdcci': androidMissedCallChannelID,
      'amdccn': androidMissedCallChannelName,
      'amdcs': androidMissedCallSound,
      'amdci': androidMissedCallIcon,
      'amdcv': androidMissedCallVibrate,
      'amdnt': missedCallNotificationTitle,
      'amdncgv': missedGroupVideoCallNotificationContent,
      'amdncga': missedGroupAudioCallNotificationContent,
      'amdncv': missedVideoCallNotificationContent,
      'amdnca': missedAudioCallNotificationContent,
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
        'androidMissedCallEnabled:$androidMissedCallEnabled,'
        'androidMissedCallChannelID:$androidMissedCallChannelID,'
        'androidMissedCallChannelName:$androidMissedCallChannelName,'
        'androidMissedCallSound:$androidMissedCallSound,'
        'androidMissedCallIcon:$androidMissedCallIcon,'
        'androidMissedCallVibrate:$androidMissedCallVibrate,'
        'missedCallNotificationTitle:$missedCallNotificationTitle,'
        'missedGroupVideoCallNotificationContent:$missedGroupVideoCallNotificationContent,'
        'missedGroupAudioCallNotificationContent:$missedGroupAudioCallNotificationContent,'
        'missedVideoCallNotificationContent:$missedVideoCallNotificationContent,'
        'missedAudioCallNotificationContent:$missedAudioCallNotificationContent,'
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

class ZegoCallAndroidCallBackgroundMessageHandlerMessage {
  final String title;
  final Map<String, Object?> extras;

  Map<String, dynamic> payloadMap = {};
  HandlerPrivateInfo? handlerInfo;

  /// call
  bool isAdvanceMode = false;
  BackgroundMessageType type = BackgroundMessageType.invitation;
  String invitationID = '';
  ZegoUIKitUser inviter = ZegoUIKitUser.empty();
  String customData = '';
  ZegoCallInvitationType callType = ZegoCallInvitationType.voiceCall;

  ZegoCallAndroidCallBackgroundMessageHandlerMessage({
    required this.title,
    required this.extras,
  }) {
    invitationID =
        extras[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
  }

  bool get isIMType =>
      BackgroundMessageType.textMessage == type ||
      BackgroundMessageType.mediaMessage == type;

  Future<void> parse() async {
    await _getHandlerInfo();

    _parsePayloadMap();
    type = BackgroundMessageTypeExtension.fromText(
      payloadMap[ZegoCallInvitationProtocolKey.operationType] as String? ?? '',
    );

    ZegoLoggerService.logInfo(
      'parsing type:$type',
      tag: 'call-invitation',
      subTag: 'android-handler',
    );
  }

  Future<void> parseCallInvitationInfo() async {
    /// offline call data format:
    ///
    /// payload:zego_uikit/lib/src/plugins/signaling/impl/service/invitation_service.dart#sendInvitation
    /// payload.data:zego_uikit_prebuilt_call/lib/src/invitation/internal/protocols.dart#InvitationSendRequestData.toJson
    ///
    /// cancel:
    /// zego_uikit_prebuilt_call/lib/src/invitation/pages/page_manager.dart#cancelGroupCallInvitation
    ///
    isAdvanceMode = ZegoUIKitAdvanceInvitationSendProtocol.typeOf(payloadMap);

    int invitationType = -1;
    if (isAdvanceMode) {
      final sendProtocol =
          ZegoUIKitAdvanceInvitationSendProtocol.fromJson(payloadMap);

      ZegoLoggerService.logInfo(
        'advance send protocol:$sendProtocol',
        tag: 'call-invitation',
        subTag: 'call handler',
      );

      inviter = sendProtocol.inviter;
      customData = sendProtocol.customData;
      invitationType = sendProtocol.type;
    } else {
      final sendProtocol = ZegoUIKitInvitationSendProtocol.fromJson(payloadMap);

      ZegoLoggerService.logInfo(
        'simple send protocol:$sendProtocol',
        tag: 'call-invitation',
        subTag: 'call handler',
      );

      inviter = sendProtocol.inviter;
      customData = sendProtocol.customData;
      invitationType = sendProtocol.type;
    }

    callType = ZegoCallTypeExtension.mapValue[invitationType] ??
        ZegoCallInvitationType.voiceCall;
  }

  void _parsePayloadMap() {
    final payload = extras['payload'] as String? ?? '';

    payloadMap = <String, dynamic>{};
    try {
      payloadMap = jsonDecode(payload) as Map<String, dynamic>? ?? {};
    } catch (e) {
      ZegoLoggerService.logError(
        'payload， json decode data exception:$e',
        tag: 'call-invitation',
        subTag: 'android-handler',
      );
    }
    ZegoLoggerService.logInfo(
      'payloadMap:$payloadMap',
      tag: 'call-invitation',
      subTag: 'android-handler',
    );
  }

  Future<void> _getHandlerInfo() async {
    final handlerInfoJson =
        await getPreferenceString(serializationKeyHandlerInfo);
    ZegoLoggerService.logInfo(
      'parsing handler info:$handlerInfoJson',
      tag: 'call-invitation',
      subTag: 'android-handler',
    );

    handlerInfo = HandlerPrivateInfo.fromJsonString(handlerInfoJson);
    ZegoLoggerService.logInfo(
      'parsing handler object:$handlerInfo',
      tag: 'call-invitation',
      subTag: 'android-handler',
    );
  }

  @override
  String toString() {
    return 'isAdvanceMode:$isAdvanceMode, '
        'type:$type, '
        'invitationID:$invitationID, '
        'inviter:$inviter, '
        'callType:$callType, '
        'custom data:$customData, '
        '----'
        'title:$title,'
        'extra:$extras, ';
  }
}
