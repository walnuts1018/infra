(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  ociChartURL: 'ghcr.io/netbox-community/netbox-chart/netbox',
  targetRevision: '8.3.16',
  values: (importstr 'values.yaml'),
}
