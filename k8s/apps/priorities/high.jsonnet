{
  apiVersion: 'scheduling.k8s.io/v1',
  kind: 'PriorityClass',
  metadata: {
    name: 'high',
  },
  value: 1000,
  globalDefault: false,
  description: 'This priority class should be used for all high priority pods.',
}
