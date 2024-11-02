{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'samba',
    labels: {
      app: 'samba',
    },
  },
  spec: {
    ports: [
      {
        port: 445,
        protocol: 'TCP',
        targetPort: 10445,
      },
    ],
    selector: {
      app: 'samba',
    },
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.132',
  },
}
