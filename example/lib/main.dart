import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenshot_detector/flutter_screenshot_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _screenshotCount = 0;
  ScreenshotEvent? _lastScreenshot;
  StreamSubscription<ScreenshotEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterScreenshotDetector.instance.onScreenshot.listen((
      event,
    ) {
      if (!mounted) return;
      setState(() {
        _screenshotCount++;
        _lastScreenshot = event;

      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastScreenshot = _lastScreenshot;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Screenshot detector')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Screenshots detected: $_screenshotCount'),
                if (lastScreenshot != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Last platform: ${lastScreenshot.platform ?? 'unknown'}',
                  ),
                  Text('Last time: ${lastScreenshot.timestamp}'),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
