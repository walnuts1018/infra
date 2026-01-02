(import '../../components/configmap.libsonnet') {
  name: 'cmp-tanka',
  namespace: (import 'app.json5').namespace,
  use_suffix:: false,
  labels: {
    'app.kubernetes.io/part-of': 'argocd',
  },
  data: {
    'plugin.yaml': (importstr './_config/plugin-tanka.yaml'),
  },
}
