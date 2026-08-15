#!/usr/bin/env bash

set -euo pipefail

readonly REPO_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd -P)"
readonly WORKER="$REPO_DIR/libexec/ff-worker"
test_home="$(mktemp -d)"

cleanup() {
  [[ -z $test_home ]] || rm -rf -- "$test_home"
}

trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

bash -n "$REPO_DIR/ff" "$REPO_DIR/fft" "$WORKER" "$REPO_DIR/install.sh" "$0"

success_output=$(FF_NO_NOTIFY=1 "$WORKER" ff-test-success "printf success" -- printf '%s\n' success)
[[ $success_output == *success* ]] || fail "worker did not preserve stdout"
[[ $success_output == *'exit status: 0'* ]] || fail "worker did not report success"

set +e
failure_output=$(FF_NO_NOTIFY=1 "$WORKER" ff-test-failure "exit 7" -- bash -c 'exit 7' 2>&1)
failure_status=$?
set -e
[[ $failure_status == 7 ]] || fail "worker returned $failure_status instead of 7"
[[ $failure_output == *'exit status: 7'* ]] || fail "worker did not report failure"

argument_output=$(FF_NO_NOTIFY=1 "$WORKER" ff-test-args "argument test" -- printf '<%s>\n' 'space value' '$literal')
[[ $argument_output == *'<space value>'* ]] || fail "spaced argument was changed"
[[ $argument_output == *'<$literal>'* ]] || fail "dollar argument was expanded"

worker_log="$test_home/worker.log"
FF_NO_NOTIFY=1 FF_LOG_FILE=$worker_log "$WORKER" fft-test-log "log test" -- printf 'logged\n' >/dev/null
[[ $(<"$worker_log") == *logged* ]] || fail "terminal worker log was not written"

HOME=$test_home "$REPO_DIR/install.sh" >/dev/null
[[ -L $test_home/.local/bin/ff ]] || fail "installer did not create the ff symlink"
[[ $(readlink -f -- "$test_home/.local/bin/ff") == "$REPO_DIR/ff" ]] || fail "installer linked the wrong target"
[[ -L $test_home/.local/bin/fft ]] || fail "installer did not create the fft symlink"
[[ $(readlink -f -- "$test_home/.local/bin/fft") == "$REPO_DIR/fft" ]] || fail "installer linked the wrong fft target"

printf 'All tests passed.\n'
