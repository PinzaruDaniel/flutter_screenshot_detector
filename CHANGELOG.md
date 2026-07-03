## 0.0.4

* Add configurable Android 13 and older fallback modes:
  `focusHeuristic` and `mediaStore`.
* Add delayed `false -> true` focus confirmation for `focusHeuristic` mode.

## 0.0.3

* Replace Android 13 and older `MediaStore` fallback with permissionless
  window focus-change detection.
* Remove Android media permissions.

## 0.0.2

* Add Android 14+ screenshot detection through `Activity.registerScreenCaptureCallback`.
* Limit Android media permissions to Android 13 and older fallback detection.
* Document Android 14+ permissionless media behavior.
* Debounce duplicate iOS screenshot notifications.

## 0.0.1

* Initial release with Android, iOS, and stream-based Dart screenshot detection.
