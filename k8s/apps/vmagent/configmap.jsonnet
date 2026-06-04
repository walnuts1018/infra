{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'vmagent-victoria-metrics-stream-aggr',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  data: {
    'stream-aggr-longterm.yaml': (importstr './_config/stream-aggr-longterm.yaml'),
  },
}
