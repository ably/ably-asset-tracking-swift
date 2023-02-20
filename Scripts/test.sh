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

# We want to specify a custom derived data directory so that we know where to
# find the test result .xcresult bundle. However, it appears that putting the
# derived data directory inside a Swift package’s repo causes build errors (see
# https://forums.swift.org/t/xcode-and-swift-package-manager/44704/6). So I’m
# following the suggestion there of placing the derived data directory outside
# the repo.
temp_dir=`mktemp -d -t ably-asset-tracking-swift`
derived_data_dir="${temp_dir}/DerivedData"
cloned_source_packages_dir="${temp_dir}/ClonedSourcePackages"

# If xcodebuild fails (e.g. due to failed tests), we want to defer the failure
# of this script until we’ve had a chance to process and copy the logs that
# xcodebuild created. Hence we temporarily disable the -e option.
xcodebuild clean -scheme "ably-asset-tracking-swift-Package" -destination 'platform=iOS Simulator,name=iPhone 14'
xcodebuild -resolvePackageDependencies
set +e
set -o pipefail && xcodebuild test -scheme "ably-asset-tracking-swift-Package" -destination 'platform=iOS Simulator,name=iPhone 14' -derivedDataPath "${derived_data_dir}" -clonedSourcePackagesDirPath "${cloned_source_packages_dir}" \
| xcpretty
xcodebuild_exit_status=$?
set -e

# Create a directory to store all of the files that we wish to pass to
# subsequent actions in the GitHub workflow that called this script.
mkdir test-results

derived_data_logs_dir="${derived_data_dir}/Logs"

# Convert the .xcresult bundle into a JUnit report file for test-observability-action
mkdir test-results/junit

derived_data_test_logs_dir="${derived_data_logs_dir}/Test"
bundle exec fastlane run trainer "path:${derived_data_test_logs_dir}" extension:".junit" fail_build:"false"
cp "${derived_data_test_logs_dir}"/*.junit test-results/junit

# Copy the Logs directory from derived data for the "Xcodebuild Logs Artifact" step in check.yml
mkdir test-results/xcodebuild-logs
cp -r "${derived_data_logs_dir}" test-results/xcodebuild-logs

exit $xcodebuild_exit_status
