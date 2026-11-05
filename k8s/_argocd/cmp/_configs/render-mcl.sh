#!/bin/sh
set -eu

mcl_cluster_name=${ARGOCD_ENV_MCL_CLUSTER_NAME:-}
mcl_deployment_json=${ARGOCD_ENV_MCL_DEPLOYMENT_JSON:-}
k8s_root=$(pwd)
while [ ! -f "$k8s_root/mcl.toml" ]; do
  parent_dir=$(dirname "$k8s_root")
  [ "$parent_dir" != "$k8s_root" ] || { echo 'Could not find k8s/mcl.toml from the application source directory.' >&2; exit 1; }
  k8s_root=$parent_dir
done
lock_file="$k8s_root/mcl.lock"
case "$mcl_cluster_name" in
  ''|*[!a-z0-9-]*) echo 'MCL_CLUSTER_NAME must be a lowercase cluster name.' >&2; exit 1 ;;
esac
command -v jq >/dev/null 2>&1 || { echo 'jq is required to resolve cluster facts and MCL parameters.' >&2; exit 1; }
cluster_file="$k8s_root/clusters/$mcl_cluster_name/cluster.json"
[ -r "$cluster_file" ] || { echo "Cluster definition not found: $cluster_file" >&2; exit 1; }
cluster_parameters=$(jq -ce '{name, namespace, kubernetesVersion} | select(.name != null and .namespace != null and .kubernetesVersion != null)' "$cluster_file")
deployment_parameters=$(printf '%s' "$mcl_deployment_json" | jq -ce 'if type != "object" then error("deployment parameters must be an object") elif has("namespace") then error("namespace is app-wide; per-deployment namespace overrides are unsupported") else . end')
parameters=$(jq -cn --argjson cluster "$cluster_parameters" --argjson deployment "$deployment_parameters" '$deployment + {cluster: $cluster}')
mcl_version=$(sed -n '/"toolchain"[[:space:]]*:/,/^[[:space:]]*}/ s/^[[:space:]]*"mcl":[[:space:]]*"\([0-9][0-9A-Za-z.+-]*\)".*/\1/p' "$lock_file")
mcl_revision=$(sed -n '/"toolchain"[[:space:]]*:/,/^[[:space:]]*}/ s/^[[:space:]]*"revision":[[:space:]]*"\([0-9a-f]*\)".*/\1/p' "$lock_file")
case "$mcl_version" in
  ''|*[!0-9A-Za-z.+-]*) echo 'Could not read a valid MCL version from k8s/mcl.lock.' >&2; exit 1 ;;
esac
case "$mcl_revision" in
  ''|*[!0-9a-f]*) echo 'Could not read a valid MCL revision from k8s/mcl.lock.' >&2; exit 1 ;;
esac
[ "${#mcl_revision}" -eq 40 ] || { echo 'Could not read a valid MCL revision from k8s/mcl.lock.' >&2; exit 1; }

case "$(uname -m)" in
  x86_64|amd64) mcl_arch=amd64 ;;
  aarch64|arm64) mcl_arch=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
cache_dir="/tmp/mcl-cli/$mcl_version-$mcl_revision-$mcl_arch"
mcl="$cache_dir/mcl"
if [ ! -x "$mcl" ]; then
  mkdir -p /tmp/mcl-cli
  download_dir=$(mktemp -d "/tmp/mcl-cli/.${mcl_version}-${mcl_revision}-${mcl_arch}.XXXXXX")
  cleanup_download() { rm -rf "$download_dir"; }
  trap cleanup_download EXIT HUP INT TERM
  archive="mcl_${mcl_version}_linux_${mcl_arch}.tar.gz"
  release_url="https://github.com/manifest-configuration-language/mcl/releases/download/v${mcl_version}"
  curl -fsSL "$release_url/SHA256SUMS" -o "$download_dir/SHA256SUMS"
  curl -fsSL "$release_url/$archive" -o "$download_dir/$archive"
  expected_hash=$(awk -v file="$archive" '$2 == file { print $1 }' "$download_dir/SHA256SUMS")
  if [ "$(printf '%s\n' "$expected_hash" | wc -l | tr -d ' ')" -ne 1 ] || [ -z "$expected_hash" ]; then
    echo "Release SHA256SUMS does not contain exactly one entry for $archive." >&2
    exit 1
  fi
  printf '%s  %s\n' "$expected_hash" "$download_dir/$archive" | sha256sum -c -
  tar -xzf "$download_dir/$archive" -C "$download_dir" mcl
  chmod 0755 "$download_dir/mcl"
  case "$("$download_dir/mcl" version)" in
    "mcl $mcl_version (revision $mcl_revision, modified false)") ;;
    *) echo 'Downloaded MCL CLI does not match k8s/mcl.lock.' >&2; exit 1 ;;
  esac
  mkdir -p "$cache_dir"
  if [ ! -x "$mcl" ]; then mv "$download_dir/mcl" "$mcl"; fi
  cleanup_download
  trap - EXIT HUP INT TERM
fi
case "$($mcl version)" in
  "mcl $mcl_version (revision $mcl_revision, modified false)") ;;
  *) echo 'Downloaded MCL CLI does not match k8s/mcl.lock.' >&2; exit 1 ;;
esac

backup_file=$(mktemp)
cp -p "$lock_file" "$backup_file"
parameter_file=$(mktemp)
printf '%s\n' "$parameters" > "$parameter_file"
restore_lock() {
  cp -p "$backup_file" "$lock_file"
  rm -f "$backup_file"
  rm -f "$parameter_file"
}
trap restore_lock EXIT
trap 'exit 1' HUP INT TERM
"$mcl" update main.mcl --parameter-file "$parameter_file"
if ! cmp -s "$backup_file" "$lock_file"; then
  echo 'MCL dependency update changed k8s/mcl.lock; refusing to render with an unreviewed lock.' >&2
  exit 1
fi
"$mcl" render main.mcl --format yaml --parameter-file "$parameter_file"
