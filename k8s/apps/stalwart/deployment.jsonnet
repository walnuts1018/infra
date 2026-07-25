local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configMap = import 'configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxUnavailable: 0,
        maxSurge: 1,
      },
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: labels(app.name),
            },
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'stalwart',
            resizePolicy: [
              {
                resourceName: 'cpu',
                restartPolicy: 'NotRequired',
              },
              {
                resourceName: 'memory',
                restartPolicy: 'RestartContainer',
              },
            ],
            image: 'docker.io/stalwartlabs/stalwart:v0.16.14',
            imagePullPolicy: 'IfNotPresent',
            args: [
              '--config',
              '/opt/stalwart/etc/config.json',
            ],
            env: [
              {
                name: 'STALWART_DB_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'postgres_password',
                  },
                },
              },
              {
                name: 'STALWART_RECOVERY_ADMIN',
                value: 'admin:YourNewPassword123',
              },
              {
                name: 'STALWART_RECOVERY_MODE',
                value: 'true',
              },
              {
                name: 'STALWART_RECOVERY_MODE_LOG_LEVEL',
                value: 'trace',
              },
              {
                name: 'AWS_ACCESS_KEY_ID',
                value: 'stalwart',
              },
              {
                name: 'AWS_SECRET_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 's3_secret_access_key',
                  },
                },
              },
              {
                name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::role/stalwart',
              },
              {
                name: 'AWS_ENDPOINT_URL_STS',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
              {
                name: 'https',
                containerPort: 443,
              },
              {
                name: 'smtp',
                containerPort: 25,
              },
              {
                name: 'smtps',
                containerPort: 465,
              },
              {
                name: 'submission',
                containerPort: 587,
              },
              {
                name: 'imaps',
                containerPort: 993,
              },
            ],
            volumeMounts: [
              {
                name: 'stalwart-config',
                mountPath: '/opt/stalwart/etc/config.json',
                subPath: 'config.json',
                readOnly: true,
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz/live',
                port: 8080,
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
            startupProbe: {
              httpGet: {
                path: '/healthz/live',
                port: 8080,
              },
              periodSeconds: 10,
              failureThreshold: 10,
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz/ready',
                port: 8080,
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            resources: {
              requests: {
                cpu: '5m',
                memory: '60Mi',
              },
              limits: {
                cpu: '500m',
                memory: '256Mi',
              },
            },
          } + {
            securityContext: null,
          },
        ],
        volumes: [
          {
            name: 'stalwart-config',
            configMap: {
              name: configMap.metadata.name,
              items: [
                {
                  key: 'config.json',
                  path: 'config.json',
                },
              ],
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'seaweedfs-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 3600,
                    path: 'token',
                  },
                },
              ],
            },
          },
        ],
      },
    },
  },
}
