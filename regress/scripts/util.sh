err() {
  echo "$@" >&2
}

die() {
  err "$@"
  exit 1
}

try() {
  "$@" || die "ERROR: failed $@"
}
