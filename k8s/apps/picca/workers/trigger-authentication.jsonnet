local app = import '../app.json5';
local externalSecret = import '../external-secret.jsonnet';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'TriggerAuthentication',
  metadata: {
    name: app.name + '-rabbitmq-worker-auth',
    namespace: app.namespace,
  },
  spec: {
    secretTargetRef: [
      {
        parameter: 'host',
        name: externalSecret.spec.target.name,
        key: 'KEDA_RABBITMQ_HOST',
      },
    ],
  },
}
