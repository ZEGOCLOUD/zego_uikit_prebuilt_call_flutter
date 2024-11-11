package com.zegocloud.uikit.call_plugin.notification;

import android.content.Context;
import android.util.Log;

import android.content.BroadcastReceiver;
import android.content.Intent;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.zegocloud.uikit.call_plugin.Defines;

public class AcceptReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.i("call plugin", "accept receiver, Received broadcast " + intent.getAction());
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }
}
