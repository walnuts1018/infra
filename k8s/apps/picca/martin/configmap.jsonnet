local app = import '../app.json5';
local config = |||
  pmtiles:
    paths:
      - s3://picca/basemap/
    reload_interval: 10m
  web_ui: disable
  tilejson_url_version_param: version
|||;

(import '../../../components/configmap.libsonnet') {
  name: app.name + '-martin-config',
  namespace: app.namespace,
  labels: (import '../../../components/labels.libsonnet')(app.name + '-martin'),
  data: {
    'config.yaml': config,
  },
}
