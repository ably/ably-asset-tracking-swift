#!/bin/sh
set -e

# This script is designed to be run from the root of this repository with:
# ./jazzy/build.sh
if [ ! -d "jazzy" ]; then
  echo "Cannot find jazzy folder. This script must be run from repository root." >&2
  exit 1
fi

mkdir -p jazzy/build

# based on the approach here:
# https://github.com/realm/jazzy/issues/1194#issuecomment-633012820

# Requires sourcekitten, which can be installed via Homebrew.
# https://github.com/jpsim/SourceKitten

# If we don't specify '-destination' then we get xcodebuild error with:
# Reason: The run destination My Mac is not valid for Running the scheme 'Publisher'.

sourcekitten doc \
  --module-name Core \
  -- \
  -workspace ./AblyAssetTracking.xcworkspace \
  -scheme Core \
  -destination generic/platform=iOS \
  -derivedDataPath jazzy/build/xcodebuildDerivedData \
  -verbose \
  > jazzy/build/core.json

sourcekitten doc \
  --module-name Publisher \
  -- \
  -workspace ./AblyAssetTracking.xcworkspace \
  -scheme Publisher \
  -destination generic/platform=iOS \
  -derivedDataPath jazzy/build/xcodebuildDerivedData \
  -verbose \
  > jazzy/build/publisher.json

sourcekitten doc \
  --module-name Subscriber \
  -- \
  -workspace ./AblyAssetTracking.xcworkspace \
  -scheme Subscriber \
  -destination generic/platform=iOS \
  -derivedDataPath jazzy/build/xcodebuildDerivedData \
  -verbose \
  > jazzy/build/subscriber.json

bundle exec jazzy --config jazzy/config.yml
