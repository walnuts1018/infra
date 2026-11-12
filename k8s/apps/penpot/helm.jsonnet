local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'penpot',
  repoURL: 'https://helm.penpot.app/',
  targetRevision: '1.12.0',
  values: (importstr 'values.yaml'),
}
