local app = import 'app.json5';
local role = import 'role-learning.jsonnet';
local serviceAccount = import 'service-account-learning.jsonnet';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: role.metadata.name,
    namespace: app.namespace,
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: role.kind,
    name: role.metadata.name,
  },
  subjects: [{
    kind: serviceAccount.kind,
    name: serviceAccount.metadata.name,
    namespace: serviceAccount.metadata.namespace,
  }],
}
