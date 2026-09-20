local app = import 'app.json5';
local labels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/part-of': app.name,
  'app.kubernetes.io/component': 'runner',
  'peertube.runner/group': 'vod',
};
local runnerImage = 'docker.io/zendet/peertube-runner:0.4.0-ctranslate2';
local runnerProbeCommand = [
  'sh',
  '-ec',
  'id="${RUNNER_GROUP_ID}-$(echo "$POD_NAME" | sed \'s/.*-//\')"; ' +
  'timeout 2 peertube-runner --id "$id" list-registered >/dev/null',
];
local runnerEnv = [
  { name: 'HOME', value: '/home/peertube' },
  { name: 'XDG_CONFIG_HOME', value: '/home/peertube/.config' },
  { name: 'XDG_CACHE_HOME', value: '/home/peertube/.cache' },
  { name: 'XDG_DATA_HOME', value: '/home/peertube/.local/share' },
  {
    name: 'POD_NAME',
    valueFrom: { fieldRef: { fieldPath: 'metadata.name' } },
  },
  { name: 'RUNNER_GROUP_ID', value: 'vod' },
  {
    name: 'PEERTUBE_URL',
    valueFrom: { secretKeyRef: { name: 'peertube-runner', key: 'runner-url' } },
  },
  {
    name: 'REGISTRATION_TOKEN',
    valueFrom: { secretKeyRef: { name: 'peertube-runner', key: 'registration-token' } },
  },
  { name: 'ENABLE_JOBS', value: 'vod-web-video-transcoding,vod-hls-transcoding,vod-audio-merge-transcoding' },
  { name: 'UNREGISTER_ON_EXIT', value: 'false' },
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
    replicas: 2,
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        serviceAccountName: app.name,
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 999,
          runAsGroup: 999,
          fsGroup: 999,
        },
        initContainers: [{
          name: 'register',
          image: runnerImage,
          imagePullPolicy: 'IfNotPresent',
          args: ['bootstrap'],
          env: runnerEnv,
          volumeMounts: [
            { name: 'home', mountPath: '/home/peertube' },
            { name: 'runner-config', mountPath: '/bootstrap', readOnly: true },
            { name: 'tmp', mountPath: '/tmp' },
          ],
          securityContext: {
            allowPrivilegeEscalation: false,
            readOnlyRootFilesystem: true,
            capabilities: { drop: ['ALL'] },
            seccompProfile: { type: 'RuntimeDefault' },
          },
          resources: {
            requests: { cpu: '1', memory: '1Gi' },
            limits: { cpu: '4', memory: '4Gi' },
          },
        }],
        containers: [{
          name: 'runner',
          image: runnerImage,
          imagePullPolicy: 'IfNotPresent',
          env: runnerEnv,
          volumeMounts: [
            {
              name: 'home',
              mountPath: '/home/peertube',
            },
            { name: 'tmp', mountPath: '/tmp' },
          ],
          securityContext: {
            allowPrivilegeEscalation: false,
            readOnlyRootFilesystem: true,
            capabilities: { drop: ['ALL'] },
            seccompProfile: { type: 'RuntimeDefault' },
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
            requests: { cpu: '1', memory: '1Gi' },
            limits: { cpu: '4', memory: '4Gi' },
          },
        }],
        volumes: [{
          name: 'runner-config',
          configMap: { name: app.name + '-runner-vod-config' },
        }, { name: 'tmp', emptyDir: {} }],
      },
    },
    volumeClaimTemplates: [{
      metadata: { name: 'home' },
      spec: {
        accessModes: ['ReadWriteOnce'],
        storageClassName: 'longhorn',
        resources: { requests: { storage: '100Gi' } },
      },
    }],
  },
}
