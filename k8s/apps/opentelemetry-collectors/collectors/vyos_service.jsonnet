{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'vyos-collector-ingest',
  },
  spec: {
    selector: {
      'app.kubernetes.io/component': 'collector',
      'app.kubernetes.io/name': 'vyos-collector',
    },
    ports: [
      {
        name: 'syslog-udp',
        port: 514,
        targetPort: 5514,
        protocol: 'UDP',
      },
      {
        name: 'netflow-udp',
        port: 2055,
        targetPort: 2055,
        protocol: 'UDP',
      },
    ],
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.136',
  },
}
