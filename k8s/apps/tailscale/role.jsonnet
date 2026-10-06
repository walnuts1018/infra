local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'events',
      ],
      verbs: [
        'get',
        'create',
        'patch',
      ],
    },
    {
      apiGroups: [
        '',
      ],
      resourceNames: [
        'tailscale',
      ],
      resources: [
        'secrets',
      ],
      verbs: [
        'get',
        'update',
        'patch',
      ],
    },
  ],
}
