#!/usr/bin/env bash

set -euo pipefail

status=0
namespace_json=$(jsonnet -e 'import "k8s/namespaces/namespaces.json5"')
rendered_helm_dir=$(mktemp -d)
trap 'rm -f "${rendered_helm_dir}"/*; rmdir "${rendered_helm_dir}"' EXIT

if ! find k8s/_argocd -name '*.yaml' -type f ! -name 'values*.yaml' ! -name 'apps.yaml' ! -name 'apps-private.yaml' ! -name 'clusters.yaml' -print0 | xargs -0 kubeconform -ignore-missing-schemas -strict -summary >/dev/null; then
  echo "invalid Argo CD YAML" >&2
  status=1
fi

validate_app() {
  local file="$1"
  local directory
  local app_json
  local namespace
  local value_file
  local repo_url
  local chart
  local version
  local cluster
  local helm_ref
  local rendered_helm
  local -a base_value_files

  directory=$(dirname "$file")
  if ! app_json=$(jsonnet "$file"); then
    echo "invalid app descriptor: ${file}" >&2
    return 1
  fi

  if ! namespace=$(jq -er '.namespace' <<<"${app_json}"); then
    echo "app descriptor has no namespace: ${file}" >&2
    return 1
  fi
  if ! jq -e --arg namespace "$namespace" 'index($namespace) != null' <<<"${namespace_json}" >/dev/null; then
    echo "app namespace is missing from k8s/namespaces/namespaces.json5: ${file}: ${namespace}" >&2
    return 1
  fi

  if [[ "$(jq -r '.additionalSources.helm // empty' <<<"${app_json}")" == "" ]]; then
    return 0
  fi

  repo_url=$(jq -er '.additionalSources.helm.repoURL' <<<"${app_json}")
  chart=$(jq -er '.additionalSources.helm.chart' <<<"${app_json}")
  version=$(jq -er '.additionalSources.helm.targetRevision' <<<"${app_json}")
  base_value_files=()
  while IFS= read -r value_file; do
    [[ -z "$value_file" ]] || base_value_files+=("${value_file}")
  done < <(jq -r '.additionalSources.helm.valueFiles[]?' <<<"${app_json}")

  for value_file in "${base_value_files[@]}"; do
    if [[ "$value_file" == /* || "$value_file" == *".."* ]] || [[ ! -f "${directory}/${value_file}" ]]; then
      echo "Helm value file is missing: ${file}: ${value_file}" >&2
      return 1
    fi
  done

  if [[ "$repo_url" == oci://* ]]; then
    helm_ref="${repo_url}/${chart}"
  elif [[ "$repo_url" != https://* && "$repo_url" != http://* ]]; then
    helm_ref="oci://${repo_url}/${chart}"
  else
    helm_ref="$chart"
  fi

  while IFS= read -r cluster; do
    [[ -z "$cluster" ]] && continue
    local -a cluster_value_files
    cluster_value_files=("${base_value_files[@]}")
    while IFS= read -r value_file; do
      [[ -z "$value_file" ]] || cluster_value_files+=("${value_file}")
    done < <(jq -r --arg cluster "$cluster" '.clusters[$cluster].additionalSources.helm.additionalValueFiles[]?' <<<"${app_json}")
    for value_file in "${cluster_value_files[@]}"; do
      if [[ "$value_file" == /* || "$value_file" == *".."* ]] || [[ ! -f "${directory}/${value_file}" ]]; then
        echo "Helm value file is missing: ${file}: ${value_file}" >&2
        return 1
      fi
    done
    local -a helm_args
    helm_args=(template "${cluster}-${chart}" "$helm_ref" --namespace "$namespace" --version "$version")
    if [[ "$helm_ref" == "$chart" ]]; then
      helm_args+=(--repo "$repo_url")
    fi
    for value_file in "${cluster_value_files[@]}"; do
      helm_args+=(--values "${directory}/${value_file}")
    done
    rendered_helm="${rendered_helm_dir}/$(basename "${file}").${cluster}.yaml"
    if ! helm "${helm_args[@]}" --include-crds >"${rendered_helm}"; then
      echo "Helm rendering failed: ${file} (${cluster})" >&2
      return 1
    fi

    case "${file}" in
      k8s/apps/cert-manager/app.json5)
        for crd in certificates.cert-manager.io clusterissuers.cert-manager.io; do
          grep -Eq "name: \"?${crd}\"?" "${rendered_helm}" || {
            echo "cert-manager chart does not render required CRD ${crd}: ${file}" >&2
            return 1
          }
        done
        ;;
      k8s/apps/external-secrets/app.json5)
        for crd in externalsecrets.external-secrets.io clustersecretstores.external-secrets.io; do
          grep -Eq "name: \"?${crd}\"?" "${rendered_helm}" || {
            echo "external-secrets chart does not render required CRD ${crd}: ${file}" >&2
            return 1
          }
        done
        ;;
    esac
  done < <(jq -r '.clusters // {} | keys[]' <<<"${app_json}")
}

while IFS= read -r -d '' file; do
  if ! validate_app "$file"; then
    status=1
  fi
done < <(find k8s/apps -name app.json5 -type f -print0)

check_app_wave() {
  local file="$1"
  local expected="$2"
  local actual

  actual=$(jsonnet "${file}" | jq -er '.annotations["argocd.argoproj.io/sync-wave"]') || {
    echo "bootstrap app has no sync wave: ${file}" >&2
    status=1
    return
  }
  if [[ "${actual}" != "${expected}" ]]; then
    echo "unexpected bootstrap sync wave: ${file}: ${actual} (expected ${expected})" >&2
    status=1
  fi
}

check_app_wave k8s/apps/cert-manager/app.json5 -5
check_app_wave k8s/apps/external-secrets/app.json5 -5
check_app_wave k8s/apps/cluster-api-operator/app.json5 -4
check_app_wave k8s/apps/clusterissuer/app.json5 -3

check_jsonnet_wave() {
  local file="$1"
  local expected="$2"
  local actual

  actual=$(jsonnet "${file}" | jq -er '.metadata.annotations["argocd.argoproj.io/sync-wave"]') || {
    echo "bootstrap resource has no sync wave: ${file}" >&2
    status=1
    return
  }
  if [[ "${actual}" != "${expected}" ]]; then
    echo "unexpected bootstrap resource sync wave: ${file}: ${actual} (expected ${expected})" >&2
    status=1
  fi
}

check_jsonnet_wave k8s/clusters/biscuit/cilium-helmchartproxy.jsonnet 20
check_jsonnet_wave k8s/clusters/biscuit/argocd-spoke-helmchartproxy.jsonnet 21
check_jsonnet_wave k8s/clusters/biscuit/argocd-agent-clusterresourceset.jsonnet 22
check_jsonnet_wave k8s/clusters/biscuit/argocd-agent-resources-externalsecret.jsonnet 22
check_jsonnet_wave k8s/clusters/biscuit/argocd-agent-helmchartproxy.jsonnet 23

for file in \
  k8s/_argocd/applications/berry/apps.yaml \
  k8s/_argocd/applications/biscuit/apps.yaml \
  k8s/_argocd/applications/kurumi/apps.yaml \
  k8s/_argocd/applications/kurumi/apps-private.yaml; do
  grep -q 'CreateNamespace=true' "$file" || { echo "CreateNamespace is missing: ${file}" >&2; status=1; }
  grep -q 'preserveResourcesOnDeletion: true' "$file" || { echo "resource preservation is missing: ${file}" >&2; status=1; }
  grep -q 'values\*\.yaml' "$file" || { echo "values.yaml is not excluded: ${file}" >&2; status=1; }
done

if rg -n '^  ignoreApplicationDifferences:' k8s/_argocd/applications >/dev/null; then
  echo "ApplicationSet syncPolicy differences must not be ignored" >&2
  status=1
fi

if rg -n '"resources"' k8s/apps/seaweedfs-biscuit/external-secret.jsonnet >/dev/null; then
  echo "SeaweedFS biscuit IAM resources must be encoded in actions" >&2
  status=1
fi

grep -q "reconcileStrategy: 'InstallOnce'" k8s/clusters/biscuit/cilium-helmchartproxy.jsonnet || {
  echo "biscuit Cilium is not an InstallOnce bootstrap" >&2
  status=1
}
grep -q "reconcileStrategy: 'InstallOnce'" k8s/clusters/biscuit/argocd-spoke-helmchartproxy.jsonnet || {
  echo "biscuit Argo CD Spoke is not an InstallOnce bootstrap" >&2
  status=1
}
grep -q "reconcileStrategy: 'InstallOnce'" k8s/clusters/biscuit/argocd-agent-helmchartproxy.jsonnet || {
  echo "biscuit Argo CD Agent is not an InstallOnce bootstrap" >&2
  status=1
}

exit "$status"
