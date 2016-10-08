#!/bin/bash

basedir="$(dirname $0)"
source "${basedir}/util.sh"

usage() {
  err 'Usage:'
  err "  $scriptname <base_ref> <test_ref> <testspec>"
  exit 1
}

###############################################################################

export_tree() {
  local ref="$1"

  git archive --prefix="${treedir}/${ref}/" "${ref}": | tar x -C "${tempdir}"
}

# Path to office script from root of tree.
office_script_path() {
  local hour="$1"
  echo -n 'web/cgi-bin/'
  if [ "${hour}" = 'SanctaMissa' ]; then
    echo 'missa/missa.pl'
  else
    echo 'horas/officium.pl'
  fi
}

long_version() {
  local short_version="$1"
  case "${short_version}" in
    Monastic)   echo 'pre-Trident Monastic';;
    1570)       echo 'Trident 1570';;
    1910)       echo 'Trident 1910';;
    Divino)     echo 'Divino Afflatu';;
    1955)       echo 'Reduced 1955';;
    1960)       echo 'Rubrics 1960';;
    *)          die "Invalid short version: ${short_version}"
  esac
}

hour_command() {
  local hour="$1"
  echo "pray${hour}"
}

run_single_test() {
  local test_tree="$1"
  local output_tree="$2"
  local short_version="$3"
  local date="$4"
  local hour="$5"

  local output_dir="${output_tree}/${short_version}/${date}"
  mkdir -p "${output_dir}"

  # Run the script and store its output, stripping off the cookie.
  "${test_tree}/$(office_script_path "${hour}")" \
    "version=$(long_version "${short_version}")" \
    "command=$(hour_command "${hour}")" \
    "date=${date}" | \
    grep -Pv '^Set-Cookie:' > \
    "${output_dir}/${hour}.out"
}

expand_dates() {
  local testspec="$1"
  "${scriptdir}/expand-dates.pl" "${testspec}"
}

gen_output_tree() {
  local ref="$1"
  echo "${tempdir}/${outputdir}/${ref}"
}

run_test() {
  local ref="$1"
  local testspec="$2"
  local test_tree="${tempdir}/${treedir}/${ref}"
  local output_tree="$(gen_output_tree "${ref}")"

  dates="$(expand_dates "${testspec}")"
  for date in ${dates}; do
    for hour in Matutinum Vespera SanctaMissa; do
      for short_version in Divino 1960; do
        run_single_test \
          "${test_tree}" \
          "${output_tree}" \
          "${short_version}" \
          "${date}" \
          "${hour}"
      done
    done
  done
}

###############################################################################

main() {
  # Globals.
  treedir=trees
  outputdir=output
  scriptname=$(basename "$0")
  scriptdir=$(dirname "$0")

  [ $# -eq 3 ] || usage

  local reporoot=$(git rev-parse --show-toplevel)
  local base_ref=$(git rev-parse --verify "$1")
  local test_ref=$(git rev-parse --verify "$2")
  local testspec="$3"

  # Export the two test trees.
  echo 'Exporting...'
  try export_tree "${base_ref}"
  try export_tree "${test_ref}"

  # Run test against each tree.
  echo 'Testing...'
  run_test "${base_ref}" "${testspec}"
  run_test "${test_ref}" "${testspec}"

  # Generate diff.
  echo 'Diffing...'
  local diff_output="${tempdir}/output.diff"
  diff -ur \
    "$(gen_output_tree "${base_ref}")" \
    "$(gen_output_tree "${test_ref}")" > \
    "${diff_output}" || true
  diffstat -p5 "${diff_output}"
  cat "${diff_output}"
}

tempdir=$(mktemp -d) || die 'Failed to create temporary directory.'
(set -e; main "$@")
ret=$?
try rm -rf "${tempdir}"
exit ${ret}
