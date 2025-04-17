package com.example.print_demo_zebra;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;
import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.graphics.internal.ZebraImageAndroid;
import com.zebra.sdk.printer.PrinterLanguage;
import com.zebra.sdk.printer.ZebraPrinter;
import com.zebra.sdk.printer.ZebraPrinterFactory;
import com.zebra.sdk.printer.discovery.BluetoothDiscoverer;
import com.zebra.sdk.printer.discovery.DiscoveredPrinter;
import com.zebra.sdk.printer.discovery.DiscoveryHandler;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity implements DiscoveryHandler {

    private final String channel = "com.example.print_demo_zebra/zebra";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothSocket bluetoothSocket;
    private Connection connection;
    private List<String> macAddresses = new ArrayList<String>();
    private ArrayList<DiscoveredPrinter> printerItems;
    private ArrayList<Map<String,String>> printerSettings;
    private String printCode2="^XA~TA000~JSN^LT0^MNN^MTD^PON^PMN^LH0,0^JMA^PR3,3~SD10^JUS^LRN^CI0^XZ\n" +
            "^XA\n" +
            "^MMT\n" +
            "^PW400\n" +
            "^LL0240\n" +
            "^LS0\n" +
            "^BY2,3,68^FT10,80^BCN,,Y,N\n" +
            "^FD>;123456789012^FS\n" +
            "^FT56,151^A0N,49,48^FH\\^FDText^FS\n" +
            "^FT193,208^A0N,82,81^FH\\^FDText^FS\n" +
            "^BY1,3,48^FT258,116^BCN,,Y,N\n" +
            "^FD>;123456789012^FS\n" +
            "^PQ1,0,1,Y^XZ";
    private QrCodeGenerator qrCodeGenerator;
    private Bitmap generatedQrCode;
    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                if (device != null && device.getBondState() != BluetoothDevice.BOND_BONDED) {
                    macAddresses.add(device.getAddress());
                }
            }
        }
    };
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        qrCodeGenerator = new QrCodeGenerator(this);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),channel).setMethodCallHandler(
                ((call, result) -> {
                    if(call.method.equals("discoverPrinters")){
                        macAddresses.clear();
                        this.DiscoverBluetoothPrinterResultList(new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success(macAddresses);
                            }

                            @Override
                            public void onError(Exception e) {
                                    result.error("PRINT FETCH",e.getMessage(),null);
                            }
                        });
                    }
                    else if(call.method.equals("createConnect")){
                        String macAddress = call.argument("macAddress");
                        this.createConnection(macAddress,new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success("success");
                            }

                            @Override
                            public void onError(Exception e) {
                                result.error("PRINT",e.getMessage(),null);
                            }
                        });
                    }
                    else if(call.method.equals("printImage")){
                        byte[] imageByte = call.argument("imageByte");
                        this.printImage(imageByte,new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success("success");
                            }

                            @Override
                            public void onError(Exception e) {
                                result.error("PRINT",e.getMessage(),null);
                            }
                        });
                    }
                    else if(call.method.equals("printQrImage")){
                        String qrCode = call.argument("qrCode");
                        this.generateQrCode(qrCode,new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success("success");
                            }

                            @Override
                            public void onError(Exception e) {
                                result.error("PRINT",e.getMessage(),null);
                            }
                        });
                    }
                    else if(call.method.equals("print")){
                        String text = call.argument("text");
                        this.print(text,new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success("success");
                            }

                            @Override
                            public void onError(Exception e) {
                                result.error("PRINT",e.getMessage(),null);
                            }
                        });
                    }
                    else if (call.method.equals("disConnect")){
                        disConnect(new PrintCallback() {
                            @Override
                            public void onSuccess() {
                                result.success("success");
                            }
                            @Override
                            public void onError(Exception e) {
                                System.out.println("CONNECTION_ERROR: " + e.getMessage());
                                result.error("DISCONNECTION_ERROR", e.getMessage(), null);
                            }
                        });
                    }
                })
        );
    }
    private void createConnection(String macAddress, PrintCallback callback) {
        new Thread(() -> {
            Looper.prepare();
            try {
                connection = new BluetoothConnection(macAddress);
                connection.open();
                if (!(connection.isConnected())){
                    throw new Exception("Printer not connected");
                }
                callback.onSuccess();
            } catch (Exception e) {
                callback.onError(e);  // Pass error to callback
            }
        }).start();
    }



    void printImage(byte[] imageByte,PrintCallback printCallback){
        new Thread(()->{
            Looper.prepare();
            try{
                if (!(connection.isConnected())){
                    throw new Exception("Printer not connected");
                }
                Bitmap bitmap = BitmapFactory.decodeByteArray(imageByte, 0, imageByte.length);
                ZebraImageAndroid zebraImage = new ZebraImageAndroid(bitmap);
                ZebraPrinter printer = ZebraPrinterFactory.getInstance(PrinterLanguage.ZPL, connection);
                printer.printImage(zebraImage, 0, 0, bitmap.getWidth(), bitmap.getHeight(), false);
                printCallback.onSuccess();
            }
            catch (Exception e){
                printCallback.onError(e);
            }
        }
        ).start();
    }
    void printQrImage(Bitmap bitmapValue,PrintCallback printCallback){
        new Thread(()->{
            Looper.prepare();
            try{
                if (!(connection.isConnected())){
                    throw new Exception("Printer not connected");
                }
                ZebraImageAndroid zebraImage = new ZebraImageAndroid(bitmapValue);
                ZebraPrinter printer = ZebraPrinterFactory.getInstance(PrinterLanguage.ZPL, connection);
                printer.printImage(zebraImage, 0, 0, bitmapValue.getWidth(), bitmapValue.getHeight(), false);
                printCallback.onSuccess();
            }
            catch (Exception e){
                printCallback.onError(e);
            }
        }
        ).start();
    }

    void configurePrinter(double width,double height,PrintCallback printCallback){
        int labelWidthDots = (int) (width*203);  // 4 inches
        int labelLengthDots = (int)(height*203); //2 inches
        String setWidth = "! U1 setvar \"media.width\" \"" + labelWidthDots + "\"\n";
        String setLength = "! U1 setvar \"ezpl.media_length\" \"" + labelLengthDots + "\"\n";
        new Thread(()->{
            Looper.prepare();
            try{
                if (!(connection.isConnected())){
                    throw new Exception("Printer not connected");
                }
                ZebraPrinter printer = ZebraPrinterFactory.getInstance(PrinterLanguage.ZPL, connection);
                connection.write(setWidth.getBytes());
                printCallback.onSuccess();
            }
            catch(Exception e){
                printCallback.onError(e);
            }
        });
    }
    void print(String text,PrintCallback printCallback){
        new Thread(()->{
            Looper.prepare();
            try{
                if (!(connection.isConnected())){
                    throw new Exception("Printer not connected");
                }
                ZebraPrinter printer = ZebraPrinterFactory.getInstance(PrinterLanguage.ZPL, connection);
                printer.sendCommand("^XA~TA000~JSN^LT0^MNN^MTD^PON^PMN^LH0,0^JMA^PR3,3~SD10^JUS^LRN^CI0^XZ\n" +
                        "^XA\n" +
                        "^MMT\n" +
                        "^PW623\n" +
                        "^LL0240\n" +
                        "^LS0\n" +
                        "^BY4,3,89^FT610,52^BCI,,Y,N\n" +
                        "^FD>;123456789012^FS\n" +
                        "^FT317,191^A0I,39,38^FH\\^FD"+text+" ^FS\n" +
                        "^FT317,143^A0I,39,38^FH\\^FD          sample print^FS\n" +
                        "^PQ1,0,1,Y^XZ");
//                printer.sendCommand(printCode2);
                printCallback.onSuccess();
            }
            catch (Exception e){
                printCallback.onError(e);
            }
        }
        ).start();

    }

    private void disConnect(PrintCallback callback){
        try {
            connection.close();
            connection = null;
            callback.onSuccess();
        } catch (ConnectionException e) {
            callback.onError(e);
        }
    }
    private void generateQrCode(String qrCode,PrintCallback printCallback) {
        try {
            // Generate QR code with company logo overlay
            qrCodeGenerator.generateQrCodeWithLogo(qrCode, new QrCodeGenerator.QrCodeGeneratorCallback() {
                @Override
                public void onQrCodeGenerated(Bitmap qrCodeBitmap) {
                    runOnUiThread(() -> {
                        if (qrCodeBitmap != null) {
                            generatedQrCode = qrCodeBitmap;
                            printQrImage(generatedQrCode, printCallback);
                        } else {
                           printCallback.onError(new Exception("Issues found"));
                        }
                    });
                }
            });
        }
        catch (Exception e){
            printCallback.onError(e);
        }
    }
    void DiscoverBluetoothPrinterResultList(PrintCallback printCallback){
        printerItems = new ArrayList<DiscoveredPrinter>();
        printerSettings = new ArrayList<Map<String,String>>();
        new Thread(()->{
            try {
                BluetoothDiscoverer.findPrinters(MainActivity.this, new DiscoveryHandler() {
                    @Override
                    public void foundPrinter(DiscoveredPrinter printer) {
                        runOnUiThread(
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        printerItems.add(printer);
                                        Log.e("printer",printer.address);
                                        printerSettings.add(printer.getDiscoveryDataMap());
                                    }
                                }
                        );
                    }

                    @Override
                    public void discoveryFinished() {
                        runOnUiThread(
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        if (printerItems.isEmpty()) {
                                            Log.e("BluetoothDiscovery", "No printers found");
                                        }
                                        else {
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                                printerItems.forEach(value-> macAddresses.add(value.address));
                                            }
                                        }
                                        printCallback.onSuccess();
                                    }
                                }
                        );
                    }

                    @Override
                    public void discoveryError(String s) {
                        printCallback.onError(new Exception(s));
                    }
                });
            }
            catch (ConnectionException e){
                printCallback.onError(e);
            }

        }).start();
    }

    @Override
    public void foundPrinter(DiscoveredPrinter discoveredPrinter) {

    }

    @Override
    public void discoveryFinished() {

    }

    @Override
    public void discoveryError(String s) {

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        this.disConnect(new PrintCallback() {
            @Override
            public void onSuccess() {
                Log.e("printer","connection closed");
            }

            @Override
            public void onError(Exception e) {
                Log.e("printer","connection error");

            }
        });
    }

    public interface PrintCallback {
        void onSuccess();
        void onError(Exception e);
    }
}
