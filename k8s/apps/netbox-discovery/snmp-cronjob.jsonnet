local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local configmapPolicy = import 'configmap-policy.jsonnet';
local configmapScript = import 'configmap-script.jsonnet';
local externalSecret = import 'external-secret.jsonnet';

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
              std.mergePatch(container {
                name: 'snmp-discovery',
                image: 'docker.io/netboxlabs/snmp-discovery:1.32.0',
                imagePullPolicy: 'IfNotPresent',
                command: [
                  '/bin/sh',
                  '/scripts/snmp-discovery.sh',
                ],
                envFrom: [
                  {
                    secretRef: {
                      name: externalSecret.spec.target.name,
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
                  name: configmapPolicy.metadata.name,
                },
              },
              {
                name: 'scripts',
                configMap: {
                  name: configmapScript.metadata.name,
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
