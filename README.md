# flutter_screenshot_detector

A Flutter plugin that emits an event when the user takes a screenshot of your app.

## Features

- Android screenshot detection through `MediaStore` changes.
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

The plugin declares the required media permissions in its Android manifest:

```xml
<uses-permission
  android:name="android.permission.READ_EXTERNAL_STORAGE"
  android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

Your app must still request the appropriate runtime permission before listening.
On Android 13 and newer, request `READ_MEDIA_IMAGES`. On Android 12 and older,
request `READ_EXTERNAL_STORAGE`.

Android does not provide a direct screenshot callback for third-party apps, so
this plugin detects screenshot-like image additions in `MediaStore`.

## iOS setup

iOS does not require additional permissions. The event is emitted after the
system posts `UIApplication.userDidTakeScreenshotNotification`.

## Limitations

- Detection happens after the screenshot is taken.
- iOS does not expose the screenshot file path.
- Android detection depends on media access permission and device screenshot
  naming conventions.
