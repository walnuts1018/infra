local app = import '../app.json5';
// Martin(https://github.com/maplibre/martin)のconfig。SeaweedFS S3上のPMTiles
// (basemap-generate CronJobが配置する`basemap/basemap.pmtiles`)をremote prefixとして
// 定期リストし、ETag/Last-Modifiedの変化を検出してホットリロードする(Pod再起動不要)。
// docs/tasks/00291-map.md 8章参照。
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
