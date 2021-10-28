# This script is used to run all tests.

set -e

if [[ -z "${MAPBOX_ACCESS_TOKEN}" ]]; then
	echo "environment variable MAPBOX_ACCESS_TOKEN is not set"
	exit 1
fi

if [[ -z "${ABLY_API_KEY}" ]]; then
	echo "environment variable ABLY_API_KEY is not set"
	exit 1
fi

bundle install

# Create Secret.swift with ably key and mapbox token

cat > ./Tests/SystemTests/Secrets.swift <<EOF
struct Secrets {
	static let ablyApiKey = "$ABLY_API_KEY"
	static let mapboxAccessToken = "$MAPBOX_ACCESS_TOKEN"
}
EOF

xcodebuild test -scheme "ably-asset-tracking-swift-Package" -destination 'platform=iOS Simulator,name=iPhone 12' | xcpretty || exit 1