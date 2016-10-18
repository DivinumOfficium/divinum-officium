#!/bin/bash

set -e

basedir="$(dirname $0)"
source "${basedir}/util.sh"

parent_rev="$(echo ${TRAVIS_COMMIT_RANGE} |
		perl -ne '/(.*)\.\.\./ && print $1')"
test_rev="${TRAVIS_COMMIT}"

# Check validity of commits.
git rev-parse --verify "${parent_rev}"
git rev-parse --verify "${test_rev}"

mdy_date() { date "$@" +'%m-%d-%Y'; }

# Test two consecutive years, starting from today.
"${basedir}/generate-diff.sh" \
  "${parent_rev}"             \
  "${test_rev}"               \
  <(echo "$(mdy_date):$(mdy_date -d '+ 2 years - 1 day')")
