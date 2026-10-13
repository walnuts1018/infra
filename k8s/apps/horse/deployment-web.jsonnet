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
            image: 'ghcr.io/walnuts1018/horse-web:v0.0.0-f68c84edd2cd67adcfacdc874ae45e77263afae5-153@sha256:f173bd3d69775d3236be887d988e03560b0d87d098b15d3e456759545c4defcf',
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
