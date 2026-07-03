import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_screenshot_detector_method_channel.dart';
import 'src/android_legacy_mode.dart';
import 'src/screenshot_event.dart';

abstract class FlutterScreenshotDetectorPlatform extends PlatformInterface {
  /// Constructs a FlutterScreenshotDetectorPlatform.
  FlutterScreenshotDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterScreenshotDetectorPlatform _instance =
      MethodChannelFlutterScreenshotDetector();

  /// The default instance of [FlutterScreenshotDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterScreenshotDetector].
  static FlutterScreenshotDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterScreenshotDetectorPlatform] when
  /// they register themselves.
  static set instance(FlutterScreenshotDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<ScreenshotEvent> get onScreenshot {
    throw UnimplementedError('onScreenshot has not been implemented.');
  }

  Future<void> configure({
    AndroidLegacyMode androidLegacyMode = AndroidLegacyMode.focusHeuristic,
  }) {
    throw UnimplementedError('configure has not been implemented.');
  }
}
