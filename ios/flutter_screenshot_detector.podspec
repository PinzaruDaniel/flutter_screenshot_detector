#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_screenshot_detector.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_screenshot_detector'
  s.version          = '0.0.1'
  s.summary          = 'Detects user screenshots in Flutter apps.'
  s.description      = <<-DESC
Detects when the user takes a screenshot in Flutter apps on Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/PinzaruDaniel/flutter_screenshot_detector'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Daniel Pinzaru' => 'daniel.pinzaru@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_screenshot_detector/Sources/flutter_screenshot_detector/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_screenshot_detector_privacy' => ['flutter_screenshot_detector/Sources/flutter_screenshot_detector/PrivacyInfo.xcprivacy']}
end
