local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    schedule: '10 2 * * *',  // AM 2:10
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 21600,
    jobTemplate: {
      spec: {
        activeDeadlineSeconds: 43200,
        template: {
          metadata: {
            labels: labels(app.name),
          },
          spec: {
            serviceAccountName: (import 'sa.jsonnet').metadata.name,
            restartPolicy: 'OnFailure',
            containers: [
              std.mergePatch(
                (import '../../components/container.libsonnet') {
                  name: 'rclone',
                  image: 'denoland/deno:2.9.6',
                  command: [
                    '/usr/bin/bash',
                    '-c',
                  ],
                  args: [
                    'export PATH=$PATH:/rclone:/usr/local/aws-cli/v2/current/bin && deno run --allow-run --allow-env --allow-read /scripts/backup.ts',
                  ],
                  env: [
                    {
                      name: 'AWS_ROLE_ARN',
                      value: 'arn:aws:iam::role/seaweedfs-default-backup',
                    },
                    {
                      name: 'AWS_ROLE_SESSION_NAME',
                      value: 'seaweedfs-default-backup',
                    },
                    {
                      name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                      value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
                    },
                    {
                      name: 'AWS_REGION',
                      value: 'us-east-1',
                    },
                    {
                      name: 'AWS_ENDPOINT_URL_STS',
                      value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333',
                    },
                  ],
                  resources: {
                    requests: {
                      cpu: '10m',
                      memory: '10Mi',
                    },
                    limits: {
                      cpu: '1',
                      memory: '2Gi',
                    },
                  },
                  ports: [
                    {
                      name: 'metrics',
                      containerPort: 9250,
                    },
                  ],
                  volumeMounts: [
                    {
                      name: 'rclone',
                      mountPath: '/rclone',
                      subPath: 'usr/local/bin',
                    },
                    {
                      name: 'aws-cli',
                      // Mounted at the same absolute path the image itself uses so that
                      // /usr/local/aws-cli/v2/current (an *absolute* symlink to the
                      // versioned dist dir) still resolves correctly.
                      mountPath: '/usr/local/aws-cli',
                      subPath: 'usr/local/aws-cli',
                    },
                    {
                      name: 'seaweedfs-default-sts-token',
                      mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                      readOnly: true,
                    },
                    {
                      name: 'local-ca-bundle',
                      mountPath: '/etc/ssl/certs/trust-bundle.pem',
                      subPath: 'trust-bundle.pem',
                      readOnly: true,
                    },
                    {
                      name: 'aws-config',
                      mountPath: '/root/.aws/config',
                      readOnly: true,
                      subPath: 'config',
                    },
                    {
                      name: 'aws-credentials',
                      mountPath: '/root/.aws/credentials',
                      readOnly: true,
                      subPath: 'credentials',
                    },
                    {
                      name: 'rclone-config',
                      mountPath: '/config/rclone.conf',
                      readOnly: true,
                      subPath: 'rclone.conf',
                    },
                    {
                      name: 'backup-script',
                      mountPath: '/scripts',
                      readOnly: true,
                    },
                    {
                      name: 'tmp',
                      mountPath: '/tmp',
                    },
                  ],
                }, {
                  securityContext: {
                    readOnlyRootFilesystem: false,
                  },
                }
              ),
            ],
            volumes: [
              {
                name: 'rclone',
                image: {
                  reference: 'ghcr.io/rclone/rclone:1.71.1',
                },
              },
              {
                name: 'aws-cli',
                image: {
                  reference: 'public.ecr.aws/aws-cli/aws-cli:2.36.41',
                },
              },
              {
                name: 'seaweedfs-default-sts-token',
                projected: {
                  sources: [
                    {
                      serviceAccountToken: {
                        audience: 'sts.seaweedfs.com',
                        path: 'token',
                      },
                    },
                  ],
                },
              },
              {
                name: 'local-ca-bundle',
                configMap: {
                  name: (import '../clusterissuer/local-bundle.jsonnet').metadata.name,
                },
              },
              {
                name: 'rclone-config',
                configMap: {
                  name: (import 'configmap-rclone.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'rclone.conf',
                      path: 'rclone.conf',
                    },
                  ],
                },
              },
              {
                name: 'aws-config',
                configMap: {
                  name: (import 'configmap-aws.jsonnet').metadata.name,
                  items: [
                    {
                      key: 'config',
                      path: 'config',
                    },
                  ],
                },
              },
              {
                name: 'aws-credentials',
                secret: {
                  secretName: (import 'external-secret-aws.jsonnet').spec.target.name,
                  items: [
                    {
                      key: 'credentials',
                      path: 'credentials',
                    },
                  ],
                },
              },
              {
                name: 'backup-script',
                configMap: {
                  name: (import 'configmap-script.jsonnet').metadata.name,
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
    },
  },
}
