{
  apiVersion: 'cf-tunnel-operator.walnuts.dev/v1beta1',
  kind: 'CloudflareTunnel',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name, 'cf-tunnel-operator.walnuts.dev/default': 'true' },
  },
  spec: {
    replicas: 3,
    default: true,
    enableServiceMonitor: true,
  },
}
