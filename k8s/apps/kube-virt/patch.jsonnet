{
  apiVersion: 'kubevirt.io/v1',
  kind: 'KubeVirt',
  metadata: {
    name: 'patches',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    certificateRotateStrategy: {},
    configuration: {},
    customizeComponents: {
      patches: [
        {
          resourceType: 'Deployment',
          resourceName: 'virt-controller',
          patch: '[{"op": "add", "path": "/spec/template/spec/containers/0/resources", "value": {"requests": {"cpu": "3m", "memory": "128Mi"}, "limits": {"cpu": "1", "memory": "1Gi"}}}]',
          type: 'json',
        },
      ],
    },
  },
}
