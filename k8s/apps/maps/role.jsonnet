local app = import 'app.json5';
local deployment = import 'deployment.jsonnet';
local configName = (import 'configmap-name.libsonnet').name;
{
  apiVersion: 'rbac.authorization.k8s.io/v1',
  kind: 'Role',
  metadata: {
    name: app.name + '-rollout-restart',
    namespace: app.namespace,
  },
  rules: [
    {
      apiGroups: ['apps'],
      resources: ['deployments'],
      resourceNames: [deployment.metadata.name],
      verbs: ['get', 'patch'],
    },
    {
      apiGroups: [''],
      resources: ['configmaps'],
      resourceNames: [configName],
      verbs: ['get', 'patch'],
    },
    {
      apiGroups: [''],
      resources: ['configmaps'],
      verbs: ['create'],
    },
  ],
}
