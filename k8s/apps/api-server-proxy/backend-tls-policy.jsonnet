{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    targetRefs: [
      {
        kind: 'Service',
        name: 'kubernetes',
      },
    ],
    validation: {
      caCertificateRefs: [
        {
          group: '',
          kind: 'ConfigMap',
          name: 'kube-root-ca.crt',
        },
      ],
      hostname: 'kubernetes.default.svc.cluster.local',
    },
  },
}
