local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-snmp',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    schedule: '17 */6 * * *',
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
              std.mergePatch((import '../../components/container.libsonnet') {
                name: 'snmp-discovery',
                image: 'docker.io/netboxlabs/snmp-discovery:1.33.0',
                imagePullPolicy: 'IfNotPresent',
                command: [
                  '/bin/sh',
                  '/scripts/snmp-discovery.sh',
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
                    memory: '64Mi',
                  },
                  limits: {
                    cpu: '500m',
                    memory: '512Mi',
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
