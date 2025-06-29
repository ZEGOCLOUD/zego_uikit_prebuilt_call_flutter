// Flutter imports:
import 'package:flutter/services.dart';

/// @nodoc
class ZegoCallCallNotificationConfig {
  const ZegoCallCallNotificationConfig({
    this.id,
    this.vibrate = true,
    required this.isVideo,
    this.iconSource,
    this.soundSource,
    this.acceptButtonText = 'Accept',
    this.rejectButtonText = 'Reject',
    required this.channelID,
    required this.title,
    required this.content,
    this.acceptCallback,
    this.rejectCallback,
    this.cancelCallback,
    this.clickCallback,
  });

  final int? id;
  final bool vibrate;
  final bool isVideo;
  final String? iconSource;
  final String? soundSource;
  final String channelID;
  final String title;
  final String content;
  final String acceptButtonText;
  final String rejectButtonText;
  final VoidCallback? acceptCallback;
  final VoidCallback? rejectCallback;
  final VoidCallback? cancelCallback;
  final VoidCallback? clickCallback;

  @override
  String toString() {
    return 'ZegoCallCallNotificationConfig{'
        'id:$id, '
        'icon source:$iconSource, '
        'sound source:$soundSource,'
        'channel id:$channelID, '
        'title:$title, content:$content, '
        'accept button text:$acceptButtonText, '
        'reject button text:$rejectButtonText, '
        '}';
  }
}

/// @nodoc
class ZegoCallNormalNotificationConfig {
  const ZegoCallNormalNotificationConfig({
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
    return 'ZegoCallNormalNotificationConfig:{'
        'id:$id, '
        'icon source:$iconSource, '
        'sound source:$soundSource, '
        'vibrate:$vibrate, '
        'channel id:$channelID, '
        'title:$title, content:$content'
        '}';
  }
}

/// @nodoc
class ZegoCallNotificationChannelConfig {
  const ZegoCallNotificationChannelConfig({
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
    return 'ZegoCallNotificationChannelConfig:{'
        'sound source:$soundSource, '
        'vibrate:$vibrate, '
        'channel id:$channelID, '
        'channel name:$channelName'
        '}';
  }
}
