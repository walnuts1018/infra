local app = import 'app.json5';

{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'ClusterRole',
  metadata: {
    name: app.name,
  },
  rules: [
    {
      apiGroups: [''],
      resources: [
        'users',
        'groups',
      ],
      verbs: ['impersonate'],
    },
    {
      apiGroups: ['authentication.k8s.io'],
      resources: [
        'userextras/originaluser.jetstack.io-user',
        'userextras/originaluser.jetstack.io-groups',
        'userextras/originaluser.jetstack.io-extra',
      ],
      verbs: ['impersonate'],
    },
  ],
}
