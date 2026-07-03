import 'flutter_screenshot_detector_platform_interface.dart';
import 'src/android_legacy_mode.dart';
import 'src/screenshot_event.dart';
export 'src/android_legacy_mode.dart';
export 'src/screenshot_event.dart';

class FlutterScreenshotDetector {
  /// Creates a screenshot detector.
  const FlutterScreenshotDetector();

  /// A shared detector instance for apps that prefer singleton-style access.
  static const instance = FlutterScreenshotDetector();

  /// Emits whenever the user takes a screenshot of the app.
  Stream<ScreenshotEvent> get onScreenshot =>
      FlutterScreenshotDetectorPlatform.instance.onScreenshot;

  /// Configures platform-specific screenshot detection behavior.
  ///
  /// [androidLegacyMode] only affects Android 13 and older. Android 14 and
  /// newer always use the native screen-capture callback.
  Future<void> configure({
    AndroidLegacyMode androidLegacyMode = AndroidLegacyMode.focusHeuristic,
  }) {
    return FlutterScreenshotDetectorPlatform.instance.configure(
      androidLegacyMode: androidLegacyMode,
    );
  }
}
