import 'flutter_screenshot_detector_platform_interface.dart';
import 'src/screenshot_event.dart';
export 'src/screenshot_event.dart';

class FlutterScreenshotDetector {
  /// Creates a screenshot detector.
  const FlutterScreenshotDetector();

  /// A shared detector instance for apps that prefer singleton-style access.
  static const instance = FlutterScreenshotDetector();

  /// Emits whenever the user takes a screenshot of the app.
  Stream<ScreenshotEvent> get onScreenshot =>
      FlutterScreenshotDetectorPlatform.instance.onScreenshot;
}
