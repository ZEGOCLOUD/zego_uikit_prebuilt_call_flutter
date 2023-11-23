package com.zegocloud.uikit.call_plugin;

public interface Defines {
    String FLUTTER_API_FUNC_ACTIVE_AUDIO_BY_CALLKIT = "activeAudioByCallKit";
    String FLUTTER_API_FUNC_CHECK_APP_RUNNING = "checkAppRunning";

    String FLUTTER_API_FUNC_ADD_LOCAL_IM_NOTIFICATION = "addLocalIMNotification";
    String FLUTTER_API_FUNC_ADD_LOCAL_CALL_NOTIFICATION = "addLocalCallNotification";
    String FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL = "createNotificationChannel";
    String FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS = "dismissAllNotifications";
    String FLUTTER_API_FUNC_ACTIVE_APP_TO_FOREGROUND = "activeAppToForeground";
    String FLUTTER_API_FUNC_REQUEST_DISMISS_KEYGUARD = "requestDismissKeyguard";

    String FLUTTER_PARAM_TITLE = "title";
    String FLUTTER_PARAM_CONTENT = "content";
    String FLUTTER_PARAM_CHANNEL_ID = "channel_id";
    String FLUTTER_PARAM_CHANNEL_NAME = "channel_name";
    String FLUTTER_PARAM_ACCEPT_BUTTON_TEXT = "accept_text";
    String FLUTTER_PARAM_REJECT_BUTTON_TEXT = "reject_text";
    String FLUTTER_PARAM_SOUND_SOURCE = "sound_source";
    String FLUTTER_PARAM_ICON_SOURCE = "icon_source";
    String FLUTTER_PARAM_ID = "id";
    String FLUTTER_PARAM_VIBRATE = "vibrate";
    String ACTION_ACCEPT = "ACTION_ACCEPT";
    String ACTION_REJECT = "ACTION_REJECT";
    String ACTION_CANCEL = "ACTION_CANCEL";
    String ACTION_CLICK = "ACTION_CLICK";
    String ACTION_ACCEPT_CB_FUNC = "onNotificationAccepted";
    String ACTION_REJECT_CB_FUNC = "onNotificationRejected";
    String ACTION_CANCEL_CB_FUNC = "onNotificationCancelled";
    String ACTION_CLICK_CB_FUNC = "onNotificationClicked";

    String ACTION_CLICK_IM = "ACTION_CLICK_IM";

    String ACTION_CLICK_IM_CB_FUNC = "onIMNotificationClicked";
}
