# This script is used to check that "Ably Asset Tracker" lib integration works properly in example apps.

set -e

# Install xcpretty (https://github.com/xcpretty/xcpretty)
gem install --user-install xcpretty

# [TEST] Publisher Example (swift)
echo
echo '\033[1mBuild: PublisherExample\033[0m'
echo

set -o pipefail && xcodebuild build -scheme "PublisherExampleObjectiveC" -workspace "./Examples/AblyAssetTracking.xcworkspace" -sdk "iphonesimulator" -configuration "Debug" | xcpretty
