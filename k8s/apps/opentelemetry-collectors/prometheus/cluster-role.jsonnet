{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: 'otel-prometheus-targetallocator',
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'namespaces',
        'nodes',
        'pods',
        'services',
        'endpoints',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        '',
      ],
      resources: [
        'configmaps',
      ],
      verbs: [
        'get',
      ],
    },
    {
      apiGroups: [
        'discovery.k8s.io',
      ],
      resources: [
        'endpointslices',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'monitoring.coreos.com',
      ],
      resources: [
        'servicemonitors',
        'podmonitors',
        'probes',
        'scrapeconfigs',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'networking.k8s.io',
      ],
      resources: [
        'ingresses',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
  ],
}
