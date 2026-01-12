{
  config: (import '../../components/configmap.libsonnet') {
    name: (import 'app.json5').name + '-test',
    namespace: (import 'app.json5').namespace,
    data: {
      test: 'test',
    },
  },
}
