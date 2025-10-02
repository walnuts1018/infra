{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: 'kurumi-api-server',
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.envoyproxy.io',
        kind: 'Backend',
        name: (import 'backend.jsonnet').metadata.name,
        sectionName: '443',
      },
    ],
    validation: {
      caCertificateRefs: [
        {
          group: '',
          kind: 'ConfigMap',
          name: (import 'configmap-ca.jsonnet').metadata.name,
        },
      ],
      hostname: 'kubernetes.default.svc.cluster.local',
    },
  },
}
