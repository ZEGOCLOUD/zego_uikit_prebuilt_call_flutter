// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

class InvitationInternalData {
  String callID = '';
  List<ZegoUIKitUser> invitees = [];
  String customData = '';

  InvitationInternalData.empty();

  InvitationInternalData(this.callID, this.invitees, this.customData);

  InvitationInternalData.fromJson(String json) {
    var dict = jsonDecode(json) as Map<String, dynamic>;
    callID = dict['call_id'] as String;
    customData = dict['custom_data'] as String;

    for (var invitee in dict['invitees'] as List) {
      invitees.add(userFromJson(invitee));
    }
  }

  String toJson() {
    var dict = {
      'call_id': callID,
      'invitees': invitees.map((e) => userToJson(e)).toList(),
      'custom_data': customData,
    };
    return const JsonEncoder().convert(dict);
  }

  ZegoUIKitUser userFromJson(String json) {
    var dict = jsonDecode(json) as Map<String, dynamic>;

    return ZegoUIKitUser(
      id: dict['user_id'] as String,
      name: dict['user_name'] as String,
    );
  }

  String userToJson(ZegoUIKitUser user) {
    var dict = {
      'user_id': user.id,
      'user_name': user.name,
    };
    return const JsonEncoder().convert(dict);
  }
}
