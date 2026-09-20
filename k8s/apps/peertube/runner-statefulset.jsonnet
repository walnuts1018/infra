local app = import 'app.json5';
local secrets = import 'external-secret-secrets.jsonnet';
local runnerConfigMap = import 'runner-configmap.jsonnet';
local runnerID = 'vod';
local labels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/part-of': app.name,
  'app.kubernetes.io/component': 'runner',
} + {
  'peertube.runner/group': 'vod',
};
local peertubeURL = 'http://peertube.peertube.svc.cluster.local:9000';
local runnerProbeCommand = [
  'peertube-runner',
  '--id',
  runnerID,
  'list-registered',
];
local runnerEnv = [
  {
    name: 'HOME',
    value: '/home/peertube',
  },
  {
    name: 'XDG_CONFIG_HOME',
    value: '/home/peertube/.config',
  },
  {
    name: 'XDG_CACHE_HOME',
    value: '/cache',
  },
  {
    name: 'XDG_DATA_HOME',
    value: '/run/peertube-runner',
  },
  {
    name: 'RUNNER_NAME',
    valueFrom: { fieldRef: { fieldPath: 'metadata.name' } },
  },
  {
    name: 'RUNNER_ID',
    value: runnerID,
  },
  {
    name: 'PEERTUBE_URL',
    value: peertubeURL,
  },
  {
    name: 'RUNNER_STATIC_CONFIG_FILE',
    value: '/bootstrap/config.toml',
  },
];

{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name + '-runner-vod',
    namespace: app.namespace,
    labels: labels,
  },
  spec: {
    serviceName: app.name + '-runner-headless',
    replicas: 1,
    selector: {
      matchLabels: labels,
    },
    template: {
      metadata: {
        labels: labels,
      },
      spec: {
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 999,
          runAsGroup: 999,
          fsGroup: 999,
        },
        initContainers: [
          {
            name: 'bootstrap',
            image: 'ghcr.io/walnuts1018/infra/peertube-runner:v1.0.35',
            imagePullPolicy: 'IfNotPresent',
            command: [
              'node',
            ],
            args: [
              '/opt/peertube-runner/bootstrap.mjs',
            ],
            env: runnerEnv + [
              {
                name: 'PEERTUBE_ROOT_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: secrets.spec.target.name,
                    key: 'admin-password',
                  },
                },
              },
            ],
            volumeMounts: [
              {
                name: 'home',
                mountPath: '/home/peertube',
              },
              {
                name: 'runner-config',
                mountPath: '/bootstrap',
                readOnly: true,
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            resources: {
              requests: {
                cpu: '100m',
                memory: '256Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
                'ephemeral-storage': '1Gi',
              },
            },
          },
        ],
        containers: [
          {
            name: 'runner',
            image: 'ghcr.io/walnuts1018/infra/peertube-runner:v1.0.35',
            imagePullPolicy: 'IfNotPresent',
            command: [
              'peertube-runner',
            ],
            args: [
              '--id',
              runnerID,
              'server',
              '--enable-job',
              'vod-hls-transcoding',
              '--enable-job',
              'vod-audio-merge-transcoding',
            ],
            env: runnerEnv,
            volumeMounts: [
              {
                name: 'home',
                mountPath: '/home/peertube',
              },
              {
                name: 'cache',
                mountPath: '/cache',
              },
              {
                name: 'data',
                mountPath: '/run/peertube-runner',
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
            securityContext: {
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
              exec: {
                command: runnerProbeCommand,
              },
              failureThreshold: 60,
              periodSeconds: 2,
              timeoutSeconds: 3,
            },
            readinessProbe: {
              exec: {
                command: runnerProbeCommand,
              },
              periodSeconds: 10,
              timeoutSeconds: 3,
              failureThreshold: 3,
            },
            livenessProbe: {
              exec: {
                command: runnerProbeCommand,
              },
              periodSeconds: 30,
              timeoutSeconds: 3,
              failureThreshold: 2,
            },
            resources: {
              requests: {
                cpu: '1',
                memory: '512Mi',
                'ephemeral-storage': '1Gi',
              },
              limits: {
                cpu: '4',
                memory: '4Gi',
                'ephemeral-storage': '22Gi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'runner-config',
            configMap: {
              name: runnerConfigMap.metadata.name,
            },
          },
          {
            name: 'cache',
            emptyDir: {
              sizeLimit: '20Gi',
            },
          },
          {
            name: 'data',
            emptyDir: {
              sizeLimit: '1Gi',
            },
          },
          {
            name: 'tmp',
            emptyDir: {
              sizeLimit: '1Gi',
            },
          },
        ],
      },
    },
    volumeClaimTemplates: [
      {
        metadata: {
          name: 'home',
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '1Gi',
            },
          },
        },
      },
    ],
  },
}
