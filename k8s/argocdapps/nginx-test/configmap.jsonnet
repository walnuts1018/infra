{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'nginx-test-conf',
    labels: (import 'app.libsonnet').labels,
  },
  data: {
    'nginx.conf': (importstr 'nginx.conf'),
    'virtualhost.conf': (importstr 'virtualhost.conf'),
  },
}
