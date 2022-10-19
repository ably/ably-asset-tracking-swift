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

# If xcodebuild fails (e.g. due to failed tests), we want to defer the failure
# of this script until we’ve had a chance to copy the test results JUnit report
# to the place where test-observability-action expects it to be. Hence we
# temporarily disable the -e option.
set +e
# --report: "Creates a JUnit-style XML report at build/reports/junit.xml"
set -o pipefail && xcodebuild test -scheme "ably-asset-tracking-swift-Package" -destination 'platform=iOS Simulator,name=iPhone 12' \
	| xcpretty --report junit
xcodebuild_exit_status=$?
set -e

# test-observability-action looks for .junit files
cp build/reports/junit.xml results.junit

exit $xcodebuild_exit_status
