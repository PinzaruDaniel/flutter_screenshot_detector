import XCTest

@testable import flutter_screenshot_detector

// This demonstrates a simple unit test of the Swift portion of this plugin's implementation.
//
// See https://developer.apple.com/documentation/xctest for more information about using XCTest.

class RunnerTests: XCTestCase {

  func testStreamLifecycle() {
    let plugin = FlutterScreenshotDetectorPlugin()

    let listenError = plugin.onListen(withArguments: nil) { _ in }
    XCTAssertNil(listenError)

    let cancelError = plugin.onCancel(withArguments: nil)
    XCTAssertNil(cancelError)
  }

}
