package com.zegocloud.uikit.call_plugin.notification;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.KeyguardManager;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.PowerManager;
import android.util.Log;
import android.view.WindowManager;
import android.widget.RemoteViews;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.zegocloud.uikit.call_plugin.Defines;
import com.zegocloud.uikit.call_plugin.R;
import com.zegocloud.uikit.call_plugin.StringUtils;

import java.util.List;

public class PluginNotification {
    public static String TAG = "ZEGO_Notification";

    public void addLocalIMNotification(Context context, String title, String body,
                                       String channelID, String soundSource, String iconSource,
                                       String notificationIdString, Boolean isVibrate) {
        Log.i("call plugin", "add IM Notification, title:" + title + ",body:" + body + ",channelId:" + channelID +
                ",soundSource:" + soundSource + ",iconSource:" + iconSource + "," +
                "notificationId:" + notificationIdString + ", isVibrate:" + isVibrate);

        createNotificationChannel(context, channelID, channelID, soundSource, isVibrate);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            wakeUpScreen(context);
        }

        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = PendingIntent.FLAG_IMMUTABLE;
        }

        ClickReceiver clickReceiver = new ClickReceiver();
        Intent clickIntent = new Intent(context, clickReceiver.getClass());
        clickIntent.setAction(Defines.ACTION_CLICK_IM);
        PendingIntent clickPendingIntent = PendingIntent.getBroadcast(context, 0, clickIntent, flags);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelID)
                .setContentTitle(title)
                .setContentText(body)
                .setContentIntent(clickPendingIntent)
                /// disappear after a few seconds
                .setFullScreenIntent(null, true)
                .setSound(retrieveSoundResourceUri(context, soundSource))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setOngoing(true)
                .setStyle(new NotificationCompat.DecoratedCustomViewStyle());

        if (isVibrate) {
            builder.setVibrate(new long[]{0});
        } else {
            builder.setVibrate(new long[]{0, 1000, 500, 1000});
        }

        int iconResourceId = BitmapUtils.getDrawableResourceId(context, iconSource);
        if (0 != iconResourceId) {
            builder.setSmallIcon(iconResourceId);
        } else {
            Log.i("call plugin", "icon resource id is not valid, use default icon");
            builder.setSmallIcon(android.R.drawable.ic_dialog_info);
        }

        android.app.Notification notification = builder.build();
        /// if android version < 4.1
        notification.flags |= notification.FLAG_NO_CLEAR;

        int notificationId = 1;
        try {
            notificationId = Integer.parseInt(notificationIdString);
        } catch (NumberFormatException e) {
            Log.d("call plugin", "convert notification id exception, " + String.format("%s", e.getMessage()));

            notificationId = 1;
        }

        int finalNotificationId = notificationId;
        String notificationTag = String.valueOf(notificationId);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationManager notificationManager = getNotificationManager(context);
            notificationManager.notify(notificationTag, notificationId, notification);
        } else {
            NotificationManagerCompat notificationManagerCompat = getAdaptedOldNotificationManager(context);
            notificationManagerCompat.notify(notificationTag, notificationId, notification);
        }
    }

    public void addLocalCallNotification(Context context, String title, String body,
                                         String acceptButtonText, String rejectButtonText,
                                         String channelID, String soundSource, String iconSource,
                                         String notificationIdString, Boolean isVibrate) {
        Log.i("call plugin", "add Notification, title:" + title + ",body:" + body +
                ",channelId:" + channelID + ",soundSource:" + soundSource + ",iconSource:" + iconSource +
                ",notificationId:" + notificationIdString + ",isVibrate:" + isVibrate);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            wakeUpScreen(context);
        }

        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = PendingIntent.FLAG_IMMUTABLE;
        }

        CancelReceiver cancelReceiver = new CancelReceiver();
        Intent intentCancel = new Intent(context, cancelReceiver.getClass());
        intentCancel.setAction(Defines.ACTION_CANCEL);
        PendingIntent cancelPendingIntent = PendingIntent.getBroadcast(context, 0, intentCancel, flags);

        ClickReceiver clickReceiver = new ClickReceiver();
        Intent clickIntent = new Intent(context, clickReceiver.getClass());
        clickIntent.setAction(Defines.ACTION_CLICK);
        PendingIntent clickPendingIntent = PendingIntent.getBroadcast(context, 0, clickIntent, flags);

        /// avoid head-up notification disappear after a few seconds
        Intent fullscreenIntent = new Intent();
        PendingIntent fullscreenPendingIntent = PendingIntent.getBroadcast(context, 0, fullscreenIntent, flags);

        /// content view
        AcceptReceiver acceptReceiver = new AcceptReceiver();
        Intent acceptIntent = new Intent(context, acceptReceiver.getClass());
        acceptIntent.setAction(Defines.ACTION_ACCEPT);
        PendingIntent acceptPendingIntent = PendingIntent.getBroadcast(context, 0, acceptIntent, flags);

        RejectReceiver rejectReceiver = new RejectReceiver();
        Intent rejectIntent = new Intent(context, rejectReceiver.getClass());
        rejectIntent.setAction(Defines.ACTION_REJECT);
        PendingIntent rejectPendingIntent = PendingIntent.getBroadcast(context, 0, rejectIntent, flags);

        RemoteViews contentView = new RemoteViews(context.getPackageName(), R.layout.layout_small_notification);
        contentView.setTextViewText(R.id.tvDecline, rejectButtonText);
        contentView.setTextViewText(R.id.tvAccept, acceptButtonText);
        contentView.setTextViewText(R.id.tvTitle, title);
        contentView.setTextViewText(R.id.tvBody, body);
        contentView.setOnClickPendingIntent(R.id.llAccept, acceptPendingIntent);
        contentView.setOnClickPendingIntent(R.id.llDecline, rejectPendingIntent);

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelID)
                .setContent(contentView)
                .setContentIntent(clickPendingIntent)
                .setDeleteIntent(cancelPendingIntent)
                .setFullScreenIntent(fullscreenPendingIntent, true)
                .setSound(retrieveSoundResourceUri(context, soundSource))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .setOngoing(true)
                .setStyle(new NotificationCompat.DecoratedCustomViewStyle());

        if (isVibrate) {
            builder.setVibrate(new long[]{0});
        } else {
            builder.setVibrate(new long[]{0, 1000, 500, 1000});
        }

        int iconResourceId = BitmapUtils.getDrawableResourceId(context, iconSource);
        if (0 != iconResourceId) {
            builder.setSmallIcon(iconResourceId);
        } else {
            Log.i("call plugin", "icon resource id is not valid, use default icon");
            builder.setSmallIcon(android.R.drawable.ic_dialog_info);
        }

        android.app.Notification notification = builder.build();
        /// keep ringtone play loop until notification dismissed
        notification.flags |= notification.FLAG_INSISTENT;
        /// if android version < 4.1
        notification.flags |= notification.FLAG_NO_CLEAR;

        int notificationId = 1;
        try {
            notificationId = Integer.parseInt(notificationIdString);
        } catch (NumberFormatException e) {
            Log.d("call plugin", "convert notification id exception, " + String.format("%s", e.getMessage()));

            notificationId = 1;
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationManager notificationManager = getNotificationManager(context);
            notificationManager.notify(notificationId, notification);
        } else {
            NotificationManagerCompat notificationManagerCompat = getAdaptedOldNotificationManager(context);
            notificationManagerCompat.notify(String.valueOf(notificationId), notificationId, notification);
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private NotificationManager getNotificationManager(Context context) {
        return (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    }

    private NotificationManagerCompat getAdaptedOldNotificationManager(Context context) {
        return NotificationManagerCompat.from(context);
    }


    public void createNotificationChannel(Context context, String channelID, String channelName, String soundSource, Boolean enableVibration) {
        Log.i("call plugin", "create channel, channelId:" + channelID + ",channelName:" + channelName + ",soundSource:" + soundSource + ", enableVibration:" + enableVibration);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            if (notificationManager.getNotificationChannel(channelID) == null) {
                Log.i("call plugin", "create channel");

                NotificationChannel channel = new NotificationChannel(channelID, channelName, NotificationManager.IMPORTANCE_MAX);

                AudioAttributes audioAttributes = new AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                        .build();
                Uri soundUri = retrieveSoundResourceUri(context, soundSource);
                channel.setSound(soundUri, audioAttributes);

                if (enableVibration) {
                    channel.enableVibration(true);
                    channel.setVibrationPattern(new long[]{0, 1000, 500, 1000});
                }

                notificationManager.createNotificationChannel(channel);
            } else {
                Log.i("call plugin", "channel exist");
            }
        } else {
            Log.i("call plugin", "version too low, not need create channel");
        }
    }

    public void dismissAllNotifications(Context context) {
        Log.i("call plugin", "dismiss all notifications");

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O /*Android 8*/) {
            NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
            notificationManager.cancelAll();
        } else {
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancelAll();
        }
    }

    public Uri retrieveSoundResourceUri(Context context, String soundSource) {
        Uri uri = null;
        if (StringUtils.isNullOrEmpty(soundSource)) {
            Log.i("call plugin", "source resource id is null or empty, use default ringtone");
            uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
        } else {
            int soundResourceId = AudioUtils.getAudioResourceId(context, soundSource);
            if (soundResourceId > 0) {
                uri = Uri.parse("android.resource://" + context.getPackageName() + "/" + soundResourceId);
            } else {
                Log.i("call plugin", "source resource id is not valid, use default ringtone");
                uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE);
            }
        }

        Log.i("call plugin", "uri:" + uri.toString());

        return uri;
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT_WATCH)
    public void wakeUpScreen(Context context) {
        PowerManager pm = (PowerManager) context.getSystemService(Context.POWER_SERVICE);
        boolean isScreenOn = pm.isInteractive();
        if (!isScreenOn) {
            String appName = getAppName(context);

            PowerManager.WakeLock wl = pm.newWakeLock(
                    PowerManager.FULL_WAKE_LOCK |
                            PowerManager.ACQUIRE_CAUSES_WAKEUP |
                            PowerManager.ON_AFTER_RELEASE,
                    appName + ":" + TAG + ":WakeupLock");
            wl.acquire(10000);

            PowerManager.WakeLock wl_cpu = pm.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    appName + ":" + TAG + ":WakeupCpuLock");
            wl_cpu.acquire(10000);
            wl_cpu.acquire(10000);
        }
    }

    public void requestDismissKeyguard(Context context, Activity activity) {
        Log.d("call plugin", "request dismiss keyguard");

        if (null == activity) {
            Log.d("call plugin", "request dismiss keyguard, activity is null");
            return;
        }

        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1) {
            KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
            if (keyguardManager.isKeyguardLocked()) {
                keyguardManager.requestDismissKeyguard(activity, null);
            }
        } else {
            WindowManager.LayoutParams params = activity.getWindow().getAttributes();
            params.flags |= WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED;
            params.flags |= WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD;
            activity.getWindow().setAttributes(params);
        }
    }

    public String getAppName(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        int stringId = applicationInfo.labelRes;
        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : context.getString(stringId);
    }

    public void activeAppToForeground(Context context) {
        Log.d("call plugin", "active app to foreground");

        String packageName = context.getPackageName();
        Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            context.getApplicationContext().startActivity(intent);
        }

