#!/bin/bash

set -e

# Usage:
# ./lint.sh COMMAND
#
# where COMMAND is one of:
#
# - check: Check for code style violations
# - fix: Fix any automatically-fixable code style violations
# - fix-then-check: Same as running with `fix` command and then running with `check` command

# We’re using Mint to make sure that everyone runs the same version of SwiftLint. The exact version of SwiftLint is specified in the repo's Mintfile.

if ! which mint > /dev/null
then
  echo "You need to install Mint (https://github.com/yonaskolb/Mint)." 1>&2
  exit 1
fi

SWIFTLINT_COMMAND="mint run realm/SwiftLint"

check() {
  ${SWIFTLINT_COMMAND} --strict
}

fix() {
  ${SWIFTLINT_COMMAND} --fix
}

fix_then_check() {
  fix
  check
}

if [[ $1 == "check" ]] || [[ -z $1 ]]
then
  check
elif [[ $1 == "fix" ]]
then
  fix
elif [[ $1 == "fix-then-check" ]]
then
  fix_then_check
else
  echo "Unknown command $1 (known commands are 'check', 'fix', 'fix-then-check')" 1>&2
  exit 1
fi
