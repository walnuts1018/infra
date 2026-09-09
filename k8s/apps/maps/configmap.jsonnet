local app = import 'app.json5';

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
      src: http://127.0.0.1:8081/maps/osm-landcover.versatiles
|||;

(import '../../components/configmap.libsonnet') {
  name: app.name + '-versatiles-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-versatiles-server'),
  data: {
    'config.yaml': config,
  },
}
