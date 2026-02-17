#!/usr/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 <source_dir> <target_dir> [backups_to_keep]" >&2
  exit 1
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
fi

source_dir="$1"
target_dir="$2"
backups_to_keep="${3:-${BACKUPS_TO_KEEP:-7}}"

cleanup_old_archives() {
  local archive_prefix="$1"
  local keep_count="$2"
  local -a archives=()
  local -a sorted_archives=()
  local i

  shopt -s nullglob
  archives=( "${target_dir%/}/${archive_prefix}"_*.tar.xz )
  shopt -u nullglob

  if (( ${#archives[@]} <= keep_count )); then
    return
  fi

  readarray -t sorted_archives < <(ls -1t -- "${archives[@]}")

  for ((i = keep_count; i < ${#sorted_archives[@]}; i++)); do
    rm -f -- "${sorted_archives[$i]}"
  done
}

if [[ ! -d "$source_dir" ]]; then
  echo "Error: source directory does not exist: $source_dir" >&2
  exit 1
fi

if ! [[ "$backups_to_keep" =~ ^[0-9]+$ ]] || [[ "$backups_to_keep" -lt 1 ]]; then
  echo "Error: backups_to_keep must be a positive integer." >&2
  exit 1
fi

mkdir -p "$target_dir"

if ! command -v tar >/dev/null 2>&1; then
  echo "Error: tar is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v xz >/dev/null 2>&1; then
  echo "Error: xz is not installed or not in PATH." >&2
  exit 1
fi

source_parent="$(dirname "${source_dir%/}")"
source_base="$(basename "${source_dir%/}")"
timestamp="$(date '+%Y%m%d_%H%M%S')"
archive_path="${target_dir%/}/${source_base}_${timestamp}.tar.gz"

tar -cvf - -C "$source_parent" "$source_base" | xz -z9 -T0 > "$archive_path"
cleanup_old_archives "$source_base" "$backups_to_keep"
