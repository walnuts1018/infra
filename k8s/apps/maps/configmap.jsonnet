local app = import 'app.json5';

// filerの素のHTTP(S3 APIではなくport 8888)を参照する。SeaweedFSのS3 IAM(desired-state.json)には
// 手を入れず、mapsバケットに匿名S3認証を許可する構成(既知のSeaweedFSバグでS3認証全体が
// 壊れるリスクがある)を避けるための設計。VersaTilesのtiles[].srcは認証ヘッダを持てないため、
// もともとS3署名リクエストはできない。
local config = |||
  server:
    ip: 0.0.0.0
    port: 8080
    cache_control: public, max-age=86400, no-transform

  cors:
    allowed_origins:
      - '*'
    max_age_seconds: 86400

  extra_response_headers:
    CDN-Cache-Control: max-age=604800

  tiles:
    - name: osm
      src: http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8888/buckets/maps/osm-landcover.versatiles
|||;

(import '../../components/configmap.libsonnet') {
  name: app.name + '-versatiles-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-versatiles-server'),
  data: {
    'config.yaml': config,
  },
}
