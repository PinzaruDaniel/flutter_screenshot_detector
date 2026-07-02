# flutter_screenshot_detector

A Flutter plugin that emits an event when the user takes a screenshot of your app.

## Features

- Android 14+ screenshot detection through the platform screen-capture callback.
- Android 13 and older fallback through window focus-change detection.
- iOS screenshot detection through `UIApplication.userDidTakeScreenshotNotification`.
- Simple Dart stream API.
- Built with Flutter 3.44 and Dart 3.12 compatibility.

## Usage

```dart
import 'dart:async';

import 'package:flutter_screenshot_detector/flutter_screenshot_detector.dart';

late final StreamSubscription<ScreenshotEvent> subscription;

void startListening() {
  subscription = FlutterScreenshotDetector.instance.onScreenshot.listen((event) {
    // React after the screenshot is taken.
    print('Screenshot detected on ${event.platform} at ${event.timestamp}');
  });
}

Future<void> stopListening() => subscription.cancel();
```

## Android setup

The plugin declares the required Android permissions in its manifest:

```xml
<uses-permission android:name="android.permission.DETECT_SCREEN_CAPTURE" />
```

No media runtime permission is required. On Android 14 and newer, the plugin
uses `Activity.registerScreenCaptureCallback`. On Android 13 and older, Android
does not provide a direct screenshot callback for third-party apps, so the plugin
uses a focus-change heuristic.

## iOS setup

iOS does not require additional permissions. The event is emitted after the
system posts `UIApplication.userDidTakeScreenshotNotification`.

## Limitations

- Detection happens after the screenshot is taken.
- iOS does not expose the screenshot file path.
- Android 13 and older detection is heuristic. It can miss screenshots on some
  devices and may report false positives for other quick system focus changes.
