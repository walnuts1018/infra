{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'vyos-collector-ingest',
    annotations: {
      'lbipam.cilium.io/ips': '192.168.12.136',
    },
  },
  spec: {
    loadBalancerSourceRanges: ['192.168.0.1/32'],
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
  },
}
