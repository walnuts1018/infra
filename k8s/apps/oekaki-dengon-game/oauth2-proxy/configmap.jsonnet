(import '../../../components/configmap.libsonnet') {
  name: (import '../app.json5').name + '-oauth2-proxy',
  namespace: (import '../app.json5').namespace,
  labels: (import '../../../components/labels.libsonnet')((import '../app.json5').name),
  data: {
    'robots.txt': (importstr './config/robots.txt'),
  },
}
