// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'missed_call.dart';
import 'offline.dart';

class ZegoUIKitCallCache {
  ZegoUIKitCallCache._internal();

  static final ZegoUIKitCallCache _instance = ZegoUIKitCallCache._internal();

  factory ZegoUIKitCallCache() {
    return _instance;
  }

  /// cached ID of the current message
  Future<void> setOfflineIMKitMessageConversationInfo({
    required String conversationID,
    required int conversationTypeIndex,
    required String senderID,
  }) async {
    ZegoLoggerService.logInfo(
      'set offline message, '
      'conversationID:$conversationID, '
      'conversationTypeIndex:$conversationTypeIndex, ',
    );

    /// same as zimkit(zego_zimkit/lib/src/callkit/cache.dart)
    const String messageConversationCacheKey = 'msg_cv_cache';
    const String messageConversationCacheID = 'msg_cv_id';
    const String messageConversationCacheTypeIndex = 'msg_cv_type_idx';
    const String messageConversationSenderID = 'msg_cv_sender_id';

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      messageConversationCacheKey,
      const JsonEncoder().convert(
        {
          messageConversationCacheID: conversationID,
          messageConversationCacheTypeIndex: conversationTypeIndex,
          messageConversationSenderID: senderID,
        },
      ),
    );
  }

  final offlineCallKit = ZegoUIKitOfflineCallKitCache();
  final missedCall = ZegoUIKitMissedCallCache();
}
