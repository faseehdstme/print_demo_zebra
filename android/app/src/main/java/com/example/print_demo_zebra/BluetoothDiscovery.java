package com.example.print_demo_zebra;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.printer.discovery.BluetoothDiscoverer;
import com.zebra.sdk.printer.discovery.DiscoveredPrinter;
import com.zebra.sdk.printer.discovery.DiscoveryHandler;

import java.util.ArrayList;
import java.util.Map;

public class BluetoothDiscovery implements DiscoveryHandler {
    private ArrayList<DiscoveredPrinter> printerItems;
    private ArrayList<Map<String, String>> printerSettings;
    private Handler mainHandler;
    private Context context;

    public BluetoothDiscovery(Context context, Handler mainHandler) {
        this.context = context;
        this.mainHandler = mainHandler;  // Pass Handler to post to UI thread
    }

    public void findPrinters() {
        printerItems = new ArrayList<>();
        printerSettings = new ArrayList<>();

        new Thread(() -> {
            Looper.prepare();
            try {
                BluetoothDiscoverer.findPrinters(context, BluetoothDiscovery.this);
            } catch (ConnectionException e) {
                Log.e("BluetoothDiscovery", "Error discovering printers", e);
            } finally {
                Looper.myLooper().quit();
            }
        }).start();
    }

    @Override
    public void foundPrinter(final DiscoveredPrinter printer) {
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                addPrinterItem(printer);
            }
        });
    }

    private void addPrinterItem(DiscoveredPrinter p) {
        printerItems.add(p);
        Log.e("printer", p.address);
        printerSettings.add(p.getDiscoveryDataMap());
    }

    @Override
    public void discoveryFinished() {
        mainHandler.post(new Runnable() {
            @Override
            public void run() {
                // Handle UI updates after discovery finishes
            }
        });
    }

    @Override
    public void discoveryError(String message) {
        Log.d("discoveryError: ", message);
    }
}
