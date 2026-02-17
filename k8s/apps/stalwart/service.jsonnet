{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    selector: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: 8080,
        targetPort: 8080,
      },
      {
        name: 'https',
        protocol: 'TCP',
        port: 443,
        targetPort: 443,
      },
      {
        name: 'smtp',
        protocol: 'TCP',
        port: 25,
        targetPort: 25,
      },
      {
        name: 'submission',
        protocol: 'TCP',
        port: 587,
        targetPort: 587,
      },
      {
        name: 'smtps',
        protocol: 'TCP',
        port: 465,
        targetPort: 465,
      },
      {
        name: 'imap',
        protocol: 'TCP',
        port: 143,
        targetPort: 143,
      },
      {
        name: 'imaps',
        protocol: 'TCP',
        port: 993,
        targetPort: 993,
      },
      {
        name: 'sieve',
        protocol: 'TCP',
        port: 4190,
        targetPort: 4190,
      },
    ],
    type: 'ClusterIP',
  },
}
