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
            image: 'ghcr.io/walnuts1018/horse-web:v0.0.387@sha256:82e5251ac596d787c038c1d43ef19299b6e09b75e8f6995ed96c3e3089f0e997',
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
