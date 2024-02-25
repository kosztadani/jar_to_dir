#!/bin/bash

# jar_to_dir.sh - Recursively extract JAR/WAR/EAR files
#
# Author: Daniel Koszta (2021)
#
# License: public domain // CC0 1.0 Universal
# https://creativecommons.org/publicdomain/zero/1.0

declare -g TARGET=""
declare -gi MAX_RECURSE="0"
declare -gi HELP_NEEDED="0"
declare -gi EXTRACT_JARS="1"
declare -gi EXTRACT_WARS="1"
declare -gi EXTRACT_EARS="1"

set -euo pipefail

function main() {
  initialize_script
  parse_arguments "$@"
  check_arguments
  if [[ "${MAX_RECURSE}" -eq "0" ]]; then
    unzip_infinite
  else
    unzip_max_recurse_times
  fi
}

function initialize_script() {
  trap error_trap ERR
}

function error_trap() {
  echo "ERROR: jar_to_dir.sh"
  exit 2
}

function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    local key="${1}"
    case "${key}" in
    -h | --help)
      HELP_NEEDED=1
      shift
      ;;
    -m | --max-recurse)
      MAX_RECURSE="${2}"
      shift
      shift
      ;;
    -1 | --once)
      MAX_RECURSE="1"
      shift
      ;;
    -j | --jars)
      EXTRACT_JARS="1"
      shift
      ;;
    -J | --no-jars)
      EXTRACT_JARS="0"
      shift
      ;;
    -w | --wars)
      EXTRACT_WARS="1"
      shift
      ;;
    -W | --no-wars)
      EXTRACT_WARS="0"
      shift
      ;;
    -e | --ears)
      EXTRACT_EARS="1"
      shift
      ;;
    -E | --no-ears)
      EXTRACT_EARS="0"
      shift
      ;;
    # split combined short options
    -*)
      local combined="${1}"
      local split
      split="$(printf "%s" "${combined}" | cut -c 2- | sed 's/./-& /g' | tr -d '\n')"
      shift
      set -- ${split} "$@"
      ;;
    # positional argument
    *)
      TARGET="${1}"
      shift
      ;;
    esac
  done
}

function check_arguments() {
  if [[ -z "${TARGET}" || "${HELP_NEEDED}" == "1" ]]; then
    print_help
    exit 1
  fi
  if [[ ! ( -d "${TARGET}" || -f "${TARGET}" ) ]]; then
    echo "ERROR: ${TARGET} is not a file or directory."
    exit 1
  fi
  if [[ "${EXTRACT_JARS}" == 0 && "${EXTRACT_WARS}" == 0 && "${EXTRACT_EARS}" == 0 ]]; then
    echo "ERROR: must specify at least one of --jars, --wars or --ears."
    exit 1
  fi
}

function print_help() {
  echo "Usage: jar_to_dir.sh [options] <path>"
  echo "       jar_to_dir.sh [-m | --max-recurse <NUM>] [-1 | --once]"
  echo "                     [-j | --jars] [-J | --no-jars]"
  echo "                     [-w | --wars] [-W | --no-wars]"
  echo "                     [-e | --ears] [-E | --no-ears]"
  echo ""
  echo "Extract JAR/WAR/EAR files recursively."
  echo ""
  echo "  -h, --help               Print this help message"
  echo "  -m, --max-recurse NUM    Maximum recursion depth (0 is infinite; default: 0)"
  echo "  -1, --once               Equivalent to '--max-recurse 1'"
  echo "  -j, --jars               Extract JAR files (default)"
  echo "  -J, --no-jars            Don't extract JAR files"
  echo "  -w, --wars               Extract WAR files (default)"
  echo "  -W, --no-wars            Don't extract WAR files"
  echo "  -e, --ears               Extract EAR files (default)"
  echo "  -E, --no-ears            Don't extract EAR files"
}

function unzip_max_recurse_times() {
  for _ in $(seq 1 "${MAX_RECURSE}"); do
    if ! unzip_once; then
      return;
    fi
  done
}

function unzip_infinite() {
  while true; do
    if ! unzip_once; then
      return;
    fi
  done
}

function unzip_once() {
  local files_to_unzip
  readarray -d '' files_to_unzip < <(find_files_to_unzip)
  if [[ "${#files_to_unzip[@]}" -eq "0" ]]; then
    return 1
  fi
  for file_to_unzip in "${files_to_unzip[@]}"; do
    unzip_file "${file_to_unzip}"
  done
}

function find_files_to_unzip() {
  local file_pattern_opts=("-false") # initialize with always-false expression
  if [[ "${EXTRACT_JARS}" == "1" ]]; then
    file_pattern_opts+=("-or" "-iname" '*.jar')
  fi
  if [[ "${EXTRACT_WARS}" == "1" ]]; then
    file_pattern_opts+=("-or" "-iname" '*.war')
  fi
  if [[ "${EXTRACT_EARS}" == "1" ]]; then
    file_pattern_opts+=("-or" "-iname" '*.ear')
  fi
  find "${TARGET}" -type f -and "(" "${file_pattern_opts[@]}" ")" -print0
}

function unzip_file() {
  local target="${1}"
  local unzip_dir
  local real_target
  unzip_dir="$(mktemp -d)"
  real_target="$(realpath -- "${target}")"
  ( cd "${unzip_dir}" && jar -xf "${real_target}" )
  rm "${target}"
  mv "${unzip_dir}" "${target}"
}

main "$@"
