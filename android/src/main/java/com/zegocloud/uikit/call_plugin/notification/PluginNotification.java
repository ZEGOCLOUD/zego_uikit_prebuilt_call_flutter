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

    public void handleShowNormalNotification(Context context, String title, String body,
                                       String channelID, String soundSource, String iconSource,
                                       String notificationIdString, Boolean isVibrate) {
        Log.i("call plugin", "show normal Notification, title:" + title + ",body:" + body + ",channelId:" + channelID +
                ",soundSource:" + soundSource + ",iconSource:" + iconSource + "," +
                "notificationId:" + notificationIdString + ", isVibrate:" + isVibrate);

        int notificationId = 1;
        try {
            notificationId = Integer.parseInt(notificationIdString);
        } catch (NumberFormatException e) {
            Log.d("call plugin", "convert notification id exception, " + String.format("%s", e.getMessage()));

            notificationId = 1;
        }

        createNotificationChannel(context, channelID, channelID, soundSource, isVibrate);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            wakeUpScreen(context);
        }

        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = PendingIntent.FLAG_IMMUTABLE ;
        }
        /// update extra value
        flags |= PendingIntent.FLAG_ONE_SHOT;

        ClickReceiver clickReceiver = new ClickReceiver();
        Intent clickIntent = new Intent(context, clickReceiver.getClass());
        clickIntent.setAction(Defines.ACTION_NORMAL_NOTIFICATION_CLICK);
        clickIntent.putExtra(Defines.FLUTTER_PARAM_NOTIFICATION_ID, notificationId);
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
                .setOngoing(false)
                .setStyle(new NotificationCompat.DecoratedCustomViewStyle());

        if (isVibrate) {
            builder.setVibrate(new long[]{0, 1000, 500, 1000});
        } else {
            builder.setVibrate(new long[]{0});
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
//        notification.flags |= notification.FLAG_NO_CLEAR;

        String notificationTag = String.valueOf(notificationId);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationManager notificationManager = getNotificationManager(context);
            notificationManager.notify(notificationTag, notificationId, notification);
        } else {
            NotificationManagerCompat notificationManagerCompat = getAdaptedOldNotificationManager(context);
            notificationManagerCompat.notify(notificationTag, notificationId, notification);
        }
    }

    public void showCallNotification(Context context, String title, String body,
                                         String acceptButtonText, String rejectButtonText,
                                         String channelID, String soundSource, String iconSource,
                                         String notificationIdString, Boolean isVibrate, Boolean isVideo) {
        Log.i("call plugin", "show call Notification, title:" + title + ",body:" + body +
                ",channelId:" + channelID + ",soundSource:" + soundSource + ",iconSource:" + iconSource +
                ",notificationId:" + notificationIdString + ",isVibrate:" + isVibrate + ",isVideo:" + isVideo);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            wakeUpScreen(context);
        }

        int flags = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = PendingIntent.FLAG_IMMUTABLE;
        }

        CancelReceiver cancelReceiver = new CancelReceiver();
        Intent intentCancel = new Intent(context, cancelReceiver.getClass());
        intentCancel.setAction(Defines.ACTION_CALL_NOTIFICATION_CANCEL);
        PendingIntent cancelPendingIntent = PendingIntent.getBroadcast(context, 0, intentCancel, flags);

        ClickReceiver clickReceiver = new ClickReceiver();
        Intent clickIntent = new Intent(context, clickReceiver.getClass());
        clickIntent.setAction(Defines.ACTION_CALL_NOTIFICATION_CLICK);
        PendingIntent clickPendingIntent = PendingIntent.getBroadcast(context, 0, clickIntent, flags);

        /// avoid head-up notification disappear after a few seconds
        Intent fullscreenIntent = new Intent();
        PendingIntent fullscreenPendingIntent = PendingIntent.getBroadcast(context, 0, fullscreenIntent, flags);

        /// content view
        AcceptReceiver acceptReceiver = new AcceptReceiver();
        Intent acceptIntent = new Intent(context, acceptReceiver.getClass());
        acceptIntent.setAction(Defines.ACTION_CALL_NOTIFICATION_ACCEPT);
        PendingIntent acceptPendingIntent = PendingIntent.getBroadcast(context, 0, acceptIntent, flags);

        RejectReceiver rejectReceiver = new RejectReceiver();
        Intent rejectIntent = new Intent(context, rejectReceiver.getClass());
        rejectIntent.setAction(Defines.ACTION_CALL_NOTIFICATION_REJECT);
        PendingIntent rejectPendingIntent = PendingIntent.getBroadcast(context, 0, rejectIntent, flags);

        RemoteViews contentView = new RemoteViews(context.getPackageName(), R.layout.layout_small_notification);
        contentView.setTextViewText(R.id.tvDecline, rejectButtonText);
        contentView.setTextViewText(R.id.tvAccept, acceptButtonText);
        contentView.setTextViewText(R.id.tvTitle, title);
        contentView.setTextViewText(R.id.tvBody, body);
        contentView.setOnClickPendingIntent(R.id.llAccept, acceptPendingIntent);
        contentView.setOnClickPendingIntent(R.id.llDecline, rejectPendingIntent);
        if (isVideo) {
            contentView.setImageViewResource(R.id.ivAccept, R.drawable.ic_video_accept);
        } else {
            contentView.setImageViewResource(R.id.ivAccept, R.drawable.ic_audio_accept);
        }

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
            builder.setVibrate(new long[]{0, 1000, 500, 1000});
        } else {
            builder.setVibrate(new long[]{0});
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

    public void dismissNotification(Context context, int notificationID) {
        Log.i("call plugin", String.format("dismissNotification, id: %d", notificationID));

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O /*Android 8*/) {
            NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
            notificationManager.cancel(notificationID);
        } else {
            NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            notificationManager.cancel(notificationID);
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

    public String getAppName(Context context) {
        ApplicationInfo applicationInfo = context.getApplicationInfo();
        int stringId = applicationInfo.labelRes;
        return stringId == 0 ? applicationInfo.nonLocalizedLabel.toString() : context.getString(stringId);
    }
}
