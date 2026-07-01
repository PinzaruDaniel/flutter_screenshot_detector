import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_screenshot_detector_example/main.dart';

void main() {
  testWidgets('shows screenshot counter', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Screenshots detected: 0'), findsOneWidget);
  });
}
