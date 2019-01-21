package org.julianyang.chinesetextloader;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        final Context context = this;

        new MethodChannel(getFlutterView(), "chinesetextloader").setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (!call.method.equals("openPlecoClipboard")) {
                            return;
                        }

                        Intent intent = new Intent(Intent.ACTION_MAIN)
                                .setPackage("com.pleco.chinesesystem")
                                .setClassName(
                                        "com.pleco.chinesesystem",
                                        "com.pleco.chinesesystem.PlecoDocumentReaderActivity")
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        Log.i("chinesetextloader/openPleco", "Launching Intent: " + intent);
                        context.startActivity(intent);
                        result.success("succeeded!");
                    }
                }
        );
    }
}
