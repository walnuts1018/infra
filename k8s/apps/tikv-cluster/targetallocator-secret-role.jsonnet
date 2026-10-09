local app = import 'app.json5';

{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: 'prometheus-targetallocator-tikv-metrics-secrets',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['secrets'],
      resourceNames: [
        'tikv-cluster-pd-cluster-secret',
        'tikv-cluster-tikv-cluster-secret',
      ],
      verbs: ['get'],
    },
  ],
}
