function(app, useSuffix=true) (import '../../../configmap.libsonnet') {
  name: app.name + '-plans',
  namespace: app.namespace,
  use_suffix: useSuffix,
  labels: (import '../../../labels.libsonnet')(app.name),
  data: {
    'plans.yaml': (importstr 'data.yaml'),
  },
}
