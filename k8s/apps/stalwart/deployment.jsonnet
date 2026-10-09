local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configMap = import 'configmap.jsonnet';
local s3Credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('stalwart');
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
    annotations: {
      'reloader.stakater.com/auto': 'true',
    },
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
        automountServiceAccountToken: false,
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
            image: 'docker.io/stalwartlabs/stalwart:v0.16.25@sha256:74e5a7d55303ba525d939c6bf97ed4e010df7521f52d80afc22a815b66bd53f3',
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
                name: 'STALWART_S3_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: s3Credentials.secretName,
                    key: s3Credentials.accessKeyField,
                  },
                },
              },
              {
                name: 'STALWART_S3_SECRET_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: s3Credentials.secretName,
                    key: s3Credentials.secretKeyField,
                  },
                },
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
                name: 'tls',
                mountPath: '/var/run/stalwart/tls',
                readOnly: true,
              },
            ],
            // Kubelet health checks use a listener without PROXY protocol.
            livenessProbe: {
              httpGet: {
                path: '/healthz/live',
                port: 8081,
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
            startupProbe: {
              httpGet: {
                path: '/healthz/live',
                port: 8081,
              },
              periodSeconds: 10,
              failureThreshold: 20,
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz/ready',
                port: 8081,
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
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 2000,
              runAsGroup: 2000,
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
                add: ['NET_BIND_SERVICE'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
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
            name: 'tls',
            secret: {
              secretName: (import 'certificate.jsonnet').spec.secretName,
            },
          },
        ],
      },
    },
  },
}
