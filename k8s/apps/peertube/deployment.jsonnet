local app = import 'app.json5';
local configMap = import 'configmap.jsonnet';
local pvc = import 'pvc.jsonnet';
local serviceAccount = import 'serviceaccount.jsonnet';
local postgresSecret = import 'external-secret-postgres.jsonnet';
local redisSecret = import 'external-secret-redis.jsonnet';
local secrets = import 'external-secret-secrets.jsonnet';
local oidcSecret = import 'external-secret-oidc.jsonnet';
local labels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/part-of': app.name,
  'app.kubernetes.io/component': 'server',
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels,
  },
  spec: {
    replicas: 1,
    strategy: {
      type: 'Recreate',
    },
    selector: {
      matchLabels: labels,
    },
    template: {
      metadata: {
        labels: labels,
      },
      spec: {
        serviceAccountName: serviceAccount.metadata.name,
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 999,
          runAsGroup: 999,
          fsGroup: 999,
        },
        containers: [
          {
            name: 'server',
            image: 'docker.io/chocobozzz/peertube:v8.3.0',
            imagePullPolicy: 'IfNotPresent',
            command: [
              'bash',
              '-ec',
            ],
            args: [importstr './_scripts/bootstrap.sh'],
            ports: [
              {
                name: 'server',
                containerPort: 9000,
                protocol: 'TCP',
              },
            ],
            env: [
              {
                name: 'NODE_ENV',
                value: 'production',
              },
              {
                name: 'NODE_CONFIG_DIR',
                value: '/app/config:/app/support/docker/production/config:/config:/data/config',
              },
              {
                name: 'PEERTUBE_LOCAL_CONFIG',
                value: '/data/config',
              },
              {
                name: 'PT_INITIAL_ROOT_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: secrets.spec.target.name,
                    key: 'admin-password',
                  },
                },
              },
              {
                name: 'PEERTUBE_DB_USERNAME',
                valueFrom: {
                  secretKeyRef: {
                    name: postgresSecret.spec.target.name,
                    key: 'postgres-username',
                  },
                },
              },
              {
                name: 'PEERTUBE_DB_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: postgresSecret.spec.target.name,
                    key: 'postgres-password',
                  },
                },
              },
              {
                name: 'PEERTUBE_REDIS_AUTH',
                valueFrom: {
                  secretKeyRef: {
                    name: redisSecret.spec.target.name,
                    key: 'redis-password',
                  },
                },
              },
              {
                name: 'PEERTUBE_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: secrets.spec.target.name,
                    key: 'peertube-secret',
                  },
                },
              },
              {
                name: 'AWS_REGION',
                value: 'us-east-1',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::role/peertube',
              },
              {
                name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
              },
              {
                name: 'AWS_ENDPOINT_URL_STS',
                value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
              },
              {
                name: 'OIDC_CLIENT_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: oidcSecret.spec.target.name,
                    key: 'client-id',
                  },
                },
              },
              {
                name: 'OIDC_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: oidcSecret.spec.target.name,
                    key: 'client-secret',
                  },
                },
              },
              {
                name: 'OIDC_ROLE_CLAIM',
                valueFrom: {
                  secretKeyRef: {
                    name: oidcSecret.spec.target.name,
                    key: 'role-claim',
                  },
                },
              },
              {
                name: 'OIDC_ROLE_CLAIM_PROPERTY',
                valueFrom: {
                  secretKeyRef: {
                    name: oidcSecret.spec.target.name,
                    key: 'role-claim-property',
                  },
                },
              },
            ],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/config/production.yaml',
                subPath: 'production.yaml',
                readOnly: true,
              },
              {
                name: 'data',
                mountPath: '/data',
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'home',
                mountPath: '/home/peertube',
              },
              {
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
            ],
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 999,
              runAsGroup: 999,
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            startupProbe: {
              httpGet: {
                path: '/api/v1/ping',
                port: 'server',
                scheme: 'HTTP',
              },
              failureThreshold: 60,
              periodSeconds: 5,
            },
            readinessProbe: {
              httpGet: {
                path: '/api/v1/ping',
                port: 'server',
                scheme: 'HTTP',
              },
              periodSeconds: 10,
              timeoutSeconds: 5,
            },
            livenessProbe: {
              httpGet: {
                path: '/api/v1/ping',
                port: 'server',
                scheme: 'HTTP',
              },
              initialDelaySeconds: 60,
              periodSeconds: 30,
              timeoutSeconds: 5,
            },
            resources: {
              requests: {
                cpu: '500m',
                memory: '1Gi',
              },
              limits: {
                cpu: '2',
                memory: '4Gi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: configMap.metadata.name,
            },
          },
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: pvc.metadata.name,
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'home',
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
