{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'Queue',
  metadata: {
    name: 'picca-prototype-image-jobs',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name + '-rabbitmq-queue'),
  },
  spec: {
    name: 'picca_prototype_image_jobs',
    durable: true,
    autoDelete: false,
    rabbitmqClusterReference: {
      name: (import '../rabbitmq-default/rabbitmqcluster.jsonnet').metadata.name,
      namespace: (import '../rabbitmq-default/rabbitmqcluster.jsonnet').metadata.namespace,
    },
  },
}
