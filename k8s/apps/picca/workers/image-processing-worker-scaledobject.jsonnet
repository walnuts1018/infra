local app = import '../app.json5';
local worker = import 'image-processing-worker.jsonnet';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: { name: worker.metadata.name, namespace: app.namespace },
  spec: {
    minReplicaCount: 0,
    maxReplicaCount: 8,
    scaleTargetRef: { name: worker.metadata.name },
    triggers: [
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.image-processing', mode: 'ExpectedQueueConsumptionTime', value: '30' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
    ],
  },
}
