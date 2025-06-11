package com.zegocloud.uikit.call_plugin;

public class Defines {
    // 错误码定义
    public static final String ERROR_UNKNOWN = "UNKNOWN_ERROR";
    public static final String ERROR_PERMISSION_DENIED = "PERMISSION_DENIED";
    public static final String ERROR_INVALID_NOTIFICATION_ID = "INVALID_NOTIFICATION_ID";
    public static final String ERROR_NOTIFICATION_CHANNEL_CREATE_FAILED = "NOTIFICATION_CHANNEL_CREATE_FAILED";
    public static final String ERROR_NOTIFICATION_CREATE_FAILED = "NOTIFICATION_CREATE_FAILED";

    // Flutter API 方法名
    public static final String FLUTTER_API_FUNC_ACTIVE_AUDIO_BY_CALLKIT = "activeAudioByCallKit";
    public static final String FLUTTER_API_FUNC_SHOW_NORMAL_NOTIFICATION = "showNormalNotification";
    public static final String FLUTTER_API_FUNC_SHOW_CALL_NOTIFICATION = "showCallNotification";
    public static final String FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL = "createNotificationChannel";
    public static final String FLUTTER_API_FUNC_DISMISS_NOTIFICATION = "dismissNotification";
    public static final String FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS = "dismissAllNotifications";

    // Flutter 参数名
    public static final String FLUTTER_PARAM_TITLE = "title";
    public static final String FLUTTER_PARAM_CONTENT = "content";
    public static final String FLUTTER_PARAM_CHANNEL_ID = "channel_id";
    public static final String FLUTTER_PARAM_CHANNEL_NAME = "channel_name";
    public static final String FLUTTER_PARAM_ACCEPT_BUTTON_TEXT = "accept_text";
    public static final String FLUTTER_PARAM_REJECT_BUTTON_TEXT = "reject_text";
    public static final String FLUTTER_PARAM_SOUND_SOURCE = "sound_source";
    public static final String FLUTTER_PARAM_ICON_SOURCE = "icon_source";
    public static final String FLUTTER_PARAM_ID = "id";
    public static final String FLUTTER_PARAM_NOTIFICATION_ID = "notification_id";
    public static final String FLUTTER_PARAM_VIBRATE = "vibrate";
    public static final String FLUTTER_PARAM_IS_VIDEO = "is_video";

    // 广播 Action
    public static final String ACTION_CALL_NOTIFICATION_ACCEPT = "ACTION_CALL_NOTIFICATION_ACCEPT";
    public static final String ACTION_CALL_NOTIFICATION_REJECT = "ACTION_CALL_NOTIFICATION_REJECT";
    public static final String ACTION_CALL_NOTIFICATION_CANCEL = "ACTION_CALL_NOTIFICATION_CANCEL";
    public static final String ACTION_CALL_NOTIFICATION_CLICK = "ACTION_CALL_NOTIFICATION_CLICK";
    public static final String ACTION_NORMAL_NOTIFICATION_CLICK = "ACTION_NORMAL_NOTIFICATION_CLICK";

    // 回调方法名
    public static final String ACTION_CALL_NOTIFICATION_ACCEPT_CB_FUNC = "onCallNotificationAccepted";
    public static final String ACTION_CALL_NOTIFICATION_REJECT_CB_FUNC = "onCallNotificationRejected";
    public static final String ACTION_CALL_NOTIFICATION_CANCEL_CB_FUNC = "onCallNotificationCancelled";
    public static final String ACTION_CALL_NOTIFICATION_CLICK_CB_FUNC = "onCallNotificationClicked";
    public static final String ACTION_NORMAL_NOTIFICATION_CLICK_CB_FUNC = "onNormalNotificationClicked";

    // 默认值
    public static final String DEFAULT_CHANNEL_ID = "zego_call_channel";
    public static final String DEFAULT_CHANNEL_NAME = "Call Notifications";
    public static final String DEFAULT_ACCEPT_TEXT = "Accept";
    public static final String DEFAULT_REJECT_TEXT = "Reject";
    public static final boolean DEFAULT_VIBRATE = true;
    public static final boolean DEFAULT_IS_VIDEO = false;

    // 通知相关常量
    public static final int NOTIFICATION_PRIORITY_HIGH = 1;
    public static final int NOTIFICATION_PRIORITY_MAX = 2;
    public static final long[] DEFAULT_VIBRATION_PATTERN = {0, 1000, 500, 1000};
    public static final int DEFAULT_NOTIFICATION_ID = 1;
}
