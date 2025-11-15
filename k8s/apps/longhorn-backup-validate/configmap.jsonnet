(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-manifests',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  data: {
    'kustomization.yaml': (importstr './_manifest/kustomization.yaml'),
    'resources.yaml': (importstr './_manifest/resources.yaml'),
  },
}
