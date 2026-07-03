/// Detection strategy used on Android 13 and older.
enum AndroidLegacyMode {
  /// Uses window focus changes. Does not require media permission, but can
  /// produce false positives when system UI briefly steals focus.
  focusHeuristic,

  /// Uses `MediaStore` image changes. More accurate, but requires media or
  /// storage read permission from the host app.
  mediaStore,
}
