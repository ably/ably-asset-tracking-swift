#!/bin/bash

set -e

# We’re using Mint to make sure that everyone runs the same version of Sourcery. The exact version of Sourcery is specified in the repo's Mintfile.

if ! which mint > /dev/null
then
  echo "You need to install Mint (https://github.com/yonaskolb/Mint)." 2>&1
  exit 1
fi

run_sourcery () {
  mint run krzysztofzablocki/Sourcery --config ".sourcery-${1}.yml"
}

run_sourcery "CoreMocks"
run_sourcery "InternalMocks"
run_sourcery "SubscriberMocks"
