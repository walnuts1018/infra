local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    targetRefs: [
      {
        group: '',
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
