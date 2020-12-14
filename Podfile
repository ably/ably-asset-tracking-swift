platform :ios, '12.0'
use_frameworks!
workspace 'AblyAssetTracking.xcworkspace'

def ably_sdk
  pod 'Ably', '~> 1.2.0'
end

target 'Core' do
  project 'Core/Core.xcodeproj'
  pod 'SwiftLint'
end

target 'Publisher' do
  project 'Publisher/Publisher.xcodeproj'
  ably_sdk
  pod 'SwiftLint'
  pod 'MapboxCoreNavigation', '~> 1.1.0'
end

target 'Subscriber' do
  project 'Subscriber/Subscriber.xcodeproj'
  ably_sdk
  pod 'SwiftLint'
end

# Example apps
target 'PublisherExample' do
  project 'PublisherExample/PublisherExample.xcodeproj'
  pod 'SwiftLint'
end

target 'SubscriberExample' do
  project 'SubscriberExample/SubscriberExample.xcodeproj'
  pod 'SwiftLint'
end

# Tests
target 'CoreTests' do
  project 'Core/Core.xcodeproj'
  pod 'SwiftLint'
end

target 'PublisherTests' do
  project 'Publisher/Publisher.xcodeproj'
  pod 'SwiftLint'
end

target 'SubscriberTests' do
  project 'Subscriber/Subscriber.xcodeproj'
  pod 'SwiftLint'
end
