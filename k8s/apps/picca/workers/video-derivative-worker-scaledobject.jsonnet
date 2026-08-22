local app = import '../app.json5';
local worker = import 'video-derivative-worker.jsonnet';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: { name: worker.metadata.name, namespace: app.namespace },
  spec: {
    minReplicaCount: 1,
    maxReplicaCount: 8,
    scaleTargetRef: { name: worker.metadata.name },
    triggers: [
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.video-thumbnail', mode: 'ExpectedQueueConsumptionTime', value: '60' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.video-motion', mode: 'ExpectedQueueConsumptionTime', value: '120' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
    ],
  },
}
