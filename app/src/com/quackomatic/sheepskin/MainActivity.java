package com.quackomatic.sheepskin;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.*;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.quackomatic.sheepskin/tileCache";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        if (call.method.equals("doThing")) {
                            String greetings = helloFromNativeCode();
                            result.success(greetings);
                        }
                    }});
    }
    private String helloFromNativeCode() {
        return "Hello from Native Android Code";
    }
}