{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    policyTypes: [
      'Ingress',
    ],
    ingress: [
      {
        from: [
          {
            ipBlock: {
              cidr: '192.168.0.0/16',
            },
          },
        ],
      },
    ],
  },
}
