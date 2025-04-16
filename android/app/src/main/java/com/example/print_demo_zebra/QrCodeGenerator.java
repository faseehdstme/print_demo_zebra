package com.example.print_demo_zebra;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;

import androidx.core.content.ContextCompat;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class QrCodeGenerator {

    private final Context context;
    private final Executor executor;
    private final Handler mainHandler;

    public QrCodeGenerator(Context context) {
        this.context = context;
        this.executor = Executors.newSingleThreadExecutor();
        this.mainHandler = new Handler(Looper.getMainLooper());
    }

    public interface QrCodeGeneratorCallback {
        void onQrCodeGenerated(Bitmap bitmap);
    }

    public void generateQrCodeWithLogo(String content, QrCodeGeneratorCallback callback) {
        executor.execute(() -> {
            try {
                // Generate QR code
                Bitmap qrCodeBitmap = generateQRCode(content, 200);

                // Add logo overlay
                Bitmap finalBitmap = addLogoToQrCode(qrCodeBitmap);

                // Return result on main thread
                mainHandler.post(() -> callback.onQrCodeGenerated(finalBitmap));
            } catch (Exception e) {
                e.printStackTrace();
                mainHandler.post(() -> callback.onQrCodeGenerated(null));
            }
        });
    }

    private Bitmap generateQRCode(String content, int size) throws WriterException {
        // Set QR code parameters
        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.H); // Higher error correction for logo overlay
        hints.put(EncodeHintType.MARGIN, 1);

        // Generate QR code bit matrix
        BitMatrix bitMatrix = new MultiFormatWriter().encode(
                content, BarcodeFormat.QR_CODE, size, size, hints);

        // Convert to bitmap
        int width = bitMatrix.getWidth();
        int height = bitMatrix.getHeight();
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);

        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                bitmap.setPixel(x, y, bitMatrix.get(x, y) ? Color.BLACK : Color.WHITE);
            }
        }

        return bitmap;
    }

    private Bitmap addLogoToQrCode(Bitmap qrCodeBitmap) {
        // Get the company logo (you would replace R.drawable.company_logo with your actual resource)
        Drawable logoDrawable = ContextCompat.getDrawable(context, R.drawable.company_logo);
        if (logoDrawable == null) {
            // If logo not available, create a simple placeholder
            Bitmap logoBitmap = Bitmap.createBitmap(100, 100, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(logoBitmap);
            Paint paint = new Paint();
            paint.setColor(ContextCompat.getColor(context, R.color.primary));
            canvas.drawRect(0, 0, 100, 100, paint);
            logoDrawable = new BitmapDrawable(context.getResources(), logoBitmap);
        }

        // Convert logo to bitmap and scale it
        Bitmap logoBitmap;
        if (logoDrawable instanceof BitmapDrawable) {
            logoBitmap = ((BitmapDrawable) logoDrawable).getBitmap();
        } else {
            logoBitmap = Bitmap.createBitmap(
                    logoDrawable.getIntrinsicWidth(),
                    logoDrawable.getIntrinsicHeight(),
                    Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(logoBitmap);
            logoDrawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
            logoDrawable.draw(canvas);
        }

        // Scale logo to appropriate size (20% of QR code size)
        int logoSize = qrCodeBitmap.getWidth() / 5;
        logoBitmap = Bitmap.createScaledBitmap(logoBitmap, logoSize, logoSize, true);

        // Create a copy of the QR code bitmap
        Bitmap combinedBitmap = qrCodeBitmap.copy(Bitmap.Config.ARGB_8888, true);
        Canvas canvas = new Canvas(combinedBitmap);

        // Draw logo in the center of the QR code
        int centerX = (qrCodeBitmap.getWidth() - logoSize) / 2;
        int centerY = (qrCodeBitmap.getHeight() - logoSize) / 2;

        // Draw white circular background for the logo
        Paint paint = new Paint();
        paint.setColor(Color.WHITE);
        canvas.drawCircle(
                qrCodeBitmap.getWidth() / 2f,
                qrCodeBitmap.getHeight() / 2f,
                logoSize / 1.8f,
                paint);

        // Draw the logo
        canvas.drawBitmap(logoBitmap, centerX, centerY, null);

        return combinedBitmap;
    }
}