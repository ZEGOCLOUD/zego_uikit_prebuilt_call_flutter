// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/config.dart';

/// @nodoc
typedef ZegoCallPrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
  ZegoCallInvitationData,
);

/// Call Type
enum ZegoCallType {
  voiceCall,
  videoCall,
}

extension ZegoCallTypeExtension on ZegoCallType {
  static bool isCallType(int type) {
    return type == ZegoCallType.voiceCall.value ||
        type == ZegoCallType.videoCall.value;
  }

  static const valueMap = {
    ZegoCallType.voiceCall: 0,
    ZegoCallType.videoCall: 1,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoCallType> mapValue = {
    0: ZegoCallType.voiceCall,
    1: ZegoCallType.videoCall,
  };
}

class ZegoCallInvitationData {
  String callID = '';
  String invitationID = ''; //zim call id
  ZegoCallType type = ZegoCallType.voiceCall;
  List<ZegoUIKitUser> invitees = [];
  ZegoUIKitUser? inviter;
  String customData = '';

  ZegoCallInvitationData.empty();

  @override
  String toString() {
    return 'callID: $callID, '
        'invitationID: $invitationID, '
        'type: $type, '
        'invitees: ${invitees.map((invitee) => invitee.toString())}, '
        'inviter: $inviter, '
        'customData: $customData.';
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
