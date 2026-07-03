import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector.dart';
import 'package:flutter_screenshot_detector/flutter_screenshot_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterScreenshotDetector();
  const channel = MethodChannel('flutter_screenshot_detector');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('onScreenshot is a broadcast stream', () {
    expect(platform.onScreenshot, isA<Stream>());
  });

  test('configure passes android legacy mode', () async {
    Object? arguments;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          arguments = call.arguments;
          return null;
        });

    await platform.configure(androidLegacyMode: AndroidLegacyMode.mediaStore);

    expect(arguments, {'androidLegacyMode': 'mediaStore'});
  });
}
