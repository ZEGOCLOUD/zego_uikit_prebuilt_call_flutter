#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zego_uikit_prebuilt_call.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zego_uikit_prebuilt_call'
  s.version          = '4.24.6' # zego_uikit_prebuilt_call:
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'zego_uikit_prebuilt_call/Sources/zego_uikit_prebuilt_call/**/*'
  s.public_header_files = 'zego_uikit_prebuilt_call/Sources/zego_uikit_prebuilt_call/include/zego_uikit_prebuilt_call/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
