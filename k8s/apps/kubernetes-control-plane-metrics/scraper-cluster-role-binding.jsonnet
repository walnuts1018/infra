local app = import 'app.json5';
local role = import 'scraper-cluster-role.jsonnet';
local serviceAccount = import 'scraper-service-account.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: role.metadata.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: serviceAccount.metadata.name,
      namespace: app.namespace,
    },
  ],
  roleRef: {
    kind: 'ClusterRole',
    name: role.metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
