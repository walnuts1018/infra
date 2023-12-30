# helm component

## Contents

- helm repository skeleton
- helm release skeleton

## Example usage

- helm-overlay.yaml

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: repo
spec:
  url: https://charts.jetstack.io
---
apiVersion: helm.toolkit.fluxcd.io/v2beta2
kind: HelmRelease
metadata:
  name: release
spec:
  chart:
    spec:
      chart: cert-manager
      version: 1.5.3
  values:
    installCRDs: true
```

- kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namePrefix: cert-manager-
components:
  - ../../components/helm
patchesStrategicMerge:
  - helm-overlay.yaml
```
