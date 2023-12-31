package com.flologames.vocabulary_trainer;


import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.widget.Toast;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@Keep
public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    private final String testChannelName = "testChannel";
    private final String testMethodName = "testMethod";
    private static final String getUnlockCountMethodName= "getUnlockCount";
    private  static final String startForegroundService = "startForegroundService";
    private static final String endForegroundService = "endForegroundService";
    private static final String isForegroundServiceRunning = "isForegroundServiceRunning";
    private static final String setUnlockCountToOpenApp = "setUnlockCountToOpenApp";
    private static final String getUnlockCountToOpenApp = "getUnlockCountToOpenApp";
    private static final String vocabularyDone = "vocabularyDone";
    private static final String installApk = "installApk";
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
            result.success(isForegroundServiceRunning());
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
        } else if(call.method.contentEquals(vocabularyDone)){
            AndroidForegroundService foregroundService = AndroidForegroundService.getInstance();
            if(foregroundService == null) {
                result.success(false);
            } else {
                foregroundService.vocabularyDone();
                result.success(true);
            }
        } else if(call.method.contentEquals(installApk)){
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;

            String filePath = "";
            try {
                filePath = arguments.get("path").toString();

            } catch (Exception e){
                e.printStackTrace();
            }

            File file = new File(filePath);

            if (file.exists()) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                Uri apkUri = FileProvider.getUriForFile(this, getApplicationContext().getPackageName() + ".provider", file);
                intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
                intent.setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent);

                result.success(true);
            } else {
                // Handle the case where the APK file doesn't exist
                result.success(false);
            }
        } else {
            result.notImplemented();
        }
    }
}
