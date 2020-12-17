Pod::Spec.new do |spec|
  spec.name = 'AblyAssetTracking'
  spec.version = '0.0.1'
  spec.summary = 'Ably Asset Tracking Client'
  spec.homepage = "https://www.ably.io"
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author = { "Ably" => "support@ably.io" }
  spec.source = { :git => "." }
  spec.ios.deployment_target  = '12.0'
  spec.swift_version = '5.0'

  spec.subspec 'Publisher' do |ss|
    ss.dependency 'Ably', '~> 1.2.0'
    ss.dependency 'MapboxCoreNavigation', '~> 1.1.0'
    ss.source_files = 'Publisher/Sources/**/*.swift', 'Core/Sources/**/*.swift'
    ss.ios.deployment_target = '12.0'
  end

  spec.subspec 'Subscriber' do |ss|
    ss.dependency 'Ably', '~> 1.2.0'
    ss.source_files = 'Subscriber/Sources/**/*.swift', 'Core/Sources/**/*.swift'
    ss.ios.deployment_target = '12.0'
  end

  # Following lines will add warnings during execution of `pod install`
  # Check https://github.com/ably/ably-asset-tracking-cocoa/issues/40 for more details
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end