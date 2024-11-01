{
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
        name: 'nginx-test-conf',
        labels: (import 'app.libsonnet').labels,
    }
    data: [
        'nginx.conf': (import 'nginx.conf'),
        'virtualhost.conf': (import 'virtualhost.conf'),
    ]
}
