// Flutter imports:
import 'package:flutter/services.dart';

/// @nodoc
class ZegoSignalingPluginLocalIMNotificationConfig {
  const ZegoSignalingPluginLocalIMNotificationConfig({
    required this.channelID,
    required this.title,
    required this.content,
    this.id,
    this.vibrate = false,
    this.iconSource,
    this.soundSource,
    this.clickCallback,
  });

  final int? id;
  final String? iconSource;
  final String? soundSource;
  final String channelID;
  final bool vibrate;
  final String title;
  final String content;
  final void Function(int notificationID)? clickCallback;

  @override
  String toString() {
    return 'id:$id, icon source:$iconSource, sound source:$soundSource,'
        'vibrate:$vibrate, channel id:$channelID, title:$title, content:$content';
  }
}

/// @nodoc
class ZegoSignalingPluginLocalNotificationChannelConfig {
  const ZegoSignalingPluginLocalNotificationChannelConfig({
    this.vibrate = false,
    this.soundSource,
    required this.channelID,
    required this.channelName,
  });

  final bool vibrate;
  final String? soundSource;
  final String channelID;
  final String channelName;

  @override
  String toString() {
    return 'sound source:$soundSource, vibrate:$vibrate, channel id:$channelID, channel name:$channelName';
  }
}
