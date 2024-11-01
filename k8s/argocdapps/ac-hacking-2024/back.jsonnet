{
  apiVersion: 'v1',
  kind: 'List',
  items: [
    (import './back/deployment.libsonnet'),
    (import './back/service.libsonnet'),
    (import './back/external-secret.libsonnet'),
  ],
}
