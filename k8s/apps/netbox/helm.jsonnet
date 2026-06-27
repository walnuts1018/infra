local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
(helm) {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/netbox-community/netbox-chart/netbox',
  targetRevision: '8.3.18',
  values: (values),
}
