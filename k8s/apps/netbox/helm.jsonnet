local app = import 'app.json5';
local values = importstr 'values.yaml';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/netbox-community/netbox-chart/netbox',
  targetRevision: '8.3.18',
  values: (values),
}
