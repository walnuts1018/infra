(import 'appproject.libsonnet')(
  'biscuit',
  [{ namespace: '*', name: 'biscuit' }],
  labels={ 'argocd-agent': 'true' },
)
