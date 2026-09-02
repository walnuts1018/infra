local app = import '../app.json5';
local worker = import 'download-worker.jsonnet';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: { name: worker.metadata.name, namespace: app.namespace },
  spec: {
    minReplicaCount: 0,
    maxReplicaCount: 8,
    scaleTargetRef: { name: worker.metadata.name },
    triggers: [{
      type: 'rabbitmq',
      metricType: 'Value',
      metadata: { protocol: 'http', queueName: 'picca.download', mode: 'ExpectedQueueConsumptionTime', value: '120' },
      authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
    }],
  },
}
