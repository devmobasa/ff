#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd -P)"
readonly BIN_DIR="${HOME}/.local/bin"
mkdir -p -- "$BIN_DIR"

for command_name in ff fft; do
  link_path="$BIN_DIR/$command_name"
  target="$REPO_DIR/$command_name"

  if [[ -e $link_path || -L $link_path ]]; then
    existing=$(readlink -f -- "$link_path" 2>/dev/null || true)
    if [[ $existing != "$target" ]]; then
      printf 'install: refusing to replace existing %s\n' "$link_path" >&2
      exit 1
    fi
  fi

  ln -sfn -- "$target" "$link_path"
  printf 'Installed %s -> %s\n' "$command_name" "$target"
done
