// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import '../prebuilt_call_config.dart';

typedef ConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

class ZegoRingtoneConfig {
  final String? packageName;
  final String? callerPath;
  final String? calleePath;

  const ZegoRingtoneConfig({
    this.packageName,
    this.callerPath,
    this.calleePath,
  });
}

enum ZegoInvitationType {
  voiceCall,
  videoCall,
}

extension ZegoInvitationTypeExtension on ZegoInvitationType {
  static const valueMap = {
    ZegoInvitationType.voiceCall: 0,
    ZegoInvitationType.videoCall: 1,
  };

  int get value => valueMap[this] ?? -1;

  static const Map<int, ZegoInvitationType> mapValue = {
    0: ZegoInvitationType.voiceCall,
    1: ZegoInvitationType.videoCall,
  };
}

class ZegoCallInvitationData {
  String callID = '';
  ZegoInvitationType type = ZegoInvitationType.voiceCall;
  List<ZegoUIKitUser> invitees = [];
  ZegoUIKitUser? inviter;
  String customData = '';

  ZegoCallInvitationData.empty();
}
