package com.danielpinzaru.flutter_screenshot_detector

import android.app.Activity
import android.os.Build
import android.view.ViewTreeObserver
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
    private var screenCaptureCallback: Activity.ScreenCaptureCallback? = null
    private var focusChangeListener: ViewTreeObserver.OnWindowFocusChangeListener? = null
    private var focusLossTimestamp = 0L
    private var lastEmittedTimestamp = 0L
    private var isListening = false

    private companion object {
        const val FOCUS_RETURN_WINDOW_MILLIS = 1500L
        const val DUPLICATE_EVENT_WINDOW_MILLIS = 1000L
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
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
            registerFocusChangeListener()
        }
    }

    private fun stopDetection() {
        unregisterScreenCaptureCallback()
        unregisterFocusChangeListener()
        focusLossTimestamp = 0L
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

    private fun registerFocusChangeListener() {
        if (focusChangeListener != null) return

        val decorView = activity?.window?.decorView ?: return
        val listener = ViewTreeObserver.OnWindowFocusChangeListener { hasFocus ->
            handleWindowFocusChange(hasFocus)
        }

        decorView.viewTreeObserver.addOnWindowFocusChangeListener(listener)
        focusChangeListener = listener
    }

    private fun unregisterFocusChangeListener() {
        val decorView = activity?.window?.decorView
        val listener = focusChangeListener

        if (decorView != null && listener != null && decorView.viewTreeObserver.isAlive) {
            decorView.viewTreeObserver.removeOnWindowFocusChangeListener(listener)
        }

        focusChangeListener = null
    }

    private fun handleWindowFocusChange(hasFocus: Boolean) {
        val now = System.currentTimeMillis()

        if (!hasFocus) {
            focusLossTimestamp = now
            return
        }

        if (focusLossTimestamp == 0L) {
            return
        }

        val focusReturnedQuickly = now - focusLossTimestamp <= FOCUS_RETURN_WINDOW_MILLIS
        val notDuplicate = now - lastEmittedTimestamp >= DUPLICATE_EVENT_WINDOW_MILLIS

        focusLossTimestamp = 0L

        if (focusReturnedQuickly && notDuplicate) {
            lastEmittedTimestamp = now
            emitScreenshotEvent("android")
        }
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
