local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-web';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(name) },
    template: {
      metadata: { labels: labels(name) },
      spec: {
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          container {
            name: 'web',
            image: 'ghcr.io/walnuts1018/horse-web:v0.0.437@sha256:3dcf284e4e3ea937776dadc07c15ac1a6e220dd63bbd002892dd36372c212553',
            imagePullPolicy: 'Always',
            ports: [{ name: 'http', containerPort: 3000 }],
            env: [
              { name: 'NODE_ENV', value: 'production' },
              { name: 'HOST', value: '0.0.0.0' },
              { name: 'PORT', value: '3000' },
              { name: 'PUBLIC_ORIGIN', value: 'https://horse.walnuts.dev' },
            ],
            livenessProbe: {
              tcpSocket: { port: 'http' },
              periodSeconds: 10,
            },
            readinessProbe: {
              tcpSocket: { port: 'http' },
              periodSeconds: 5,
            },
            resources: {
              requests: { cpu: '10m', memory: '96Mi' },
              limits: { cpu: '500m', memory: '512Mi' },
            },
          },
        ],
      },
    },
  },
}
