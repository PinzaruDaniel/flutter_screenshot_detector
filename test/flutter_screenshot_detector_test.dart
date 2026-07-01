import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector_platform_interface.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterScreenshotDetectorPlatform
    with MockPlatformInterfaceMixin
    implements FlutterScreenshotDetectorPlatform {
  @override
  Stream<ScreenshotEvent> get onScreenshot => Stream.value(
    ScreenshotEvent(
      timestamp: DateTime.fromMillisecondsSinceEpoch(42),
      platform: 'test',
    ),
  );
}

void main() {
  final FlutterScreenshotDetectorPlatform initialPlatform =
      FlutterScreenshotDetectorPlatform.instance;

  test('$MethodChannelFlutterScreenshotDetector is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterScreenshotDetector>(),
    );
  });

  test('onScreenshot', () async {
    const flutterScreenshotDetectorPlugin = FlutterScreenshotDetector();
    final fakePlatform = MockFlutterScreenshotDetectorPlatform();
    FlutterScreenshotDetectorPlatform.instance = fakePlatform;

    final event = await flutterScreenshotDetectorPlugin.onScreenshot.first;

    expect(event.platform, 'test');
    expect(event.timestamp, DateTime.fromMillisecondsSinceEpoch(42));
  });
}
