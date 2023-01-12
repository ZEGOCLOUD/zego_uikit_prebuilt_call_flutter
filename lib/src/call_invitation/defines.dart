// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';

typedef PrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

class ZegoRingtoneConfig {
  final String? packageName;
  final String? incomingCallPath;
  final String? outgoingCallPath;

  const ZegoRingtoneConfig({
    this.packageName,
    this.incomingCallPath,
    this.outgoingCallPath,
  });
}

enum ZegoCallType {
  voiceCall,
  videoCall,
}

@Deprecated('Use [ZegoCallType]')
typedef ZegoInvitationType = ZegoCallType;

extension ZegoCallTypeExtension on ZegoCallType {
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
}

class ZegoCallUser {
  String id;
  String name;

  ZegoCallUser(this.id, this.name);

  @override
  String toString() {
    return "{id:$id, name:$name}";
  }
}

class ZegoAndroidNotificationConfig {
  /// specify the channel id of notification, which is same in 'Zego Console'
  String channelID;

  /// specify the channel name of notification, which is same in 'Zego Console'
  String channelName;

  /// specify the sound file name id of notification, which is same in 'Zego Console'
  String? sound;

  ZegoAndroidNotificationConfig({
    this.channelID = "CallInvitation",
    this.channelName = "Call Invitation",
    this.sound = "",
  });
}
