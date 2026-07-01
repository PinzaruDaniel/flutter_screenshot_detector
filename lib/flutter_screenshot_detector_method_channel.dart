import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_screenshot_detector_platform_interface.dart';
import 'src/screenshot_event.dart';

/// An implementation of [FlutterScreenshotDetectorPlatform] that uses method channels.
class MethodChannelFlutterScreenshotDetector
    extends FlutterScreenshotDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('flutter_screenshot_detector/events');

  @override
  Stream<ScreenshotEvent> get onScreenshot =>
      eventChannel.receiveBroadcastStream().map(ScreenshotEvent.fromMap);
}
