#!/usr/bin/env bash

set -e
BASEDIR=$(dirname "$0")
WORKSPACE_PATH="${BASEDIR}/../Examples/AblyAssetTracking.xcworkspace"

# Jazzy's support for SPM involves using SourceKitten manually to generate json  files, then joining them together with jazzy:
# https://github.com/realm/jazzy/issues/1194#issuecomment-633012820

# Requires sourcekitten, which can be installed via Homebrew.
# https://github.com/jpsim/SourceKitten

# If we don't specify '-destination' to be an iOS platform, we get xcodebuild error with:
# Reason: The run destination My Mac is not valid for Running the scheme 'Publisher'.
# This is because Publisher requires libraries which don't support macOS properly (Mapbox) which have conflicting dependencies.

# Hack: AblyAssetTrackingCore and AblyAssetTrackingInternal modules do not have schemes in the Xcode Workspace, so the 
#   AblyAssetTrackingSubscriber is used instead.
# If jazzy, sourcekitten and xcodebuild can build Swift Packages without internally creating Xcode schemes, this would not be a problem. Alternatively, if Xcode autogenerated schemes for Core and Internal, we can use those.
mkdir -p $BASEDIR/build

output_filepath=$BASEDIR/build/core.json
sourcekitten doc \
  --module-name AblyAssetTrackingCore \
  -- \
  -workspace "$WORKSPACE_PATH" \
  -scheme AblyAssetTrackingSubscriber \
  -destination generic/platform=iOS \
  > "$output_filepath"

echo "Saved AblyAssetTrackingCore docs JSON to $output_filepath"

output_filepath=$BASEDIR/build/internal.json
sourcekitten doc \
  --module-name AblyAssetTrackingInternal \
  -- \
  -workspace "$WORKSPACE_PATH" \
  -scheme AblyAssetTrackingSubscriber \
  -destination generic/platform=iOS \
  > "$output_filepath"

echo "Saved AblyAssetTrackingInternal docs JSON to $output_filepath"

output_filepath=$BASEDIR/build/publisher.json
sourcekitten doc \
  --module-name AblyAssetTrackingPublisher \
  -- \
  -workspace "$WORKSPACE_PATH" \
  -scheme AblyAssetTrackingPublisher \
  -destination generic/platform=iOS \
  > "$output_filepath"

echo "Saved AblyAssetTrackingPublisher docs JSON to $output_filepath"

output_filepath=$BASEDIR/build/subscriber.json
sourcekitten doc \
  --module-name AblyAssetTrackingSubscriber \
  -- \
  -workspace "$WORKSPACE_PATH" \
  -scheme AblyAssetTrackingSubscriber \
  -destination generic/platform=iOS \
  > "$output_filepath"

echo "Saved AblyAssetTrackingSubscriber docs JSON to $output_filepath"

echo "Generating docs based on multiple doc JSONs..."
bundle exec jazzy --config "$BASEDIR/config.yml"
