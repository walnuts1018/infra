{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: (import 'app.json5').name,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'services',
        'endpoints',
        'pods',
      ],
      verbs: [
        'get',
        'watch',
        'list',
      ],
    },
    {
      apiGroups: [
        'extensions',
        'networking.k8s.io',
      ],
      resources: [
        'ingresses',
      ],
      verbs: [
        'get',
        'watch',
        'list',
      ],
    },
    {
      apiGroups: [
        '',
      ],
      resources: [
        'nodes',
      ],
      verbs: [
        'list',
        'watch',
      ],
    },
  ],
}
