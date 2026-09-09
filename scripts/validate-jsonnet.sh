#!/usr/bin/env bash

set -euo pipefail

check_only=false
if [[ "${1:-}" == "--check-only" ]]; then
  check_only=true
fi

status=0
while IFS= read -r -d '' file; do
  if ! output=$(jsonnet "$file"); then
    status=1
    continue
  fi

  if [[ "$check_only" == "true" ]]; then
    continue
  fi

  if ! printf '%s\n' "$output" | jq -c 'if type == "array" then .[] else . end' | kubeconform -ignore-missing-schemas -strict -summary -; then
    status=1
  fi
done < <(find k8s -name '*.jsonnet' -type f -print0)

exit "$status"
