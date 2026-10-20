local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/netbox-community/netbox-chart/netbox',
  targetRevision: '8.3.93',
  values: (importstr 'values.yaml'),
}
