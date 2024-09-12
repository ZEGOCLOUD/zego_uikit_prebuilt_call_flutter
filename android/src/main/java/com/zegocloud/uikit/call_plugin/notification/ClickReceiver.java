package com.zegocloud.uikit.call_plugin.notification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.zegocloud.uikit.call_plugin.Defines;

public class ClickReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        int notificationID = intent.getIntExtra(Defines.FLUTTER_PARAM_NOTIFICATION_ID, -1);
        Log.i("call plugin", "click receiver, Received broadcast " + intent.getAction() + String.format(", notification id: %d", notificationID));

        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }
}
