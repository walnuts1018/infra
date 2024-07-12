#!/bin/bash

set -e

declare -A namespaces=(
    ["default"]=1
)

rm -rf ./k8s/namespaces
mkdir -p ./k8s/namespaces

ls ./k8s/apps/ | while read line; do
    kustomize build ./k8s/apps/$line | egrep -o 'namespace: [a-z0-9\.\-]+' | cut -d ' ' -f 2 | while read namespace; do
        if [ -z "$namespace" ]; then
            continue
        fi
        namespaces[$namespace]=1
    done
done

cat <<EOF | tee ./k8s/namespaces/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

for namespace in "${!namespaces[@]}"; do
    cat <<EOF | tee ./k8s/namespaces/$namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
EOF
    echo "  - $namespace.yaml" >>./k8s/namespaces/kustomization.yaml
done
