package com.danielpinzaru.flutter_screenshot_detector

import android.app.Activity
import android.content.ContentResolver
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

/** FlutterScreenshotDetectorPlugin */
class FlutterScreenshotDetectorPlugin :
    FlutterPlugin,
    EventChannel.StreamHandler,
    ActivityAware {
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null
    private var activity: Activity? = null
    private var contentResolver: ContentResolver? = null
    private var observer: ContentObserver? = null
    private var screenCaptureCallback: Activity.ScreenCaptureCallback? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastSeenImageTimestamp = 0L
    private var isListening = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        contentResolver = flutterPluginBinding.applicationContext.contentResolver
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_screenshot_detector/events")
        eventChannel?.setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        isListening = true
        startDetection()
    }

    override fun onCancel(arguments: Any?) {
        isListening = false
        stopDetection()
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDetection()
        eventChannel?.setStreamHandler(null)
        eventChannel = null
        contentResolver = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        if (isListening) {
            startDetection()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        stopDetection()
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        stopDetection()
        activity = null
    }

    private fun startDetection() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            registerScreenCaptureCallback()
        } else {
            registerObserver()
        }
    }

    private fun stopDetection() {
        unregisterScreenCaptureCallback()
        unregisterObserver()
    }

    private fun registerScreenCaptureCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        if (screenCaptureCallback != null) return

        val currentActivity = activity ?: return
        val callback = Activity.ScreenCaptureCallback {
            emitScreenshotEvent("android")
        }

        currentActivity.registerScreenCaptureCallback(currentActivity.mainExecutor, callback)
        screenCaptureCallback = callback
    }

    private fun unregisterScreenCaptureCallback() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return

        val callback = screenCaptureCallback ?: return
        activity?.unregisterScreenCaptureCallback(callback)
        screenCaptureCallback = null
    }

    private fun registerObserver() {
        if (observer != null) return

        val resolver = contentResolver ?: return
        lastSeenImageTimestamp = latestImageTimestamp() ?: 0L
        observer = object : ContentObserver(mainHandler) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                super.onChange(selfChange, uri)
                detectLatestScreenshot()
            }
        }

        resolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            observer as ContentObserver
        )
    }

    private fun unregisterObserver() {
        val resolver = contentResolver
        val currentObserver = observer

        if (resolver != null && currentObserver != null) {
            resolver.unregisterContentObserver(currentObserver)
        }

        observer = null
    }

    private fun detectLatestScreenshot() {
        val resolver = contentResolver ?: return
        val dateAddedColumn = MediaStore.Images.Media.DATE_ADDED
        val displayNameColumn = MediaStore.Images.Media.DISPLAY_NAME
        val projection = mutableListOf(dateAddedColumn, displayNameColumn)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            projection.add(MediaStore.Images.Media.RELATIVE_PATH)
        } else {
            @Suppress("DEPRECATION")
            projection.add(MediaStore.Images.Media.DATA)
        }

        try {
            resolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection.toTypedArray(),
                null,
                null,
                "$dateAddedColumn DESC"
            )?.use { cursor ->
                if (!cursor.moveToFirst()) return

                val timestamp = cursor.getLong(cursor.getColumnIndexOrThrow(dateAddedColumn)) * 1000
                val displayName = cursor.getString(cursor.getColumnIndexOrThrow(displayNameColumn))
                val pathColumn = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    MediaStore.Images.Media.RELATIVE_PATH
                } else {
                    @Suppress("DEPRECATION")
                    MediaStore.Images.Media.DATA
                }
                val path = cursor.getString(cursor.getColumnIndexOrThrow(pathColumn))

                if (timestamp <= lastSeenImageTimestamp) {
                    return
                }

                lastSeenImageTimestamp = timestamp

                if (!looksLikeScreenshot(displayName, path)) {
                    return
                }

                emitScreenshotEvent("android")
            }
        } catch (_: SecurityException) {
            eventSink?.error(
                "missing_permission",
                "Android screenshot detection requires media/image read permission.",
                null
            )
        } catch (_: Exception) {
            // Ignore unrelated MediaStore changes that cannot be inspected.
        }
    }

    private fun latestImageTimestamp(): Long? {
        val resolver = contentResolver ?: return null
        val dateAddedColumn = MediaStore.Images.Media.DATE_ADDED

        return try {
            resolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                arrayOf(dateAddedColumn),
                null,
                null,
                "$dateAddedColumn DESC"
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    cursor.getLong(cursor.getColumnIndexOrThrow(dateAddedColumn)) * 1000
                } else {
                    null
                }
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun looksLikeScreenshot(displayName: String?, path: String?): Boolean {
        val value = "${displayName.orEmpty()} ${path.orEmpty()}".lowercase()
        return value.contains("screenshot") ||
            value.contains("screen_shot") ||
            value.contains("screenshots")
    }

    private fun emitScreenshotEvent(platform: String) {
        eventSink?.success(
            mapOf(
                "platform" to platform,
                "timestamp" to System.currentTimeMillis()
            )
        )
    }
}
