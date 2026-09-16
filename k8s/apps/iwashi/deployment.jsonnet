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
          image: 'postgres:18.6-alpine',
          command: ['/bin/sh', '/migrations/migrate.sh'],
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          volumeMounts: [{ name: 'migrations', mountPath: '/migrations', readOnly: true }],
          securityContext: { allowPrivilegeEscalation: false, runAsNonRoot: true, runAsUser: 65534, capabilities: { drop: ['ALL'] } },
        }],
        containers: [{
          name: app.name,
          image: 'ghcr.io/walnuts1018/iwashi:43845617864ad08172b1e666350fbe7749ba33eb',
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
        volumes: [{ name: 'migrations', configMap: { name: (import 'migrations.jsonnet').metadata.name, defaultMode: 365 } }],
        securityContext: { seccompProfile: { type: 'RuntimeDefault' } },
      },
    },
  },
}
