#!/usr/bin/bash
# use rsync to backup all files in a source dir to a targe dir
# when files are deleted from the source they are deleted from the target

set -euo pipefail

usage() {
  echo "Usage: $0 <source_dir> <target_dir>" >&2
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

source_dir="$1"
target_dir="$2"

if [[ ! -d "$source_dir" ]]; then
  echo "Error: source directory does not exist: $source_dir" >&2
  exit 1
fi

mkdir -p "$target_dir"

if ! command -v rsync >/dev/null 2>&1; then
  echo "Error: rsync is not installed or not in PATH." >&2
  exit 1
fi

rsync -avcrh --itemize-changes -HAX --partial --delete-delay --delete "${source_dir%/}/" "${target_dir%/}/"
