local app = import 'app.json5';
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: app.name + '-scraper',
  },
  rules: [
    {
      apiGroups: [''],
      resources: ['nodes/metrics'],
      verbs: ['get'],
    },
    {
      nonResourceURLs: ['/metrics', '/metrics/*'],
      verbs: ['get'],
    },
  ],
}
