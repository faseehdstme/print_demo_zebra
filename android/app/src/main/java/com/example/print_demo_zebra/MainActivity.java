package com.example.print_demo_zebra;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.pdf.PdfRenderer;
import android.net.Uri;
import android.os.Build;
import android.os.Looper;
import android.os.ParcelFileDescriptor;
import android.provider.DocumentsContract;
import android.provider.MediaStore;
import android.provider.OpenableColumns;
import android.util.Log;

import androidx.annotation.NonNull;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;
import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.graphics.internal.ZebraImageAndroid;
import com.zebra.sdk.printer.PrinterLanguage;
import com.zebra.sdk.printer.PrinterStatus;
import com.zebra.sdk.printer.SGD;
import com.zebra.sdk.printer.ZebraPrinter;
import com.zebra.sdk.printer.ZebraPrinterFactory;
import com.zebra.sdk.printer.ZebraPrinterLanguageUnknownException;
import com.zebra.sdk.printer.discovery.BluetoothDiscoverer;
import com.zebra.sdk.printer.discovery.DiscoveredPrinter;
import com.zebra.sdk.printer.discovery.DiscoveryHandler;

import java.io.File;
import java.io.IOException;
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
    int pdfWidth;
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
                    else if(call.method.equals("pdfPrint")){

                        String uriPath = call.argument("fileUri");
                        Uri finalUri = Uri.parse(uriPath);
                        try {
                            String fileName = getPDFName(finalUri);
                            String filePath = getPDFPath(finalUri);
                            if (filePath != null){
                                sendPrint(filePath);
                            }
                            else {
                                throw new RuntimeException("File not found");
                            }
                        }
                        catch (Exception e){
                            result.error("PrintPDF",e.getMessage(),null);
                        }
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
                String printerModel = SGD.GET("device.host_identification",connection).substring(0,5);
                Log.e("printer",printerModel);
                ZebraImageAndroid zebraImage = new ZebraImageAndroid(bitmapValue);
                ZebraPrinter printer = ZebraPrinterFactory.getInstance(PrinterLanguage.ZPL, connection);
                printer.sendCommand("^XA\n" +
                        "^PW203\n" +
                        "^LL203\n" +
                        "^XZ");

                printer.printImage(zebraImage, 0, 0, bitmapValue.getWidth(), bitmapValue.getHeight(), false);
                printCallback.onSuccess();
            }
            catch (Exception e){
                printCallback.onError(e);
            }
        }
        ).start();
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

    //PDF print
    private boolean isPDFEnabled(Connection connection) {
        try {
            String printerInfo = SGD.GET("apl.enable", connection);
            if (printerInfo.equals("pdf")) {
                return true;
            }
        } catch (ConnectionException e) {
            e.printStackTrace();
        }

        return false;
    }

    public String getPDFName(Uri fileUri) {
        String fileString = fileUri.toString();
        File myFile = new File(fileString);
        String fileName = null;

        /*if (fileString.startsWith("content://")) {
            Cursor cursor = null;
            try {
                cursor = getActivity().getContentResolver().query(fileUri, null, null, null, null);
                if (cursor != null && cursor.moveToFirst()) {
                    fileName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
                }
            } finally {
                cursor.close();
            }
        } else */if (fileString.startsWith("file://")) {
            fileName = myFile.getName();
        }
        return fileName;
    }

    // Uses the Uri to obtain the path to the file.
    public String getPDFPath(Uri fileUri) {
        if ("file".equalsIgnoreCase(fileUri.getScheme())) {
            return fileUri.getPath();
        }
        String selection = null;
        String[] selectionArgs = null;

        final String id = DocumentsContract.getDocumentId(fileUri);
        try {
            if (id.length() < 15) {
                fileUri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.valueOf(id));
            } else if (id.substring(0,7).equals("primary")) {
                String endPath = id.substring(8);
                String fullPath = "/sdcard/" + endPath;
                return fullPath;
            } else if (!id.substring(0,1).equals("/")) {
                boolean pathStarted = false;
                String path = "/sdcard/";

                for (char c : id.toCharArray()) {
                    if (pathStarted) {
                        path = path + c;
                    }
                    if (c == ':') {
                        pathStarted = true;
                    }
                }
                return path;
            } else {
                return id;
            }
        } catch (NumberFormatException e) {
            Log.e("Exc",e.getMessage(),null);
            e.printStackTrace();
//            String snackbarmsg = mainActivity.getString(R.string.wrong_firmware);
//            mainActivity.showSnackbar(snackbarmsg);
        }

        if ("content".equalsIgnoreCase(fileUri.getScheme())) {
            String[] projection = {
                    MediaStore.Files.FileColumns.DATA
            };
            Cursor cursor = null;
            try {
                cursor = getApplicationContext().getContentResolver()
                        .query(fileUri, projection, selection, selectionArgs, null);
                int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
                if (cursor.moveToFirst()) {
                    return cursor.getString(column_index);
                }
            } catch (Exception e) {
            }
        } else if ("file".equalsIgnoreCase(fileUri.getScheme())) {
            return fileUri.getPath();
        }
        return null;
    }

    // Returns the width of the page in inches for scaling later
    // PdfRenderer is only available for devices running Android Lollipop or newer
    private Integer getPageWidth( Uri fileUri) throws IOException {
        final ParcelFileDescriptor pfdPdf = getApplicationContext().getContentResolver().openFileDescriptor(
                fileUri, "r");

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            PdfRenderer pdf = new PdfRenderer(pfdPdf);
            PdfRenderer.Page page = pdf.openPage(0);
            int pixWidth = page.getWidth();
            int inWidth = pixWidth / 72;
            pdfWidth = inWidth;
            return inWidth;
        }
        else {
            pdfWidth=0;
        }

        return null;
    }

    private Boolean checkPrinterStatus(ZebraPrinter printer,String filePath) {
        try {
            PrinterStatus printerStatus = printer.getCurrentStatus();
            if (printerStatus.isReadyToPrint && filePath != null) {
                return true;
            }
        } catch (ConnectionException e) {
            e.printStackTrace();
        }
        return false;
    }

    //If there is an issue with the printer, this IDs the most common issues and tells the user
    private void showPrinterStatus(ZebraPrinter printer) {
        String snackbarMsg = "";
        try {
            PrinterStatus printerStatus = printer.getCurrentStatus();
            if (printerStatus.isReadyToPrint) {
//                snackbarMsg = mainActivity.getString(R.string.ready_to_print);
            } else if (printerStatus.isPaused) {
//                snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.printer_paused);
            } else if (printerStatus.isHeadOpen) {
//                snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.head_open);
            } else if (printerStatus.isPaperOut) {
//                snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.paper_out);
            } else {
//                snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.cannot_print);
            }

//            mainActivity.showSnackbar(snackbarMsg);

        } catch (ConnectionException e) {
            e.printStackTrace();
//            snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.no_printer);
//            mainActivity.showSnackbar(snackbarMsg);
        }
    }

    // Sets the scaling on the printer and then sends the pdf file to the printer
    private void sendPrint(String filePath) {
        String snackbarMsg = "";
        new Thread(()->{
            Looper.prepare();
        try {
            if (!(connection.isConnected())){
                throw new RuntimeException("Printer not connected");
            }
            ZebraPrinter printerValue = ZebraPrinterFactory.getInstance(connection);

            boolean isReady = checkPrinterStatus(printerValue,filePath);
            String scale = scalePrint(connection);

            SGD.SET("apl.settings",scale,connection);

            if (isReady) {
                if (filePath != null) {
                    printerValue.sendFileContents(filePath);
                } else {
                    throw new RuntimeException("Printer not ready");
//                    snackbarMsg = this.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.no_pdf_selected);
//                    mainActivity.showSnackbar(snackbarMsg);
                }
            } else {
                showPrinterStatus(printerValue);
            }

        } catch (Exception e) {
            e.printStackTrace();
//            snackbarMsg = mainActivity.getString(R.string.print_failed) + " " + mainActivity.getString(R.string.no_printer);
//            mainActivity.showSnackbar(snackbarMsg);
        }
        }
        ).start();
    }

    // Takes the size of the pdf and the printer's maximum size and scales the file down
    private String scalePrint (Connection connection) throws ConnectionException{
        int fileWidth =pdfWidth ;
        String scale = "dither scale-to-fit";

        if (fileWidth != 0) {
            String printerModel = SGD.GET("device.host_identification",connection).substring(0,5);
            double scaleFactor;

            if (printerModel.equals("iMZ22")||printerModel.equals("QLn22")||printerModel.equals("ZD410")) {
                scaleFactor = 2.0/fileWidth*100;
            } else if (printerModel.equals("iMZ32")||printerModel.equals("QLn32")||printerModel.equals("ZQ510")) {
                scaleFactor = 3.0/fileWidth*100;
            } else if (printerModel.equals("QLn42")||printerModel.equals("ZQ521")||
                    printerModel.equals("ZD420")||printerModel.equals("ZD500")||
                    printerModel.equals("ZT220")||printerModel.equals("ZT230")||
                    printerModel.equals("ZT410")) {
                scaleFactor = 4.0/fileWidth*100;
            } else if (printerModel.equals("ZT420")) {
                scaleFactor = 6.5/fileWidth*100;
            } else {
                scaleFactor = 100;
            }

            scale = "dither scale=" + (int) scaleFactor + "x" + (int) scaleFactor;
        }

        return scale;
    }
}
