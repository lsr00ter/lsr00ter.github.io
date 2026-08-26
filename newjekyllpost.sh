#!/usr/bin/env bash
set -euo pipefail

if (( $# == 0 )); then
  echo "Usage: $(basename "$0") TITLE" >&2
  exit 64
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$repo_dir"

exec bundle exec jekyll post "$*"
