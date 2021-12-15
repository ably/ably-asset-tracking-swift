# This script is used to check that "Ably Asset Tracker" lib integration works properly in example apps.

set -e
set -o pipefail

# Install xcpretty (https://github.com/xcpretty/xcpretty)
gem install --user-install xcpretty

# Build AblyAssetTrackingSubscriber lib
echo
echo '\033[1mBuild: AblyAssetTrackingSubscriber Library\033[0m'
echo

xcodebuild -scheme "AblyAssetTrackingPublisher" -destination "generic/platform=iOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

# Build AblyAssetTrackingPublisher lib
echo
echo '\033[1mBuild: AblyAssetTrackingPublisher Library\033[0m'
echo

xcodebuild -scheme "AblyAssetTrackingPublisher" -destination "generic/platform=iOS" SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES | xcpretty

# Publisher Example (swift)
echo
echo '\033[1mBuild: PublisherExample\033[0m'
echo

xcodebuild build -scheme "PublisherExample" -workspace "./Examples/AblyAssetTracking.xcworkspace" -sdk "iphonesimulator" -configuration "Debug" | xcpretty

# Publisher Example (objective-c)
echo
echo '\033[1mBuild: PublisherExampleObjectiveC\033[0m'
echo

xcodebuild build -scheme "PublisherExampleObjectiveC" -workspace "./Examples/AblyAssetTracking.xcworkspace" -sdk "iphonesimulator" -configuration "Debug" | xcpretty

# Subscriber Example (swift)
echo
echo '\033[1mBuild: SubscriberExample\033[0m'
echo

xcodebuild build -scheme "SubscriberExample" -workspace "./Examples/AblyAssetTracking.xcworkspace" -sdk "iphonesimulator" -configuration "Debug" | xcpretty

# Subscriber Example (objective-c)
echo
echo '\033[1mBuild: SubscriberExampleObjectiveC\033[0m'
echo

xcodebuild build -scheme "SubscriberExampleObjectiveC" -workspace "./Examples/AblyAssetTracking.xcworkspace" -sdk "iphonesimulator" -configuration "Debug" | xcpretty
