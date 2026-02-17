{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
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
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
            },
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'stalwart',
            image: 'docker.io/stalwartlabs/stalwart:v0.15.5',
            imagePullPolicy: 'IfNotPresent',
            env: [
              {
                name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
              },
              {
                name: 'AWS_ENDPOINT_URL_STS',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
              {
                name: 'AWS_ENDPOINT_URL_S3',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
              {
                name: 'AWS_REGION',
                value: 'us-east-1',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::role/stalwart',
              },
            ],
            ports: [
              {
                containerPort: 8080,
              },
              {
                containerPort: 443,
              },
              {
                containerPort: 25,
              },
              {
                containerPort: 587,
              },
              {
                containerPort: 465,
              },
              {
                containerPort: 143,
              },
              {
                containerPort: 993,
              },
              {
                containerPort: 4190,
              },
            ],
            volumeMounts: [
              {
                name: 'data',
                mountPath: '/opt/stalwart',
              },
              {
                name: 'stalwart-config',
                mountPath: '/opt/stalwart/etc/config.toml',
                subPath: 'config.toml',
                readOnly: true,
              },
              {
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
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
                cpu: '100m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '2Gi',
              },
            },
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,
            },
          },
        ],
        volumes: [
          {
            name: 'data',
            emptyDir: {},
          },
          {
            name: 'stalwart-config',
            secret: {
              secretName: (import 'external-secret.jsonnet').spec.target.name,
              items: [
                {
                  key: 'config.toml',
                  path: 'config.toml',
                },
              ],
            },
          },
          {
            name: 'seaweedfs-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 86400,
                    path: 'token',
                  },
                },
              ],
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
