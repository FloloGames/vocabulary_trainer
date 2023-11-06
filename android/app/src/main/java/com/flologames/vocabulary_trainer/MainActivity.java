package com.flologames.vocabulary_trainer


import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    private final String testChannelName = "testChannel";
    private final String testMethodName = "testMethod";
    private static final String getUnlockCountMethodName= "getUnlockCount";
    private  static final String startForegroundService = "startForegroundService";
    private static final String endForegroundService = "endForegroundService";
    private static final String isForegroundServiceRunning = "isForegroundServiceRunning";
    private static final String setUnlockCountToOpenApp = "setUnlockCountToOpenApp";
    private static final String getUnlockCountToOpenApp = "getUnlockCountToOpenApp";
    private static MethodChannel testMethodChannel;

    Intent foregroundServiceIntent;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        //GeneratedPluginRegistrant.registerWith(flutterEngine);

        testMethodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), testChannelName);

        testMethodChannel.setMethodCallHandler(this);
    }


    private  boolean isForegroundServiceRunning(){
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for(ActivityManager.RunningServiceInfo service: activityManager.getRunningServices(Integer.MAX_VALUE)){
            if(AndroidForegroundService.class.getName().equals(service.service.getClassName())){
                return true;
            }
        }
        return false;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if(call.method.contentEquals(testMethodName)){
            Toast.makeText(this, "TestMethod works!", Toast.LENGTH_LONG).show();
        } else if(call.method.contentEquals(getUnlockCountMethodName)){
            Toast.makeText(this, "TestMethod works!", Toast.LENGTH_LONG).show();

            AndroidForegroundService androidForegroundService = AndroidForegroundService.getInstance();

            if(androidForegroundService == null){
                result.success(-1);
            } else {
                int unlockCount = androidForegroundService.getUnlockCount();
                result.success(unlockCount);
            }
        } else if(call.method.contentEquals(startForegroundService)){
            if(!isForegroundServiceRunning()) {
                foregroundServiceIntent = new Intent(this, AndroidForegroundService.class);

                startForegroundService(foregroundServiceIntent);
            }
            result.success(isForegroundServiceRunning());
        } else if(call.method.contentEquals(endForegroundService)){
            if(isForegroundServiceRunning()){
                stopService(foregroundServiceIntent);
            }
        } else if(call.method.contentEquals(isForegroundServiceRunning)){
            result.success(isForegroundServiceRunning());
        } else if(call.method.contentEquals(setUnlockCountToOpenApp)){
            AndroidForegroundService foregroundService = AndroidForegroundService.getInstance();
            if(foregroundService == null) {
                result.success(false);
            } else {
                Map<String, Object> arguments = (Map<String, Object>) call.arguments;

                int count = -1;
                try {
                    count = (int) arguments.get("count");

                } catch (Exception e){
                    e.printStackTrace();
                }

                foregroundService.setUnlockCountToOpenApp(count);
                result.success(true);
            }
        } else if(call.method.contentEquals(getUnlockCountToOpenApp)){
            AndroidForegroundService foregroundService = AndroidForegroundService.getInstance();
            if(foregroundService == null) {
                Log.i("getUnlockCountToOpenApp", String.valueOf(-1));
                result.success(-1);
            } else {
                int count = foregroundService.getUnlockCountToOpenApp();
                Log.i("getUnlockCountToOpenApp", String.valueOf(count));
                result.success(count);
            }
        } else {
            result.notImplemented();
        }
    }
}
