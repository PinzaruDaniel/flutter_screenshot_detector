# flutter_screenshot_detector

A Flutter plugin that emits an event when the user takes a screenshot of your app.

## Features

- Android 14+ screenshot detection through the platform screen-capture callback.
- Android 13 and older configurable fallback modes.
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

### Android 13 and Older Mode

Android 14 and newer always use the native screen-capture callback. On Android
13 and older, choose one of two fallback modes before listening:

```dart
await FlutterScreenshotDetector.instance.configure(
  androidLegacyMode: AndroidLegacyMode.focusHeuristic,
);
```

`focusHeuristic` is the default. It does not require media permission, but it
can report false positives when system UI briefly steals focus. It waits for a
quick `false -> true` focus cycle, then emits after a short delay.

```dart
await FlutterScreenshotDetector.instance.configure(
  androidLegacyMode: AndroidLegacyMode.mediaStore,
);
```

`mediaStore` is more accurate, but your host app must declare and request media
or storage read permission.

## Android setup

The plugin declares the required Android permissions in its manifest:

```xml
<uses-permission android:name="android.permission.DETECT_SCREEN_CAPTURE" />
```

If you use `AndroidLegacyMode.mediaStore`, add the relevant permissions to your
app manifest and request them at runtime:

```xml
<uses-permission
  android:name="android.permission.READ_EXTERNAL_STORAGE"
  android:maxSdkVersion="32" />
<uses-permission
  android:name="android.permission.READ_MEDIA_IMAGES"
  android:maxSdkVersion="33" />
```

## iOS setup

iOS does not require additional permissions. The event is emitted after the
system posts `UIApplication.userDidTakeScreenshotNotification`.

## Limitations

- Detection happens after the screenshot is taken.
- iOS does not expose the screenshot file path.
- Android 13 and older `focusHeuristic` mode can miss screenshots on some
  devices and may report false positives for other quick system focus changes.
- Android 13 and older `mediaStore` mode depends on media access permission and
  device screenshot naming conventions.
