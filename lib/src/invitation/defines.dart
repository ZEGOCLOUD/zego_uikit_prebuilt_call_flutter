// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

/// @nodoc
typedef ZegoCallPrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
  ZegoCallInvitationData,
);

/// Call Type
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

class ZegoCallInvitationData {
  String callID = '';
  String invitationID = ''; //zim call id
  ZegoCallInvitationType type = ZegoCallInvitationType.voiceCall;
  List<ZegoUIKitUser> invitees = [];
  ZegoUIKitUser? inviter;
  String customData = '';

  ZegoCallInvitationData.empty();
  bool get isEmpty => callID.isEmpty || invitationID.isEmpty;

  @override
  String toString() {
    return 'ZegoCallInvitationData:{'
        'callID: $callID, '
        'invitationID: $invitationID, '
        'type: $type, '
        'invitees: ${invitees.map((invitee) => invitee.toString())}, '
        'inviter: $inviter, '
        'customData: $customData.'
        '}';
  }
}

/// User In Call
class ZegoCallUser {
  String id;
  String name;

  ZegoCallUser(this.id, this.name);

  ZegoCallUser.fromUIKit(ZegoUIKitUser user) : this(user.id, user.name);

  @override
  String toString() {
    return '{id:$id, name:$name}';
  }
}
