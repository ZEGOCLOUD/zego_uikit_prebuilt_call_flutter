// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

class ZegoCallInvitationProtocolKey {
  static String callID = 'call_id';
  static String invitationID = 'invitation_id';
  static String timeout = 'timeout';
  static String customData = 'custom_data';
  static String invitees = 'invitees';
  static String userID = 'user_id';
  static String userName = 'user_name';
  static String operationType = 'operation_type';

  ///
  static String reason = 'reason';
  static String refuseByDecline = 'decline';
  static String refuseByBusy = 'busy';
}

class ZegoCallInvitationSendRequestProtocol {
  String callID = '';
  List<ZegoUIKitUser> invitees = [];
  String customData = '';
  int timeout = 60;

  ZegoCallInvitationSendRequestProtocol.empty();

  ZegoCallInvitationSendRequestProtocol({
    required this.callID,
    required this.invitees,
    required this.timeout,
    required this.customData,
  });

  ZegoCallInvitationSendRequestProtocol.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'InvitationSendRequestData, json decode data exception:$e',
        tag: 'call',
        subTag: 'protocols',
      );
    }
    _parseFromMap(dict);
  }

  ZegoCallInvitationSendRequestProtocol.fromJsonMap(Map<String, dynamic> dict) {
    _parseFromMap(dict);
  }

  void _parseFromMap(Map<String, dynamic> dict) {
    callID = dict[ZegoCallInvitationProtocolKey.callID] as String;
    timeout = dict[ZegoCallInvitationProtocolKey.timeout] as int? ?? 60;
    customData =
        dict[ZegoCallInvitationProtocolKey.customData] as String? ?? '';

    for (final invitee
        in dict[ZegoCallInvitationProtocolKey.invitees] as List) {
      final inviteeDict = invitee as Map<String, dynamic>;
      final user = ZegoUIKitUser(
        id: inviteeDict[ZegoCallInvitationProtocolKey.userID] as String,
        name: inviteeDict[ZegoCallInvitationProtocolKey.userName] as String,
      );
      invitees.add(user);
    }
  }

  String toJson() {
    final dict = {
      ZegoCallInvitationProtocolKey.callID: callID,
      ZegoCallInvitationProtocolKey.invitees: invitees
          .map((user) => {
                ZegoCallInvitationProtocolKey.userID: user.id,
                ZegoCallInvitationProtocolKey.userName: user.name,
              })
          .toList(),
      ZegoCallInvitationProtocolKey.timeout: timeout,
      ZegoCallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class ZegoCallInvitationCancelRequestProtocol {
  ZegoCallInvitationCancelRequestProtocol({
    required this.callID,
    required this.customData,
  });

  String callID = '';
  String customData = '';

  ZegoCallInvitationCancelRequestProtocol.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'InvitationCancelRequestData, json decode data exception:$e',
        tag: 'call',
        subTag: 'protocols',
      );
    }

    _parseFromMap(dict);
  }

  ZegoCallInvitationCancelRequestProtocol.fromJsonMap(
      Map<String, dynamic> dict) {
    _parseFromMap(dict);
  }

  void _parseFromMap(Map<String, dynamic> dict) {
    callID = dict[ZegoCallInvitationProtocolKey.callID] as String? ?? '';
    customData =
        dict[ZegoCallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      ZegoCallInvitationProtocolKey.callID: callID,
      ZegoCallInvitationProtocolKey.operationType:
          BackgroundMessageType.cancelInvitation.text,
      ZegoCallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class ZegoCallInvitationRejectRequestProtocol {
  ZegoCallInvitationRejectRequestProtocol({
    required this.reason,
    this.targetInvitationID = '',
    this.customData = '',
  });

  String targetInvitationID = '';
  String reason = '';
  String customData = '';

  ZegoCallInvitationRejectRequestProtocol.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'InvitationCancelRejectData, json decode data exception:$e',
        tag: 'call',
        subTag: 'protocols',
      );
    }

    targetInvitationID =
        dict[ZegoCallInvitationProtocolKey.invitationID] as String? ?? '';
    reason = dict[ZegoCallInvitationProtocolKey.reason] as String? ?? '';
    customData =
        dict[ZegoCallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      ZegoCallInvitationProtocolKey.invitationID: targetInvitationID,
      ZegoCallInvitationProtocolKey.reason: reason,
      ZegoCallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class ZegoCallInvitationAcceptRequestProtocol {
  ZegoCallInvitationAcceptRequestProtocol({
    this.customData = '',
  });

  String customData = '';

  ZegoCallInvitationAcceptRequestProtocol.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'InvitationCancelRejectData, json decode data exception:$e',
        tag: 'call',
        subTag: 'protocols',
      );
    }

    customData =
        dict[ZegoCallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      ZegoCallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class ZegoCallInvitationOfflineCallKitCacheParameterProtocol {
  ZegoCallInvitationOfflineCallKitCacheParameterProtocol({
    required this.invitationID,
    required this.inviter,
    required this.callType,
    required this.payloadData,
    this.accept = false,
  });

  String invitationID = '';
  ZegoUIKitUser inviter = ZegoUIKitUser.empty();
  ZegoCallType callType = ZegoCallType.voiceCall;
  String payloadData = '';
  bool accept = false;

  bool get isEmpty => invitationID.isEmpty || payloadData.isEmpty;

  ZegoCallInvitationOfflineCallKitCacheParameterProtocol.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'ZegoCallInvitationOfflineCallKitParameterProtocol, json decode data exception:$e',
        tag: 'call',
        subTag: 'protocols',
      );
    }

    _parseFromMap(dict);
  }

  ZegoCallInvitationOfflineCallKitCacheParameterProtocol.fromJsonMap(
      Map<String, dynamic> dict) {
    _parseFromMap(dict);
  }

  void _parseFromMap(Map<String, dynamic> dict) {
    invitationID =
        dict[ZegoCallInvitationProtocolKey.invitationID] as String? ?? '';
    inviter = ZegoUIKitUser.fromJson(
      dict['inviter'] as Map<String, dynamic>? ?? {},
    );
    callType = ZegoCallTypeExtension.mapValue[dict['type'] as int? ?? 0] ??
        ZegoCallType.voiceCall;
    payloadData = dict['data'] as String? ?? '';

    accept = dict['accept'] as bool? ?? false;
  }

  String toJson() {
    return const JsonEncoder().convert(dict);
  }

  Map<String, dynamic> get dict => {
        ZegoCallInvitationProtocolKey.invitationID: invitationID,
        'inviter': inviter.toJson(),
        'type': callType.value,
        'data': payloadData,
        'accept': accept,
      };
}
