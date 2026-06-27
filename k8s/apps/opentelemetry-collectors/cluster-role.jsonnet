{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: (import 'app.json5').name,
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'events',
        'namespaces',
        'namespaces/status',
        'nodes',
        'nodes/spec',
        'nodes/stats',
        'nodes/metrics',
        'nodes/proxy',
        'pods',
        'pods/status',
        'replicationcontrollers',
        'replicationcontrollers/status',
        'resourcequotas',
        'services',
        'configmaps',
        'endpoints',
        'persistentvolumes',
        'persistentvolumeclaims',
        'secrets',
      ],
      verbs: [
        'get',
        'watch',
        'list',
      ],
    },
    {
      apiGroups: [
        'apps',
      ],
      resources: [
        'replicasets',
        'daemonsets',
        'deployments',
        'statefulsets',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'extensions',
      ],
      resources: [
        'daemonsets',
        'deployments',
        'replicasets',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'batch',
      ],
      resources: [
        'jobs',
        'cronjobs',
      ],
      verbs: [
        'get',
        'list',
        'watch',
      ],
    },
    {
      apiGroups: [
        'autoscaling',
      ],
      resources: [
        'horizontalpodautoscalers',
      ],
      verbs: [
        'get',
        'list',
        'watch',
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
        '*',
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
    {
      apiGroups: [
        'events.k8s.io',
      ],
      resources: [
        'events',
      ],
      verbs: [
        'list',
        'watch',
      ],
    },
    {
      nonResourceURLs: [
        '/metrics',
      ],
      verbs: [
        'get',
      ],
    },
  ],
}
