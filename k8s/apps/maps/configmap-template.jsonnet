local app = import 'app.json5';
local configName = (import 'configmap-name.libsonnet').name;

// update-cronjobのrender-configステップがgomplateでこのテンプレートを展開し、
// presigned URL(/work/presigned-url、presignステップの出力)を埋め込んだ
// ConfigMapマニフェスト全体を生成する。テンプレート自体は静的な内容なのでGit管理する。
local template = |||
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: %(configName)s
    namespace: %(namespace)s
  data:
    config.yaml: |
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
          src: {{ (file.Read "/work/presigned-url") | strings.TrimSpace }}
||| % { configName: configName, namespace: app.namespace };

(import '../../components/configmap.libsonnet') {
  name: app.name + '-configmap-template',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-update'),
  data: {
    'configmap.yaml.tmpl': template,
  },
}
