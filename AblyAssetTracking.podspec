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
    ss.dependency 'MapboxCoreNavigation'
    # ss.dependency 'MapboxCoreNavigation', '~> 2.0.0' # Use this once its released to cocoapods
    ss.dependency 'Logging', '~> 1.4.0'
    ss.dependency 'Amplify', '~> 1.6.0'
    ss.dependency 'AmplifyPlugins/AWSS3StoragePlugin', '~> 1.6.0'
    ss.dependency 'AmplifyPlugins/AWSCognitoAuthPlugin', '~> 1.6.0'
    ss.source_files = 'Publisher/Sources/**/*.swift', 'Core/Sources/**/*.swift'
    ss.ios.deployment_target = '12.0'
  end

  spec.subspec 'Subscriber' do |ss|
    ss.dependency 'Ably', '~> 1.2.0'
    ss.dependency 'Logging', '~> 1.4.0'
    ss.source_files = 'Subscriber/Sources/**/*.swift', 'Core/Sources/**/*.swift'
    ss.ios.deployment_target = '12.0'
  end
end
