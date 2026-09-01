// Picca basemap生成(Planetiler custom schema)。
//
// picca リポジトリの tools/basemap/schema.yml のコピーを保持する。infra側のCIは
// picca リポジトリをcheckoutしないため、cross-repo importstrはできず、この
// コピーを手動(または将来的にはCIで)同期する運用とする。schema.ymlを変更したら、
// このファイルも同じ内容へ更新すること。
local app = import '../app.json5';
local schema = importstr './basemap-schema.yml';
(import '../../../components/configmap.libsonnet') {
  name: app.name + '-basemap-schema',
  namespace: app.namespace,
  labels: (import '../../../components/labels.libsonnet')(app.name + '-basemap-schema'),
  data: {
    'schema.yml': schema,
  },
}
