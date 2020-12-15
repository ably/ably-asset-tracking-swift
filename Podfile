platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!
workspace 'AblyAssetTracking.xcworkspace'

def ably_sdk
  pod 'Ably', '~> 1.2.0'
end

def mapbox_sdk
  pod 'MapboxCoreNavigation', '~> 1.1.0'
end

abstract_target 'asset_tracking' do
  pod 'SwiftLint'

  target 'Core' do
    project 'Core/Core.xcodeproj'
  end

  target 'Publisher' do
    project 'Publisher/Publisher.xcodeproj'
    ably_sdk
    mapbox_sdk
  end

  target 'Subscriber' do
    project 'Subscriber/Subscriber.xcodeproj'
    ably_sdk
    pod 'SwiftLint'
  end

  # Example apps
  target 'PublisherExample' do
    project 'PublisherExample/PublisherExample.xcodeproj'
    mapbox_sdk
    ably_sdk
  end

  target 'SubscriberExample' do
    project 'SubscriberExample/SubscriberExample.xcodeproj'
    ably_sdk
  end

  # Tests
  target 'CoreTests' do
    project 'Core/Core.xcodeproj'
  end

  target 'PublisherTests' do
    project 'Publisher/Publisher.xcodeproj'
  end

  target 'SubscriberTests' do
    project 'Subscriber/Subscriber.xcodeproj'
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    config.build_settings['ARCHS'] = "arm64 x86_64"
  end
end
