local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': app.name,
      },
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        ports: [
          {
            port: 8443,
            protocol: 'TCP',
          },
        ],
      },
      {
        ports: [
          {
            port: 8080,
            protocol: 'TCP',
          },
        ],
      },
    ],
  },
}
