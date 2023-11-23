package com.zegocloud.uikit.call_plugin;

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

import java.util.List;

/**
 * ZegoUIKitCallPlugin
 */
public class ZegoUIKitCallPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private Context context;
    private ActivityPluginBinding activityBinding;
    private PluginNotification notification;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("call plugin", "onAttachedToEngine");

        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "call_plugin");
        methodChannel.setMethodCallHandler(this);

        notification = new PluginNotification();

        context = flutterPluginBinding.getApplicationContext();

        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(Defines.ACTION_ACCEPT);
        intentFilter.addAction(Defines.ACTION_REJECT);
        intentFilter.addAction(Defines.ACTION_CANCEL);
        intentFilter.addAction(Defines.ACTION_CLICK);
        intentFilter.addAction(Defines.ACTION_CLICK_IM);
        LocalBroadcastManager manager = LocalBroadcastManager.getInstance(context);
        manager.registerReceiver(this, intentFilter);

        Log.d("call plugin", "android VERSION.RELEASE: " + Build.VERSION.RELEASE);
        Log.d("call plugin", "android VERSION.SDK_INT: " + Build.VERSION.SDK_INT);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.d("call plugin", "onMethodCall: " + call.method);

        if (call.method.equals(Defines.FLUTTER_API_FUNC_ACTIVE_AUDIO_BY_CALLKIT)) {
            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_ADD_LOCAL_IM_NOTIFICATION)) {
            String title = call.argument(Defines.FLUTTER_PARAM_TITLE);
            String content = call.argument(Defines.FLUTTER_PARAM_CONTENT);
            String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
            String iconSource = call.argument(Defines.FLUTTER_PARAM_ICON_SOURCE);
            String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
            String notificationId = call.argument(Defines.FLUTTER_PARAM_ID);
            Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

            notification.addLocalIMNotification(context, title, content, channelID, soundSource, iconSource, notificationId, isVibrate);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_ADD_LOCAL_CALL_NOTIFICATION)) {
            String title = call.argument(Defines.FLUTTER_PARAM_TITLE);
            String content = call.argument(Defines.FLUTTER_PARAM_CONTENT);
            String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
            String acceptButtonText = call.argument(Defines.FLUTTER_PARAM_ACCEPT_BUTTON_TEXT);
            String rejectButtonText = call.argument(Defines.FLUTTER_PARAM_REJECT_BUTTON_TEXT);
            String iconSource = call.argument(Defines.FLUTTER_PARAM_ICON_SOURCE);
            String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
            String notificationId = call.argument(Defines.FLUTTER_PARAM_ID);
            Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

            notification.addLocalCallNotification(context, title, content, acceptButtonText, rejectButtonText, channelID, soundSource, iconSource, notificationId, isVibrate);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_CREATE_NOTIFICATION_CHANNEL)) {
            String channelID = call.argument(Defines.FLUTTER_PARAM_CHANNEL_ID);
            String channelName = call.argument(Defines.FLUTTER_PARAM_CHANNEL_NAME);
            String soundSource = call.argument(Defines.FLUTTER_PARAM_SOUND_SOURCE);
            Boolean isVibrate = call.argument(Defines.FLUTTER_PARAM_VIBRATE);

            notification.createNotificationChannel(context, channelID, channelName, soundSource, isVibrate);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_DISMISS_ALL_NOTIFICATIONS)) {
            notification.dismissAllNotifications(context);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_ACTIVE_APP_TO_FOREGROUND)) {
            notification.activeAppToForeground(context);

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_REQUEST_DISMISS_KEYGUARD)) {
            notification.requestDismissKeyguard(context, activityBinding.getActivity());

            result.success(null);
        } else if (call.method.equals(Defines.FLUTTER_API_FUNC_CHECK_APP_RUNNING)) {
            result.success(isAppRunning());
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d("call plugin", "onDetachedFromEngine");
        methodChannel.setMethodCallHandler(null);
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

    private boolean isAppRunning() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
            List<ActivityManager.RunningAppProcessInfo> runningAppProcesses = activityManager.getRunningAppProcesses();
            if (runningAppProcesses != null) {
                for (ActivityManager.RunningAppProcessInfo processInfo : runningAppProcesses) {
                    Log.d("call plugin", "running app: " + processInfo.processName);

                    if (processInfo.processName.equals(context.getPackageName())) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    // BroadcastReceiver by other classes.
    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            String action = intent.getAction();
            Log.d("call plugin", "onReceive action, " + String.format("%s", action));

            switch (action) {
                case Defines.ACTION_ACCEPT:
                    onBroadcastNotificationAccepted(intent);
                    break;
                case Defines.ACTION_REJECT:
                    onBroadcastNotificationRejected(intent);
                    break;
                case Defines.ACTION_CANCEL:
                    onBroadcastNotificationCancelled(intent);
                    break;
                case Defines.ACTION_CLICK:
                    onBroadcastNotificationClicked(intent);
                    break;
                case Defines.ACTION_CLICK_IM:
                    onBroadcastNotificationIMClicked(intent);
                    break;
                default:
                    Log.d("call plugin", "onReceive, Received unknown action: " + (StringUtils.isNullOrEmpty(action) ? "empty" : action));
            }
        } catch (Exception e) {
            Log.d("call plugin", "onReceive exception, " + String.format("%s", e.getMessage()));
            e.printStackTrace();
        }
    }

    private void onBroadcastNotificationAccepted(Intent intent) {
        Log.d("call plugin", "onBroadcastNotificationAccepted");
        methodChannel.invokeMethod(Defines.ACTION_ACCEPT_CB_FUNC, null);
    }

    private void onBroadcastNotificationRejected(Intent intent) {
        Log.d("call plugin", "onBroadcastNotificationRejected");
        methodChannel.invokeMethod(Defines.ACTION_REJECT_CB_FUNC, null);
    }

    private void onBroadcastNotificationCancelled(Intent intent) {
        Log.d("call plugin", "onBroadcastNotificationCancelled");
        methodChannel.invokeMethod(Defines.ACTION_CANCEL_CB_FUNC, null);
    }

    private void onBroadcastNotificationClicked(Intent intent) {
        Log.d("call plugin", "onBroadcastNotificationClicked");
        methodChannel.invokeMethod(Defines.ACTION_CLICK_CB_FUNC, null);
    }

    private void onBroadcastNotificationIMClicked(Intent intent) {
        Log.d("call plugin", "onBroadcastNotificationIMClicked");
        methodChannel.invokeMethod(Defines.ACTION_CLICK_IM_CB_FUNC, null);
    }
}