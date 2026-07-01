import Flutter
import UIKit

public class FlutterScreenshotDetectorPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterScreenshotDetectorPlugin()
    let eventChannel = FlutterEventChannel(
      name: "flutter_screenshot_detector/events",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    eventSink = nil
    return nil
  }

  @objc private func userDidTakeScreenshot() {
    eventSink?([
      "platform": "ios",
      "timestamp": Int(Date().timeIntervalSince1970 * 1000)
    ])
  }
}
