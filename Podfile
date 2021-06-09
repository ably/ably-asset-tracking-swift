platform :ios, '12.0'
use_frameworks! # Needed for AWS Amplify https://cocoapods.org/pods/Amplify
inhibit_all_warnings!
workspace 'AblyAssetTracking.xcworkspace'

def ably_sdk
  pod 'Ably', '~> 1.2.0'
end

def mapbox_sdk
  pod 'MapboxCoreNavigation', :git => 'https://github.com/mapbox/mapbox-navigation-ios.git', :tag => 'v2.0.0-beta.10'
  # pod 'MapboxCoreNavigation', '~> 2.0.0' # Use this once its released to cocoapods
end

abstract_target 'asset_tracking' do
  # Official Apple SwiftLog pod
  pod 'Logging', '~> 1.4.0'
  pod 'SwiftLint'

  target 'Core' do
    project 'Core/Core.xcodeproj'
    ably_sdk
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
    pod 'Amplify', '~> 1.6.0'
    pod 'AmplifyPlugins/AWSS3StoragePlugin', '~> 1.6.0'
    pod 'AmplifyPlugins/AWSCognitoAuthPlugin', '~> 1.6.0'
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
