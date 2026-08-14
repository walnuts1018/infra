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
                containerPort: 3000,
              },
            ],
            env: [
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
                name: 'JWT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'jwt_secret',
                  },
                },
              },
              {
                name: 'STATIC_SERVICE',
                value: 's3',
              },
              // aws-sdk クライアントに forcePathStyle を明示できないため、DNS 非対応な bucket 名で
              // 自動的に path-style リクエストへフォールバックさせている (SeaweedFS は virtual-hosted-style 未対応)
              {
                name: 'AWS_S3_BUCKET_NAME',
                value: 'visual_regression_tracker',
              },
              {
                name: 'AWS_REGION',
                value: 'us-east-1',
              },
              {
                name: 'AWS_ENDPOINT_URL_S3',
                value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
              },
              {
                name: 'AWS_ACCESS_KEY_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'AWS_ACCESS_KEY_ID',
                  },
                },
              },
              {
                name: 'AWS_SECRET_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'AWS_SECRET_ACCESS_KEY',
                  },
                },
              },
            ],
            livenessProbe: {
              tcpSocket: {
                port: 3000,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            readinessProbe: {
              tcpSocket: {
                port: 3000,
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
