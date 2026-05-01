#!/usr/bin/env bash
# Run `helm lint` against every chart. Used by the pre-commit `helm-lint` hook.
# `cd`s into each chart and lints `.` so this works when `helm` is a WSL /
# Rancher Desktop wrapper that mangles relative path arguments.
set -euo pipefail

cd "$(dirname "$0")/.."

shopt -s nullglob
charts=(charts/*/)
shopt -u nullglob

if [ ${#charts[@]} -eq 0 ]; then
  echo "No charts found under charts/."
  exit 0
fi

for c in "${charts[@]}"; do
  (cd "$c" && helm lint .)
done
