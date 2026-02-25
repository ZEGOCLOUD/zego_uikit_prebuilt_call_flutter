// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

/// @nodoc
typedef ZegoCallPrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
  ZegoCallInvitationData,
);

/// Call Type
///
/// [voiceCall] Represents a voice call invitation.
/// [videoCall] Represents a video call invitation.
enum ZegoCallInvitationType {
  voiceCall,
  videoCall,
}
// ZegoLiveStreamingInvitationType.requestCoHost: 2,
// ZegoLiveStreamingInvitationType.inviteToJoinCoHost: 3,
// ZegoLiveStreamingInvitationType.removeFromCoHost: 4,
// // ZegoLiveStreamingInvitationType.crossRoomPKBattleRequest: 5,
// ZegoLiveStreamingInvitationType.crossRoomPKBattleRequestV2: 6,

extension ZegoCallTypeExtension on ZegoCallInvitationType {
  static bool isCallType(int type) {
    return type == ZegoCallInvitationType.voiceCall.value ||
        type == ZegoCallInvitationType.videoCall.value;
  }

  static const valueMap = {
    ZegoCallInvitationType.voiceCall: 0,
    ZegoCallInvitationType.videoCall: 1,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoCallInvitationType> mapValue = {
    0: ZegoCallInvitationType.voiceCall,
    1: ZegoCallInvitationType.videoCall,
  };
}

/// Data class containing information about a call invitation.
class ZegoCallInvitationData {
  /// The unique identifier for the call.
  String callID = '';

  /// The unique identifier for the invitation.
  String invitationID = ''; //zim call id

  /// The type of call (voice or video).
  ZegoCallInvitationType type = ZegoCallInvitationType.voiceCall;

  /// List of users being invited.
  List<ZegoUIKitUser> invitees = [];

  /// The user who sent the invitation.
  ZegoUIKitUser? inviter;

  /// Timeout in seconds for the invitation.
  int timeoutSeconds = 60;

  /// Custom data to send with the invitation.
  String customData = '';

  ZegoCallInvitationData({
    required this.callID,
    required this.invitationID,
    required this.type,
    required this.inviter,
    required this.invitees,
    required this.timeoutSeconds,
    required this.customData,
  });

  ZegoCallInvitationData.empty();
  bool get isEmpty => callID.isEmpty || invitationID.isEmpty;

  ZegoCallInvitationData.fromJson(String json) {
    var dict = <String, dynamic>{};
    try {
      dict = jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      ZegoLoggerService.logError(
        'json decode data exception:$e, '
        'json:$json',
        tag: 'call-invitation',
        subTag: 'ZegoCallInvitationData',
      );
    }

    _parseFromMap(dict);
  }

  ZegoCallInvitationData.fromJsonMap(Map<String, dynamic> dict) {
    _parseFromMap(dict);
  }

  void _parseFromMap(Map<String, dynamic> dict) {
    callID = dict['call_id'] as String? ?? '';
    invitationID = dict['invitation_id'] as String? ?? '';
    type = ZegoCallTypeExtension.mapValue[dict['type'] as int? ?? 0] ??
        ZegoCallInvitationType.voiceCall;
    customData = dict['data'] as String? ?? '';
    timeoutSeconds = dict['timeout'] as int? ?? 60;

    for (final invitee in dict['invitees'] as List) {
      final inviteeDict = invitee as Map<String, dynamic>;
      final user = ZegoUIKitUser(
        id: inviteeDict['id'] as String,
        name: inviteeDict['name'] as String,
      );
      invitees.add(user);
    }

    inviter = ZegoUIKitUser(
      id: dict['inviter_id'] as String? ?? '',
      name: dict['inviter_name'] as String? ?? '',
    );
  }

  String toJson() {
    final dict = {
      'call_id': callID,
      'invitation_id': invitationID,
      'type': type.index,
      'timeout': timeoutSeconds,
      'data': customData,
      'inviter_id': inviter?.id ?? '',
      'inviter_name': inviter?.name ?? '',
      'invitees':
          invitees.map((user) => {'id': user.id, 'name': user.name}).toList(),
    };

    return const JsonEncoder().convert(dict);
  }

  @override
  String toString() {
    return 'ZegoCallInvitationData:{'
        'callID: $callID, '
        'invitationID: $invitationID, '
        'type: $type, '
        'timeoutSeconds: $timeoutSeconds, '
        'invitees: ${invitees.map((invitee) => invitee.toString())}, '
        'inviter: $inviter, '
        'customData: $customData.'
        '}';
  }
}

/// User In Call
/// User class representing a participant in a call invitation.
class ZegoCallUser {
  /// The unique identifier for the user.
  String id;

  /// The display name of the user.
  String name;

  ZegoCallUser(this.id, this.name);

  /// Create a ZegoCallUser from a ZegoUIKitUser.
  ZegoCallUser.fromUIKit(ZegoUIKitUser user) : this(user.id, user.name);

  @override
  String toString() {
    return '{id:$id, name:$name}';
  }
}
