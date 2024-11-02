{
  apiVersion: 'scheduling.k8s.io/v1',
  kind: 'PriorityClass',
  metadata: {
    name: 'low',
  },
  value: 10,
  globalDefault: false,
  description: 'This priority class should be used for all low priority pods.',
}
