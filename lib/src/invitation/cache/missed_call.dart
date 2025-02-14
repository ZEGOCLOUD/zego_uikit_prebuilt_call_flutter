// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

class ZegoUIKitMissedCallCache {
  String callkitMissedCalIDCacheKey = 'callkit_missed_call_id';

  /// cached ID of the current cal
  Future<void> setNotificationID(int notificationID) async {
    ZegoLoggerService.logInfo(
      'set offline missed call id:$notificationID',
      tag: 'call-invitation',
      subTag: 'offline, missed call',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(callkitMissedCalIDCacheKey, notificationID);
  }

  /// @nodoc
  ///
  /// Retrieve the cached ID of the current call, which is stored in the handler received from ZPNS.
  Future<int?> getNotificationID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(callkitMissedCalIDCacheKey);
  }

  /// cached ID of the current cal
  Future<void> clearNotificationID() async {
    ZegoLoggerService.logInfo(
      'clear offline missed call id',
      tag: 'call-invitation',
      subTag: 'offline, missed call',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(callkitMissedCalIDCacheKey);
  }

  /// cached ID of the missed cal
  Future<void> addNotification(
    int notificationID,
    ZegoCallInvitationData invitationData,
  ) async {
    ZegoLoggerService.logInfo(
      'add offline missed call notification, '
      'notification id:$notificationID, '
      'data:$invitationData',
      tag: 'call-invitation',
      subTag: 'offline, missed call',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(notificationID.toString(), invitationData.toJson());
  }

  /// Retrieve the cached ID of the missed call
  Future<ZegoCallInvitationData> getNotification(
    int notificationID,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString(notificationID.toString());

    return ZegoCallInvitationData.fromJson(dataJson ?? '');
  }

  /// cached ID of the current cal
  Future<void> clearNotification(int notificationID) async {
    ZegoLoggerService.logInfo(
      'clear offline missed call, notification id:$notificationID',
      tag: 'call-invitation',
      subTag: 'offline, missed call',
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.remove(notificationID.toString());
  }
}
