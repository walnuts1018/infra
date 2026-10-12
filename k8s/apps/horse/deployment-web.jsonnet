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
            image: 'ghcr.io/walnuts1018/horse:v0.0.0-756f44818a3e43460ba96be8d38915bab94a00df-20@sha256:31e7d550f977335e7d594afbab126c14265190aefa63b2c36fcbfe8a1e5bfda3',
            imagePullPolicy: 'Always',
            command: ['node', '.output/server/index.mjs'],
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
