local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'external-dns',
  repoURL: 'https://kubernetes-sigs.github.io/external-dns/',
  targetRevision: '1.21.1',
  values: (values),
}
