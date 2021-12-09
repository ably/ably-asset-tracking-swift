#!/bin/bash

set -e

# This script is updating AAT Library version, it is looking for regex pattern `(libraryVersion = ").+(")` and replace 
# the value of `libraryVersion` with the new value ($1) passed to the script.
#
# usage: `./update-version.sh 1.0.0-beta.5`

BASEDIR=$(dirname "$0")

sed -i '' -E 's/(ibraryVersion = ").+(")/\1'$1'\2/' $BASEDIR/../Sources/AblyAssetTrackingCore/Version.swift
sed -i '' -E 's/(ibraryVersion = ").+(")/\1'$1'\2/' $BASEDIR/../Tests/CoreTests/Sources/Helper/VersionTest.swift