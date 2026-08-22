local app = import '../app.json5';
local worker = import 'image-worker.jsonnet';
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
        metadata: { protocol: 'http', queueName: 'picca.image-thumbnail', mode: 'ExpectedQueueConsumptionTime', value: '30' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.image-inspect', mode: 'ExpectedQueueConsumptionTime', value: '30' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.image-hdr', mode: 'ExpectedQueueConsumptionTime', value: '60' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
      {
        type: 'rabbitmq',
        metricType: 'Value',
        metadata: { protocol: 'http', queueName: 'picca.image-portrait', mode: 'ExpectedQueueConsumptionTime', value: '60' },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      },
    ],
  },
}
