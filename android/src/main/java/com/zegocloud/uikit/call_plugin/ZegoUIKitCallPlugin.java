package com.zegocloud.uikit.call_plugin;

import java.util.HashMap;
import java.util.Map;
import java.util.List;

import android.app.ActivityManager;
import android.content.Context;
import android.content.IntentFilter;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.zegocloud.uikit.call_plugin.notification.PluginNotification;
import com.zegocloud.uikit.call_plugin.Defines;


/**
 * ZegoUIKitCallPlugin
 */
public class ZegoUIKitCallPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String TAG = "ZegoUIKitCallPlugin";
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private Context context;
    private ActivityPluginBinding activityBinding;
    private PluginNotification notification;
    private LocalBroadcastManager broadcastManager;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine");

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "call_plugin");
        methodChannel.setMethodCallHandler(this);

        notification = new PluginNotification();
        context = flutterPluginBinding.getApplicationContext();
        broadcastManager = LocalBroadcastManager.getInstance(context);

        registerBroadcastReceiver();

        Log.d(TAG, "Android VERSION.RELEASE: " + Build.VERSION.RELEASE);
        Log.d(TAG, "Android VERSION.SDK_INT: " + Build.VERSION.SDK_INT);
    }

    private void registerBroadcastReceiver() {
        try {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(Defines.ACTION_CALL_NOTIFICATION_ACCEPT);
            intentFilter.addAction(Defines.ACTION_CALL_NOTIFICATION_REJECT);
            intentFilter.addAction(Defines.ACTION_CALL_NOTIFICATION_CANCEL);
            intentFilter.addAction(Defines.ACTION_CALL_NOTIFICATION_CLICK);
            intentFilter.addAction(Defines.ACTION_NORMAL_NOTIFICATION_CLICK);
            broadcastManager.registerReceiver(this, intentFilter);
            Log.d(TAG, "Broadcast receiver registered successfully");
        } catch (Exception e) {
            Log.e(TAG, "Error registering broadcast receiver: " + e.getMessage());
        }
    }

    private void unregisterBroadcastReceiver() {
        if (broadcastManager != null) {
            try {
                broadcastManager.unregisterReceiver(this);
            } catch (Exception e) {
                Log.e(TAG, "Error unregistering broadcast receiver: " + e.getMessage());
            }
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d(TAG, "onMethodCall: " + call.method);

        try {
            switch (call.method) {
                case Defines.FLUTTER_API_FUNC_ACTIVE_AUDIO_BY_CALLKIT:
                    handleActiveAudioByCallkit(result);
                    break;
                case Defines.FLUTTER_API_FUNC_SHOW_NORMAL_NOTIFICATION:
                    handleShowNormalNotification(call, result);
                    break;
                case Defines.FLUTTER_API_FUNC_SHOW_CALL_NOTIFICATION:
                    handleShowCallNotification(call, result);
                    break;
                case Defines.FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL:
                    handleCreateNotificationChannel(call, result);
                    break;
                case Defines.FLUTTER_API_FUNC_DISMISS_NOTIFICATION:
                    handleDismissNotification(call, result);
                    break;
                case Defines.FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS:
                    handleDismissAllNotifications(result);
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error in onMethodCall: " + e.getMessage());
            result.error(Defines.ERROR_UNKNOWN, e.getMessage(), null);
        }
    }

    private void handleActiveAudioByCallkit(Result result) {
        result.success(null);
    }

    private void handleShowNormalNotification(MethodCall call, Result result) {
        String title = call.argument(Defines.FLUTTER_PARAM_TITLE);
        String content = call.argument(Defines.FLUTTER_PARAM_CONTENT);
        String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
        String iconSource = call.argument(Defines.FLUTTER_PARAM_ICON_SOURCE);
        String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
        String notificationId = call.argument(Defines.FLUTTER_PARAM_ID);
        Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

        notification.handleShowNormalNotification(context, title, content, channelID, soundSource, iconSource, notificationId, isVibrate);
        result.success(null);
    }

    private void handleShowCallNotification(MethodCall call, Result result) {
        String title = call.argument(Defines.FLUTTER_PARAM_TITLE);
        String content = call.argument(Defines.FLUTTER_PARAM_CONTENT);
        String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
        String iconSource = call.argument(Defines.FLUTTER_PARAM_ICON_SOURCE);
        String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
        String notificationId = call.argument(Defines.FLUTTER_PARAM_ID);
        Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

        String acceptButtonText = call.argument(Defines.FLUTTER_PARAM_ACCEPT_BUTTON_TEXT);
        String rejectButtonText = call.argument(Defines.FLUTTER_PARAM_REJECT_BUTTON_TEXT);
        Boolean isVideo = call.argument(Defines.FLUTTER_PARAM_IS_VIDEO);

        notification.showCallNotification(context, title, content, acceptButtonText, rejectButtonText,
            channelID, soundSource, iconSource, notificationId, isVibrate, isVideo);
        result.success(null);
    }

    private void handleCreateNotificationChannel(MethodCall call, Result result) {
        String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
        String channelName = call.argument(Defines.FLUTTER_PARAM_CHANNEL_NAME);
        String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
        Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

        notification.createNotificationChannel(context, channelID, channelName, soundSource, isVibrate);
        result.success(null);
    }

    private void handleDismissNotification(MethodCall call, Result result) {
        String notificationIdString = call.argument(Defines.FLUTTER_PARAM_NOTIFICATION_ID);
        if (notificationIdString == null || notificationIdString.isEmpty()) {
            result.error(Defines.ERROR_INVALID_NOTIFICATION_ID, "Notification ID is null or empty", null);
            return;
        }

        try {
            int notificationID = Integer.parseInt(notificationIdString);
            notification.dismissNotification(context, notificationID);
            result.success(null);
        } catch (NumberFormatException e) {
            result.error(Defines.ERROR_INVALID_NOTIFICATION_ID, "Invalid notification ID format: " + notificationIdString, null);
        }
    }

    private void handleDismissAllNotifications(Result result) {
        notification.dismissAllNotifications(context);
        result.success(null);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        methodChannel.setMethodCallHandler(null);
        unregisterBroadcastReceiver();
    }


    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        Log.d("call plugin", "onAttachedToActivity");
        activityBinding = activityPluginBinding;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        Log.d("call plugin", "onReattachedToActivityForConfigChanges");
        activityBinding = activityPluginBinding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d("call plugin", "onDetachedFromActivityForConfigChanges");
        activityBinding = null;
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d("call plugin", "onDetachedFromActivity");
        activityBinding = null;
    }

    // BroadcastReceiver by other classes.
    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            String action = intent.getAction();
            Log.d(TAG, "onReceive action: " + action);

            if (action == null) {
                Log.w(TAG, "Received intent with null action");
                return;
            }

            switch (action) {
                case Defines.ACTION_CALL_NOTIFICATION_ACCEPT:
                    onBroadcastCallNotificationAccepted(intent);
                    break;
                case Defines.ACTION_CALL_NOTIFICATION_REJECT:
                    onBroadcastCallNotificationRejected(intent);
                    break;
                case Defines.ACTION_CALL_NOTIFICATION_CANCEL:
                    onBroadcastCallNotificationCancelled(intent);
                    break;
                case Defines.ACTION_CALL_NOTIFICATION_CLICK:
                    onBroadcastCallNotificationClicked(intent);
                    break;
                case Defines.ACTION_NORMAL_NOTIFICATION_CLICK:
                    onBroadcastNormalNotificationClicked(intent);
                    break;
                default:
                    Log.w(TAG, "Received unknown action: " + action);
                    break;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error in onReceive: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void onBroadcastCallNotificationAccepted(Intent intent) {
        Log.d(TAG, "onBroadcastCallNotificationAccepted");
        if (methodChannel != null) {
            methodChannel.invokeMethod(Defines.ACTION_CALL_NOTIFICATION_ACCEPT_CB_FUNC, null);
        } else {
            Log.e(TAG, "methodChannel is null");
        }
    }

    private void onBroadcastCallNotificationRejected(Intent intent) {
        Log.d(TAG, "onBroadcastCallNotificationRejected");
        if (methodChannel != null) {
            methodChannel.invokeMethod(Defines.ACTION_CALL_NOTIFICATION_REJECT_CB_FUNC, null);
        } else {
            Log.e(TAG, "methodChannel is null");
        }
    }

    private void onBroadcastCallNotificationCancelled(Intent intent) {
        Log.d(TAG, "onBroadcastCallNotificationCancelled");
        if (methodChannel != null) {
            methodChannel.invokeMethod(Defines.ACTION_CALL_NOTIFICATION_CANCEL_CB_FUNC, null);
        } else {
            Log.e(TAG, "methodChannel is null");
        }
    }

    private void onBroadcastCallNotificationClicked(Intent intent) {
        Log.d(TAG, "onBroadcastCallNotificationClicked");
        if (methodChannel != null) {
            methodChannel.invokeMethod(Defines.ACTION_CALL_NOTIFICATION_CLICK_CB_FUNC, null);
        } else {
            Log.e(TAG, "methodChannel is null");
        }
    }

    private void onBroadcastNormalNotificationClicked(Intent intent) {
        int notificationID = intent.getIntExtra(Defines.FLUTTER_PARAM_NOTIFICATION_ID, -1);
        Log.d(TAG, "onBroadcastNormalNotificationClicked, notification id: " + notificationID);

        if (methodChannel != null) {
            Map<String, Object> arguments = new HashMap<>();
            arguments.put(Defines.FLUTTER_PARAM_NOTIFICATION_ID, notificationID);
            methodChannel.invokeMethod(Defines.ACTION_NORMAL_NOTIFICATION_CLICK_CB_FUNC, arguments);
        } else {
            Log.e(TAG, "methodChannel is null");
        }
    }
}