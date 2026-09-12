(import 'appproject.libsonnet')(
  'kurumi',
  [{ namespace: '*', name: 'kurumi' }],
  labels={ 'argocd-agent': 'true' },
)
