{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: (import 'app.json5').name + '-sts',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    targetRefs: [
      {
        group: '',
        kind: 'Service',
        name: 'sts',
        sectionName: 'https',
      },
    ],
    validation: {
      caCertificateRefs: [
        {
          group: '',
          kind: 'Secret',
          name: (import '../clusterissuer/local-issuer.jsonnet').spec.ca.secretName,
        },
      ],
      hostname: 'sts.minio-operator.svc.cluster.local',
    },
  },
}
