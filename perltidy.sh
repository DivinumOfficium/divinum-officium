#!/bin/sh

set -e

for file in $(find . -name '*.pl' -o -name '*.pm' | sort); do
  echo "$file"
  perltidy "$file"
done
