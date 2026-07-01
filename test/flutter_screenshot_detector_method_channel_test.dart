import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterScreenshotDetector();

  test('onScreenshot is a broadcast stream', () {
    expect(platform.onScreenshot, isA<Stream>());
  });
}
