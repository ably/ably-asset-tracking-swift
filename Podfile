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
  # Official Apple SwiftLog pod
  pod 'Logging', '~> 1.4.0'
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
    pod 'AblyAssetTracking/Publisher', :path => 'AblyAssetTracking.podspec'
  end

  target 'SubscriberExample' do
    project 'SubscriberExample/SubscriberExample.xcodeproj'
    pod 'AblyAssetTracking/Subscriber', :path => 'AblyAssetTracking.podspec'
  end

  target 'PublisherExampleObjectiveC' do
    project 'PublisherExampleObjectiveC/PublisherExampleObjectiveC.xcodeproj'
    pod 'AblyAssetTracking/Publisher', :path => 'AblyAssetTracking.podspec'
  end

  target 'SubscriberExampleObjectiveC' do
    project 'SubscriberExampleObjectiveC/SubscriberExampleObjectiveC.xcodeproj'
    pod 'AblyAssetTracking/Subscriber', :path => 'AblyAssetTracking.podspec'
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

# Due to issue on Xcode 12 we need to add 'arm64' as Excluded Architecture. Without it app will fail when built for device using Xcode12.
# As a downside, it won't be possible to run it on iOS simulator on MacBooks with M1 cpu.
# Check https://github.com/ably/ably-asset-tracking-cocoa/issues/40 for details.
post_install do |installer|
  installer.pods_project.targets.each do |target|
      if target.name  == "MapboxCoreNavigation"
        target.build_configurations.each do |config|
          config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
      end
    end
end
