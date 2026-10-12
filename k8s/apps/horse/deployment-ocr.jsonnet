local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-ocr';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
    annotations: { 'argocd.argoproj.io/sync-wave': '1' },
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(name) },
    template: {
      metadata: { labels: labels(name) },
      spec: {
        securityContext: { fsGroup: 10001 },
        nodeSelector: { 'kubernetes.io/arch': 'amd64' },
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        volumes: [
          { name: 'home', emptyDir: { sizeLimit: '4Gi' } },
          { name: 'tmp', emptyDir: { sizeLimit: '1Gi' } },
        ],
        containers: [
          container {
            name: 'ocr',
            image: 'ghcr.io/walnuts1018/horse-ocr:v0.0.0-c988fe6d34b26185782f7afbdb4c31dbfd45085c-6@sha256:462232df9c3f380de3335ac7dd5f406115d2e9b2ecfc272a007c6144abde1bce',
            imagePullPolicy: 'Always',
            ports: [{ name: 'http', containerPort: 8000 }],
            env: [
              { name: 'HOME', value: '/home/horse' },
              { name: 'PADDLE_PDX_CACHE_HOME', value: '/home/horse/.paddlex' },
              { name: 'XDG_CACHE_HOME', value: '/home/horse/.cache' },
              { name: 'OCR_CPU_THREADS', value: '2' },
            ],
            volumeMounts: [
              { name: 'home', mountPath: '/home/horse' },
              { name: 'tmp', mountPath: '/tmp' },
            ],
            startupProbe: {
              httpGet: { path: '/healthz', port: 'http' },
              periodSeconds: 10,
              failureThreshold: 120,
            },
            livenessProbe: {
              httpGet: { path: '/healthz', port: 'http' },
              periodSeconds: 30,
            },
            readinessProbe: {
              httpGet: { path: '/readyz', port: 'http' },
              periodSeconds: 10,
            },
            resources: {
              requests: { cpu: '500m', memory: '1Gi' },
              limits: { cpu: '2', memory: '4Gi' },
            },
          },
        ],
      },
    },
  },
}
