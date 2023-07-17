// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class InvitationInternalData {
  String callID = '';
  List<ZegoUIKitUser> invitees = [];
  String customData = '';
  int timeout = 60;

  InvitationInternalData.empty();

  InvitationInternalData({
    required this.callID,
    required this.invitees,
    required this.timeout,
    required this.customData,
  });

  InvitationInternalData.fromJson(String json) {
    final dict = jsonDecode(json) as Map<String, dynamic>;
    callID = dict['call_id'] as String;
    timeout = dict['timeout'] as int? ?? 60;
    customData = dict['custom_data'] as String;

    for (final invitee in dict['invitees'] as List) {
      final inviteeDict = invitee as Map<String, dynamic>;
      final user = ZegoUIKitUser(
        id: inviteeDict['user_id'] as String,
        name: inviteeDict['user_name'] as String,
      );
      invitees.add(user);
    }
  }

  String toJson() {
    final dict = {
      'call_id': callID,
      'invitees': invitees
          .map((user) => {
                'user_id': user.id,
                'user_name': user.name,
              })
          .toList(),
      'timeout': timeout,
      'custom_data': customData,
    };
    return const JsonEncoder().convert(dict);
  }
}
