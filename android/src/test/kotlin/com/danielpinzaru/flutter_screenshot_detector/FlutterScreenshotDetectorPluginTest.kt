package com.danielpinzaru.flutter_screenshot_detector

import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class FlutterScreenshotDetectorPluginTest {
    @Test
    fun streamHandler_lifecycleDoesNotThrow() {
        val plugin = FlutterScreenshotDetectorPlugin()

        plugin.onListen(null, null)
        plugin.onCancel(null)
    }
}
