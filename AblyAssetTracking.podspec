Pod::Spec.new do |spec|
  spec.name = 'AblyAssetTracking'
  spec.version = '0.0.1'
  spec.summary = 'Ably Asset Tracking Client'
  spec.homepage = "https://www.ably.io"
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author = { "Ably" => "support@ably.io" }
  spec.source = { :git => "git@github.com:ably/ably-asset-tracking-cocoa.git" }
  spec.ios.deployment_target  = '12.0'

  spec.subspec 'Publisher' do |ss|
    ss.dependency 'Ably', '~> 1.2.0'
    ss.dependency 'MapboxCoreNavigation', '~> 1.1.0'
    ss.dependency 'AblyAssetTracking/Core'

    ss.source_files = 'Publisher/**/*.swift'
    ss.ios.deployment_target = '12.0'
    spec.swift_version = '5.0'
  end

  spec.subspec 'Subscriber' do |ss|
    ss.dependency 'Ably', '~> 1.2.0'
    ss.dependency 'AblyAssetTracking/Core'

    ss.source_files = 'Subscriber/**/*.swift'
    ss.ios.deployment_target = '12.0'
    spec.swift_version = '5.0'
  end

  spec.subspec 'Core' do |ss|
    ss.source_files = 'Core/**/*.swift'
    ss.ios.deployment_target = '12.0'
    spec.swift_version = '5.0'
  end
end