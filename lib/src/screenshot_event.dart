/// Information about a detected screenshot.
class ScreenshotEvent {
  /// Creates a screenshot event.
  const ScreenshotEvent({required this.timestamp, this.platform});

  /// Time when the platform reported the screenshot.
  final DateTime timestamp;

  /// Native platform that emitted the event, such as `android` or `ios`.
  final String? platform;

  /// Builds an event from the map emitted by the native plugin.
  factory ScreenshotEvent.fromMap(Object? value) {
    final map = value is Map ? value : const <Object?, Object?>{};
    final timestampValue = map['timestamp'];
    final platformValue = map['platform'];

    final millisecondsSinceEpoch = timestampValue is int
        ? timestampValue
        : DateTime.now().millisecondsSinceEpoch;

    return ScreenshotEvent(
      timestamp: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
      platform: platformValue is String ? platformValue : null,
    );
  }
}
