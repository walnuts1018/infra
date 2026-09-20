local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-runner-vod-config',
  namespace: app.namespace,
  data: {
    'config.toml': importstr './_config/runner-config.toml',
  },
}
