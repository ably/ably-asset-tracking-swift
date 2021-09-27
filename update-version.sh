#!/bin/bash

set -e

# find `ablyAssetTrackingLibraryVersion = "current_version"` and replace `current_version` with $1
# script starts searching the pattern in project root directory recurively

find ./ -type f -and -name "*.swift" -print0 | xargs -0 sed -i.old_version -E 's/(ablyAssetTrackingLibraryVersion = ").+(")/\1'$1'\2/'
find ./ -type f -and -name "*.old_version" -print0 | xargs -0 rm