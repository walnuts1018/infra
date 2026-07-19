function(name, namespace, labels, minAvailable=null, maxUnavailable=null) {
  apiVersion: 'policy/v1',
  kind: 'PodDisruptionBudget',
  metadata: {
    name: name,
    namespace: namespace,
    labels: labels,
  },
  spec: {
    [if minAvailable != null then 'minAvailable']: minAvailable,
    [if maxUnavailable != null then 'maxUnavailable']: maxUnavailable,
    selector: {
      matchLabels: labels,
    },
  },
}
