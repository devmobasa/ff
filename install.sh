#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd -P)"
readonly BIN_DIR="${HOME}/.local/bin"
readonly LINK_PATH="$BIN_DIR/ff"
readonly TARGET="$REPO_DIR/ff"

mkdir -p -- "$BIN_DIR"

if [[ -e $LINK_PATH || -L $LINK_PATH ]]; then
  existing=$(readlink -f -- "$LINK_PATH" 2>/dev/null || true)
  if [[ $existing != "$TARGET" ]]; then
    printf 'install: refusing to replace existing %s\n' "$LINK_PATH" >&2
    exit 1
  fi
fi

ln -sfn -- "$TARGET" "$LINK_PATH"
printf 'Installed ff -> %s\n' "$TARGET"

