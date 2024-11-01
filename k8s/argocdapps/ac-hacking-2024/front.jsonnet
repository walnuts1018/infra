{
  apiVersion: 'v1',
  kind: 'List',
  items: [
    (import './front/deployment.libsonnet'),
    (import './front/service.libsonnet'),
  ],
}
