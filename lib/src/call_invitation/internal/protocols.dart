// Dart imports:
import 'dart:convert';

import 'package:zego_uikit/zego_uikit.dart';

class CallInvitationProtocolKey {
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

class InvitationSendRequestData {
  String callID = '';
  List<ZegoUIKitUser> invitees = [];
  String customData = '';
  int timeout = 60;

  InvitationSendRequestData.empty();

  InvitationSendRequestData({
    required this.callID,
    required this.invitees,
    required this.timeout,
    required this.customData,
  });

  InvitationSendRequestData.fromJson(String json) {
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

    callID = dict[CallInvitationProtocolKey.callID] as String;
    timeout = dict[CallInvitationProtocolKey.timeout] as int? ?? 60;
    customData = dict[CallInvitationProtocolKey.customData] as String? ?? '';

    for (final invitee in dict[CallInvitationProtocolKey.invitees] as List) {
      final inviteeDict = invitee as Map<String, dynamic>;
      final user = ZegoUIKitUser(
        id: inviteeDict[CallInvitationProtocolKey.userID] as String,
        name: inviteeDict[CallInvitationProtocolKey.userName] as String,
      );
      invitees.add(user);
    }
  }

  String toJson() {
    final dict = {
      CallInvitationProtocolKey.callID: callID,
      CallInvitationProtocolKey.invitees: invitees
          .map((user) => {
                CallInvitationProtocolKey.userID: user.id,
                CallInvitationProtocolKey.userName: user.name,
              })
          .toList(),
      CallInvitationProtocolKey.timeout: timeout,
      CallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class InvitationCancelRequestData {
  InvitationCancelRequestData({
    required this.callID,
    required this.customData,
  });

  String callID = '';
  String customData = '';

  InvitationCancelRequestData.fromJson(String json) {
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

    callID = dict[CallInvitationProtocolKey.callID] as String? ?? '';
    customData = dict[CallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      CallInvitationProtocolKey.callID: callID,
      CallInvitationProtocolKey.operationType:
          BackgroundMessageType.cancelInvitation.text,
      CallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class InvitationRejectRequestData {
  InvitationRejectRequestData({
    required this.reason,
    this.targetInvitationID = '',
    this.customData = '',
  });

  String targetInvitationID = '';
  String reason = '';
  String customData = '';

  InvitationRejectRequestData.fromJson(String json) {
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
        dict[CallInvitationProtocolKey.invitationID] as String? ?? '';
    reason = dict[CallInvitationProtocolKey.reason] as String? ?? '';
    customData = dict[CallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      CallInvitationProtocolKey.invitationID: targetInvitationID,
      CallInvitationProtocolKey.reason: reason,
      CallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}

class InvitationAcceptRequestData {
  InvitationAcceptRequestData({
    this.customData = '',
  });

  String customData = '';

  InvitationAcceptRequestData.fromJson(String json) {
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

    customData = dict[CallInvitationProtocolKey.customData] as String? ?? '';
  }

  String toJson() {
    final dict = {
      CallInvitationProtocolKey.customData: customData,
    };
    return const JsonEncoder().convert(dict);
  }
}
