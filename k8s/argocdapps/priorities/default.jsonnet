{
  apiVersion: 'scheduling.k8s.io/v1',
  kind: 'PriorityClass',
  metadata: {
    name: 'default',
  },
  value: 100,
  globalDefault: true,
  description: "This priority class should be used for all pods that don't have a priority class.",
}
