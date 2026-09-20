#!/usr/bin/env sh
set -eu

token_file='/runner-bootstrap/registration-token'
test -s "${token_file}"

REGISTRATION_TOKEN="$(cat "${token_file}")"
export REGISTRATION_TOKEN
exec peertube-runner bootstrap
