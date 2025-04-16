#include <jni.h>
#include <android/bitmap.h>
#include <android/log.h>
#include <string>

// Log tag for native code
#define LOG_TAG "QRCodeNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Bitmap info structure
typedef struct {
    uint32_t width;
    uint32_t height;
    uint32_t stride;
    int32_t format;
    uint8_t* pixels;
} BitmapInfo;

// Get info from Android Bitmap
bool getBitmapInfo(JNIEnv* env, jobject bitmap, BitmapInfo* info) {
    if (AndroidBitmap_getInfo(env, bitmap, &info->format, &info->width, 
                              &info->height, &info->stride) < 0) {
        LOGE("Failed to get bitmap info");
        return false;
    }

    // Check format - we only handle ARGB_8888
    if (info->format != ANDROID_BITMAP_FORMAT_RGBA_8888) {
        LOGE("Unsupported bitmap format: %d, only ARGB_8888 is supported", info->format);
        return false;
    }

    // Lock the bitmap pixels
    if (AndroidBitmap_lockPixels(env, bitmap, (void**)&info->pixels) < 0) {
        LOGE("Failed to lock bitmap pixels");
        return false;
    }

    return true;
}

// Release bitmap lock
void releaseBitmap(JNIEnv* env, jobject bitmap) {
    AndroidBitmap_unlockPixels(env, bitmap);
}

// Process the QR code bitmap
void processBitmap(BitmapInfo* info) {
    // This is where you would implement your bitmap processing logic
    // For example, analyze the QR code, extract data, etc.
    
    // For demonstration, let's just log some info about the bitmap
    LOGI("Processing bitmap: %dx%d pixels", info->width, info->height);
    
    // Log a few sample pixel values (RGBA format)
    for (int y = 0; y < std::min(3u, info->height); y++) {
        for (int x = 0; x < std::min(3u, info->width); x++) {
            int offset = y * info->stride + x * 4;
            uint8_t r = info->pixels[offset];
            uint8_t g = info->pixels[offset + 1];
            uint8_t b = info->pixels[offset + 2];
            uint8_t a = info->pixels[offset + 3];
            LOGI("Pixel at (%d, %d): RGBA(%d, %d, %d, %d)", x, y, r, g, b, a);
        }
    }
}

// JNI function implementation
extern "C"
JNIEXPORT void JNICALL 
Java_com_example_qrcodegenerator_BitmapProcessorActivity_sendBitmapToNativeCode(
    JNIEnv* env, jobject thiz, jobject bitmap) {
    
    LOGI("Native method called: sendBitmapToNativeCode");
    
    // Get bitmap info
    BitmapInfo info;
    if (!getBitmapInfo(env, bitmap, &info)) {
        return;  // Error already logged
    }
    
    // Process the bitmap
    processBitmap(&info);
    
    // Release bitmap
    releaseBitmap(env, bitmap);
    
    LOGI("Native method completed");
}