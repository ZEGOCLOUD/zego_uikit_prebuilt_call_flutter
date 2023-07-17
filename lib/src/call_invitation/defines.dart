// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';

/// @nodoc
typedef PrebuiltConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

/// @nodoc
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

/// @nodoc
enum ZegoCallType {
  voiceCall,
  videoCall,
}

/// @nodoc
@Deprecated('Use [ZegoCallType]')
typedef ZegoInvitationType = ZegoCallType;

/// @nodoc
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

/// @nodoc
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

///
class ZegoCallUser {
  String id;
  String name;

  ZegoCallUser(this.id, this.name);

  @override
  String toString() {
    return '{id:$id, name:$name}';
  }
}

/// @nodoc
class ZegoIOSNotificationConfig {
  /// is iOS sandbox or not
  bool isSandboxEnvironment;
  String systemCallingIconName;

  ZegoIOSNotificationConfig({
    this.isSandboxEnvironment = false,
    this.systemCallingIconName = '',
  });

  @override
  String toString() {
    return 'isSandboxEnvironment:$isSandboxEnvironment, '
        'systemCallingIconName:$systemCallingIconName ';
  }
}

/// @nodoc
class ZegoAndroidNotificationConfig {
  /// specify the channel id of notification, which is same in 'Zego Console'
  String channelID;

  /// specify the channel name of notification, which is same in 'Zego Console'
  String channelName;

  /// specify the sound file name id of notification, which is same in 'Zego Console'
  String? sound;

  /// specify the call id show or hide,
  bool callIDVisibility;

  ZegoAndroidNotificationConfig({
    this.channelID = 'CallInvitation',
    this.channelName = 'Call Invitation',
    this.sound = '',
    this.callIDVisibility = true,
  });
}
