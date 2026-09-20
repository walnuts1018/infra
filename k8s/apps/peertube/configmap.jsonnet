local app = import 'app.json5';

(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  data: {
    'production.yaml': (importstr './_config/production.yaml'),
  },
}
