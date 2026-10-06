local app = import '../app.json5';

{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: 'otel-prometheus-targetallocator-secrets',
    namespace: app.namespace,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'targetallocator-sa.jsonnet').metadata.name,
      namespace: app.namespace,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: (import 'secret-role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
