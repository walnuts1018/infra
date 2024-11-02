{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'secrets',
      ],
      verbs: [
        'create',
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
    {
      apiGroups: [
        '',
      ],
      resourceNames: [
        'tailscale-auth1',
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
