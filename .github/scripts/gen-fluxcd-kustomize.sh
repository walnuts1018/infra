#!/bin/bash

set -e

ls ./k8s/apps/ | while read line; do
    cat <<EOF | tee ./k8s/_flux/kurumi/$line.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: $line
  namespace: flux-system
spec:
  interval: 1m0s
  path: ./k8s/apps/$line
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
    namespace: flux-system
EOF
done
