#!/bin/bash

set -e

# This script is updating AAT Library version, it is looking for regex pattern `(ablyAssetTrackingLibraryVersion = ").+(")` and replace 
# the value of `ablyAssetTrackingLibraryVersion` with the new value ($1) passed to the script.
# This script starts searching in the project root directory recursively and processes all files in the project in search of the pattern above.
#
# usage: `./update-version.sh 1.0.0-beta.5`

find ./ -type f -and -name "*.swift" -print0 | xargs -0 sed -i.old_version -E 's/(ablyAssetTrackingLibraryVersion = ").+(")/\1'$1'\2/'
find ./ -type f -and -name "*.old_version" -print0 | xargs -0 rm