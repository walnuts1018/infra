local app = import 'app.json5';
local clusterRole = import 'cluster-role.jsonnet';
local serviceAccount = import 'service-account.jsonnet';

{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: app.name,
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: clusterRole.kind,
    name: clusterRole.metadata.name,
  },
  subjects: [
    {
      kind: serviceAccount.kind,
      name: serviceAccount.metadata.name,
      namespace: serviceAccount.metadata.namespace,
    },
  ],
}
