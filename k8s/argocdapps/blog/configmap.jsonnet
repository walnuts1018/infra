{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'blog-conf',
    namespace: (import 'app.libsonnet').namespace,
    labels: (import 'app.libsonnet').labels,
  },
  data: {
    'nginx.conf': (importstr './config/nginx.conf'),
    'virtualhost.conf': (importstr './config/virtualhost.conf'),
  },
}
