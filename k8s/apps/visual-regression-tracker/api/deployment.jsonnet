local container = import '../../../components/container.libsonnet';
local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local externalSecret = import '../external-secret.jsonnet';
local appname = app.name + '-api';

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: appname,
    namespace: app.namespace,
    labels: (labels)(appname),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(appname),
    },
    template: {
      metadata: {
        labels: (labels)(appname),
      },
      spec: {
        containers: [
          (container) {
            name: 'api',
            image: 'docker.io/visualregressiontracker/api:5.5.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 4200,
              },
            ],
            env: [
              {
                name: 'APP_PORT',
                value: '4200',
              },
              {
                name: 'APP_FRONTEND_URL',
                value: 'https://vrt.local.walnuts.dev',
              },
              {
                name: 'AUTO_APPROVE_BASED_ON_HISTORY',
                value: 'true',
              },
              {
                name: 'BODY_PARSER_JSON_LIMIT',
                value: '5mb',
              },
              {
                name: 'JWT_LIFE_TIME',
                value: '1d',
              },
              {
                name: 'DATABASE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'DATABASE_URL',
                  },
                },
              },
              {
                name: 'POSTGRES_USER',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'postgres_user',
                  },
                },
              },
              {
                name: 'POSTGRES_DB',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'postgres_db',
                  },
                },
              }
              {
                name: 'JWT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'jwt_secret',
                  },
                },
              },
            ],
            livenessProbe: {
              tcpSocket: {
                port: 4200,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            readinessProbe: {
              tcpSocket: {
                port: 4200,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1000m',
                memory: '512Mi',
              },
            },
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,
            },
          },
        ],
      },
    },
  },
}
