{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: (import 'app.json5').name,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'ClusterRole',
    name: (import './cluster-role.jsonnet').metadata.name,
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: (import './service-account.jsonnet').metadata.name,
      namespace: (import './service-account.jsonnet').metadata.namespace,
    },
  ],
}
