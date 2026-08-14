local container = import '../../../components/container.libsonnet';
local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local appname = app.name + '-ui';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: appname,
    namespace: app.namespace,
    labels: labels(appname),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(appname),
    },
    template: {
      metadata: {
        labels: labels(appname),
      },
      spec: {
        containers: [
          (container) {
            name: 'ui',
            image: 'docker.io/visualregressiontracker/ui:5.5.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'REACT_APP_API_URL',
                value: 'https://vrt.local.walnuts.dev/api',
              },
            ],
            livenessProbe: {
              tcpSocket: {
                port: 8080,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            readinessProbe: {
              tcpSocket: {
                port: 8080,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '32Mi',
              },
              limits: {
                cpu: '200m',
                memory: '128Mi',
              },
            },
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,
              // nginx のエントリポイントが起動時に /var/cache/nginx 配下を nginx ユーザーへ chown するため必要
              capabilities+: {
                add+: ['CHOWN', 'SETUID', 'SETGID'],
              },
            },
          },
        ],
      },
    },
  },
}
