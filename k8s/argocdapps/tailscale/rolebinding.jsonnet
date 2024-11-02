{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'RoleBinding',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import 'sa.jsonnet').metadata.name,
    },
  ],
  roleRef: {
    kind: 'Role',
    name: (import 'role.jsonnet').metadata.name,
    apiGroup: 'rbac.authorization.k8s.io',
  },
}
