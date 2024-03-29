# This script is used to check that "Ably Asset Tracker" lib integration works properly in example apps.

set -e
set -o pipefail

# Install xcpretty (https://github.com/xcpretty/xcpretty)
gem install --user-install xcpretty

# Build AblyAssetTrackingSubscriber lib
echo
echo '\033[1mBuild: AblyAssetTrackingSubscriber Library\033[0m'
echo

xcodebuild -scheme "AblyAssetTrackingSubscriber" -destination "generic/platform=iOS" SKIP_INSTALL=NO | xcpretty

# Build AblyAssetTrackingPublisher lib
echo
echo '\033[1mBuild: AblyAssetTrackingPublisher Library\033[0m'
echo

xcodebuild -scheme "AblyAssetTrackingPublisher" -destination "generic/platform=iOS" SKIP_INSTALL=NO | xcpretty

# Subscriber Example (swift)
echo
echo '\033[1mBuild: SubscriberExample\033[0m'
echo

xcodebuild build -scheme "SubscriberExample" -workspace "./Examples/AblyAssetTracking.xcworkspace" -destination "platform=iOS Simulator,name=iPhone 14" -configuration "Debug" | xcpretty

# Publisher Example (SwiftUI)
echo
echo '\033[1mBuild: PublisherExample (SwiftUI)\033[0m'
echo

xcodebuild build -scheme "PublisherExample" -workspace "./Examples/AblyAssetTracking.xcworkspace" -destination "platform=iOS Simulator,name=iPhone 14" -configuration "Debug" | xcpretty
