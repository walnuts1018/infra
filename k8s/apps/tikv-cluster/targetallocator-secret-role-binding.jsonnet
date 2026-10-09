local targetAllocatorApp = import '../opentelemetry-collectors/app.json5';
local targetAllocatorServiceAccount = import '../opentelemetry-collectors/prometheus/targetallocator-sa.jsonnet';
local app = import 'app.json5';
local role = import 'targetallocator-secret-role.jsonnet';

{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: role.metadata.name,
    namespace: app.namespace,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: targetAllocatorServiceAccount.metadata.name,
      namespace: targetAllocatorApp.namespace,
    },
  ],
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'Role',
    name: role.metadata.name,
  },
}
