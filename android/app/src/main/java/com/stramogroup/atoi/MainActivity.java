package com.stramogroup.atoi;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.brother.ptouch.sdk.Printer;
import com.brother.ptouch.sdk.PrinterInfo;
import com.brother.ptouch.sdk.LabelInfo;
import com.brother.ptouch.sdk.PrinterStatus;

import android.util.Base64;
import android.util.Log;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "brotherPrinter";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    FlutterView view = getFlutterView();
    view.enableTransparentBackground();

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
          new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                  if (call.method.equals("printImage")) {
                      String imageStr = call.argument("image");
                      byte[] decodedString = Base64.decode(imageStr, Base64.DEFAULT);
                      Bitmap decodedByte = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);
                      if (decodedByte != null) {
                          printImageBrother(decodedByte);
                      }
                  } else {
                      if (call.method.equals("getBattery")) {
                          int batteryLevel = getBatteryLevel();
                          Log.d("battery", batteryLevel+"");
                      }
                  }
              }
          });
  }

  private void printImageBrother(Bitmap bmp) {
        final Printer printer = new Printer();
        // Specify printer
        PrinterInfo settings = printer.getPrinterInfo();
        settings.printerModel = PrinterInfo.Model.PT_P900W;
        settings.port = PrinterInfo.Port.NET;
        settings.ipAddress = "192.168.118.1";

        // Print Settings
        settings.labelNameIndex = LabelInfo.PT.W36.ordinal();
        settings.printMode = PrinterInfo.PrintMode.FIT_TO_PAGE;
        settings.isAutoCut = true;
        printer.setPrinterInfo(settings);

        // Connect, then print
        new Thread(new Runnable() {
            @Override
            public void run() {
                if (printer.startCommunication()) {
                    try {
                        PrinterStatus result = printer.printImage(bmp);
                        if (result.errorCode != PrinterInfo.ErrorCode.ERROR_NONE) {
                            Log.d("TAG", "ERROR - " + result.errorCode);
                        }
                    } catch (Exception e) {
                        Log.d("error", e+"");
                    }
                    printer.endCommunication();
                }
            }
        }).start();
    }

    private int getBatteryLevel() {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return batteryLevel;
    }
}
