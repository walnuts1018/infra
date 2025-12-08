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
          kind: 'ConfigMap',
          name: (import 'sts-ca-cert-configmap.jsonnet').metadata.name,  // TrustManagerがClusterBundleに対応したら、直接そちらを参照できるだろう
        },
      ],
      hostname: 'sts.minio-operator.svc.cluster.local',
    },
  },
}
