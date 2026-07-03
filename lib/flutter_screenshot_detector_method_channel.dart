import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_screenshot_detector_platform_interface.dart';
import 'src/android_legacy_mode.dart';
import 'src/screenshot_event.dart';

/// An implementation of [FlutterScreenshotDetectorPlatform] that uses method channels.
class MethodChannelFlutterScreenshotDetector
    extends FlutterScreenshotDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('flutter_screenshot_detector/events');

  /// The method channel used to configure native detection.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_screenshot_detector');

  @override
  Stream<ScreenshotEvent> get onScreenshot =>
      eventChannel.receiveBroadcastStream().map(ScreenshotEvent.fromMap);

  @override
  Future<void> configure({
    AndroidLegacyMode androidLegacyMode = AndroidLegacyMode.focusHeuristic,
  }) {
    return methodChannel.invokeMethod<void>('configure', {
      'androidLegacyMode': androidLegacyMode.name,
    });
  }
}
