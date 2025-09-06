{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  data: {
    'windows.ipxe': (importstr './config/windows.ipxe'),
    'ubuntu.ipxe': (importstr './config/ubuntu.ipxe'),
  },
}
