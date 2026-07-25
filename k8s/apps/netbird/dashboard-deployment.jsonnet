local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-dashboard',
    namespace: app.namespace,
    labels: labels(app.name + '-dashboard'),
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(app.name + '-dashboard') },
    template: {
      metadata: { labels: labels(app.name + '-dashboard') },
      spec: {
        containers: [{
          name: 'dashboard',
          image: 'netbirdio/dashboard:v2.90.7',
          env: [
            {
              name: 'NETBIRD_MGMT_API_ENDPOINT',
              value: 'https://netbird.walnuts.dev',
            },
            {
              name: 'NETBIRD_MGMT_GRPC_API_ENDPOINT',
              value: 'https://netbird.walnuts.dev',
            },
            {
              name: 'AUTH_AUDIENCE',
              valueFrom: {
                secretKeyRef: {
                  name: (import 'external-secret.jsonnet').spec.target.name,
                  key: 'AUTH_AUDIENCE',
                },
              },
            },
            {
              name: 'AUTH_CLIENT_ID',
              valueFrom: {
                secretKeyRef: {
                  name: (import 'external-secret.jsonnet').spec.target.name,
                  key: 'AUTH_CLIENT_ID',
                },
              },
            },
            {
              name: 'AUTH_CLIENT_SECRET',
              valueFrom: {
                secretKeyRef: {
                  name: (import 'external-secret.jsonnet').spec.target.name,
                  key: 'AUTH_CLIENT_SECRET',
                },
              },
            },
            {
              name: 'AUTH_AUTHORITY',
              value: 'https://auth.walnuts.dev',
            },
            {
              name: 'USE_AUTH0',
              value: 'false',
            },
            {
              name: 'AUTH_SUPPORTED_SCOPES',
              value: 'openid profile email offline_access',
            },
            {
              name: 'AUTH_REDIRECT_URI',
              value: '/auth',
            },
            {
              name: 'AUTH_SILENT_REDIRECT_URI',
              value: '/silent-auth',
            },
          ],
          ports: [{
            name: 'http',
            containerPort: 80,
            protocol: 'TCP',
          }],
          resources: {
            requests: { cpu: '20m', memory: '64Mi' },
            limits: { cpu: '500m', memory: '256Mi' },
          },
        }],
      },
    },
  },
}
