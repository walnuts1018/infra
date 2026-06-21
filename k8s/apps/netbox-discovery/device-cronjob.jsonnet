local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-device',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    schedule: '43 */6 * * *',
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    successfulJobsHistoryLimit: 1,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      spec: {
        backoffLimit: 0,
        activeDeadlineSeconds: 900,
        template: {
          metadata: {
            labels: labels(app.name),
          },
          spec: {
            restartPolicy: 'Never',
            containers: [
              std.mergePatch(container {
                name: 'device-discovery',
                image: 'hcr.io/walnuts1018/infra/device-discovery:v1.0.9@sha256:f2df17ae07e72ef4bba6e6a93fb915f4b2d31289203b1c8b9ed1df8b7e717881',
                imagePullPolicy: 'IfNotPresent',
                command: [
                  '/bin/sh',
                  '/scripts/device-discovery.sh',
                ],
                env: [
                  {
                    name: 'PYTHONDONTWRITEBYTECODE',
                    value: '1',
                  },
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: (import 'external-secret.jsonnet').spec.target.name,
                    },
                  },
                ],
                resources: {
                  requests: {
                    cpu: '20m',
                    memory: '128Mi',
                  },
                  limits: {
                    cpu: '500m',
                    memory: '768Mi',
                  },
                },
                volumeMounts: [
                  {
                    name: 'policies',
                    mountPath: '/policies',
                    readOnly: true,
                  },
                  {
                    name: 'scripts',
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
              }),
            ],
            volumes: [
              {
                name: 'policies',
                configMap: {
                  name: (import 'configmap-policy.jsonnet').metadata.name,
                },
              },
              {
                name: 'scripts',
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
