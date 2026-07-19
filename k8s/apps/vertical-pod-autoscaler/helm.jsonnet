local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'vertical-pod-autoscaler',
  repoURL: 'https://kubernetes.github.io/autoscaler',
  targetRevision: '0.10.0',
  valuesObject: std.parseYaml(importstr 'values.yaml'),
}
