package com.quackomatic.sheepskin;


import android.os.Build;
import android.os.Bundle;

import androidx.annotation.RequiresApi;

import java.io.IOException;

import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.quackomatic.sheepskin/tilecache";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @RequiresApi(api = Build.VERSION_CODES.Q)
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("doSomething")) {
                            try {
                                new TileCache().doSomething("/a/path/here");
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }
                    }});
    }
}
