local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local secret = import 'external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name, namespace: app.namespace, labels: labels(app.name) },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(app.name) },
    template: {
      metadata: { labels: labels(app.name) },
      spec: {
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        initContainers: [{
          name: 'migrations',
          image: 'ghcr.io/walnuts1018/iwashi:245a181dde8f3035c4bf10f6e4366d7b068076d5-migrations',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        containers: [{
          name: app.name,
          image: 'ghcr.io/walnuts1018/iwashi:245a181dde8f3035c4bf10f6e4366d7b068076d5',
          imagePullPolicy: 'IfNotPresent',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          env: [
            { name: 'OIDC_ISSUER', value: 'https://auth.walnuts.dev' },
            { name: 'OIDC_REDIRECT_URL', value: 'https://iwashi.walnuts.dev/auth/callback' },
            { name: 'VICTORIA_METRICS_URL', value: 'http://victoria-metrics-victoria-metrics-cluster-vmselect.victoria-metrics.svc.cluster.local:8481' },
          ],
          ports: [{ name: 'http', containerPort: 8080 }],
          readinessProbe: { httpGet: { path: '/healthz', port: 'http' }, initialDelaySeconds: 2 },
          livenessProbe: { httpGet: { path: '/healthz', port: 'http' }, initialDelaySeconds: 10 },
          resources: { requests: { cpu: '10m', memory: '32Mi' }, limits: { memory: '256Mi' } },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        securityContext: { seccompProfile: { type: 'RuntimeDefault' } },
      },
    },
  },
}