//        // 获取ActivityManager
//        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
//
//        // 获取任务列表
//        List<ActivityManager.AppTask> appTasks = null;
//        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
//            appTasks = am.getAppTasks();
//        }
//        if (appTasks == null || appTasks.isEmpty()) {
//            Log.d("call plugin", "app task null");
//            return;
//        }
//
//        if (Build.VERSION.SDK_INT < 29) {
//            // Android 10以下版本，可以直接调用moveTaskToFront将任务带到前台
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                for (ActivityManager.AppTask appTask : appTasks) {
//                    if (appTask.getTaskInfo().baseActivity.getPackageName().equals(packageName)) {
//                        appTask.moveToFront();
//                        return;
//                    }
//                }
//            } else {
//                // 对于 API 23以下的版本，启动一个新的Activity来将应用带到前台
//                Intent intent = null;
//                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.CUPCAKE) {
//                    intent = context.getPackageManager().getLaunchIntentForPackage(packageName);
//                }
//                if (intent != null) {
//                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
//                    context.startActivity(intent);
//                }
//            }
//        } else {
//            // Android 10以上版本，需要通过启动intent来将应用带到前台
//            Intent intent = context.getPackageManager().getLaunchIntentForPackage(packageName);
//            if (intent != null) {
//                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED | Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
//                context.getApplicationContext().startActivity(intent);
//            }
//        }
    }
}
