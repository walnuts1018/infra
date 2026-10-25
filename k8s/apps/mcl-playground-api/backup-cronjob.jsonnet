local app = import 'app.json5';
local config = import 'backup-configmap.jsonnet';
local externalSecret = import 'backup-external-secret.jsonnet';
local s3Credentials = (import 's3-config.libsonnet').forIdentity('mcl_playground_backup');
local backupLabels = (import '../../components/labels.libsonnet')(app.name + '-backup');
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-backup',
    namespace: app.namespace,
  },
  spec: {
    schedule: '17 3 * * *',
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 3600,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      spec: {
        backoffLimit: 3,
        activeDeadlineSeconds: 14400,
        template: {
          metadata: {
            labels: backupLabels,
          },
          spec: {
            automountServiceAccountToken: false,
            restartPolicy: 'OnFailure',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
              seccompProfile: { type: 'RuntimeDefault' },
            },
            containers: [
              {
                name: 'backup',
                image: 'ghcr.io/rclone/rclone:1.75.2@sha256:2687085f718d3c628f7fdfb77c52a1d344332aed543110bb88088f2c70d43eb5',
                command: ['rclone'],
                args: [
                  '--config=/config/rclone.conf',
                  '--cache-dir=/tmp/rclone',
                  'copy',
                  'seaweed:mcl-playground',
                  'b2:walnuts-mcl-playground-backup-81f18e5/mcl-playground',
                  '--transfers=4',
                  '--checkers=8',
                  '--b2-chunk-size=64M',
                  '--retries=5',
                  '--low-level-retries=20',
                  '--retries-sleep=30s',
                  '--timeout=10m',
                  '--contimeout=30s',
                  '--stats=1m',
                  '--log-level=INFO',
                ],
                env: [
                  {
                    name: 'AWS_ACCESS_KEY_ID',
                    valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.accessKeyField } },
                  },
                  {
                    name: 'AWS_SECRET_ACCESS_KEY',
                    valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.secretKeyField } },
                  },
                  {
                    name: 'RCLONE_CONFIG_B2_ACCOUNT',
                    valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'RCLONE_CONFIG_B2_ACCOUNT' } },
                  },
                  {
                    name: 'RCLONE_CONFIG_B2_KEY',
                    valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'RCLONE_CONFIG_B2_KEY' } },
                  },
                ],
                resources: {
                  requests: { cpu: '100m', memory: '128Mi' },
                  limits: { cpu: '1', memory: '1Gi' },
                },
                securityContext: {
                  allowPrivilegeEscalation: false,
                  readOnlyRootFilesystem: true,
                  capabilities: { drop: ['ALL'] },
                },
                volumeMounts: [
                  { name: 'config', mountPath: '/config', readOnly: true },
                  { name: 'tmp', mountPath: '/tmp' },
                ],
              },
            ],
            volumes: [
              { name: 'config', configMap: { name: config.metadata.name } },
              { name: 'tmp', emptyDir: { sizeLimit: '1Gi' } },
            ],
          },
        },
      },
    },
  },
}
