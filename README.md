# flutter_screenshot_detector

A Flutter plugin that emits an event when the user takes a screenshot of your app.

## Features

- Android 14+ screenshot detection through the platform screen-capture callback.
- Android 13 and older fallback through `MediaStore` changes.
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
<uses-permission
  android:name="android.permission.READ_EXTERNAL_STORAGE"
  android:maxSdkVersion="32" />
<uses-permission
  android:name="android.permission.READ_MEDIA_IMAGES"
  android:maxSdkVersion="33" />
```

On Android 14 and newer, no media runtime permission is needed because the plugin
uses `Activity.registerScreenCaptureCallback`.

On Android 13 and older, the fallback still uses `MediaStore`, so your app must
request the appropriate runtime permission before listening:

- Android 13: `READ_MEDIA_IMAGES`
- Android 12 and older: `READ_EXTERNAL_STORAGE`

Android 13 and older do not provide a direct screenshot callback for third-party
apps, so the fallback detects screenshot-like image additions in `MediaStore`.

## iOS setup

iOS does not require additional permissions. The event is emitted after the
system posts `UIApplication.userDidTakeScreenshotNotification`.

## Limitations

- Detection happens after the screenshot is taken.
- iOS does not expose the screenshot file path.
- Android 13 and older detection depends on media access permission and device
  screenshot naming conventions.
