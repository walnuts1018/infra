{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'vyos-collector-ingest',
  },
  spec: {
    selector: {
      'app.kubernetes.io/component': 'opentelemetry-collector',
      'app.kubernetes.io/instance': 'opentelemetry-collector.vyos',
      'app.kubernetes.io/part-of': 'opentelemetry',
    },
    ports: [
      {
        name: 'syslog-udp',
        port: 514,
        targetPort: 5514,
        protocol: 'UDP',
      },
    ],
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.136',
  },
}
