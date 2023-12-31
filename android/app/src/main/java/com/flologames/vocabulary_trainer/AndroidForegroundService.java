package com.flologames.vocabulary_trainer;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;

public class AndroidForegroundService extends Service {
    Intent dialogIntent;
    int unlockCountToOpenApp = 5;
    int unlocksCount = 0;
    int totalUnlocksCount = 0;
    DeviceUnlockManager deviceUnlockManager;
    private static AndroidForegroundService instance;
    public static AndroidForegroundService getInstance(){
        return instance;
    }
    public void deviceUnlocked(){
        totalUnlocksCount++;
        unlocksCount++;
        if(unlocksCount < unlockCountToOpenApp){
            return;
        }
        dialogIntent = new Intent(this, MainActivity.class);

        stopService(dialogIntent);

        dialogIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        dialogIntent.putExtra("totalUnlockCount", totalUnlocksCount); // Replace "key" and "value" with your actual data

        startActivity(dialogIntent);
        //unlocksCount = 0;
    }
    public int getUnlockCountToOpenApp(){
        Log.i("getUnlockCountToOpenApp", String.valueOf(unlockCountToOpenApp));
        return unlockCountToOpenApp;
    }
    public void setUnlockCountToOpenApp(int value){
        unlockCountToOpenApp = value;
    }
    public int getUnlockCount(){
        return unlocksCount;
    }
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        instance = this;
        // Handle service initialization and logic here
        deviceUnlockManager = new DeviceUnlockManager();
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_USER_PRESENT);
        registerReceiver(deviceUnlockManager, filter);




        final String CHANNEL_ID = "ForegroundService ID";

        NotificationChannel channel = new NotificationChannel(
                CHANNEL_ID,
                CHANNEL_ID,
                NotificationManager.IMPORTANCE_LOW
        );

        getSystemService(NotificationManager.class).createNotificationChannel(channel);
        Notification.Builder notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentText("Service is running")
                .setContentTitle("Service enabled")
                .setSmallIcon(R.drawable.launch_background);

        startForeground(1001, notification.build());


        return super.onStartCommand(intent, flags, startId);
    }
    public void vocabularyDone(){
        unlocksCount = 0;
    }
    @Override
    public void onDestroy() {
        if(deviceUnlockManager != null){
            unregisterReceiver(deviceUnlockManager);
        }
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
