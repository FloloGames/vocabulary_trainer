package com.flologames.vocabulary_trainer;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import io.flutter.Log;

public class DeviceUnlockManager extends BroadcastReceiver {
    //FlutterAppLauncher flutterAppLauncher = new FlutterAppLauncher();

    //private FlutterEngine flutterEngine;

    @Override
    public void onReceive(Context context, Intent intent) {
        if(intent.getAction().equals(Intent.ACTION_USER_PRESENT)){
            Log.i("DeviceUnlockManager", "Phone got unlocked!");

            AndroidForegroundService foregroundService = AndroidForegroundService.getInstance();
            if(foregroundService == null){
                Log.e("DeviceUnlockManager","foregroundService is null");
                return;
            }

            foregroundService.deviceUnlocked();
        }
    }
}
