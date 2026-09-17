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
        serviceAccountName: app.name + '-api',
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        initContainers: [{
          name: 'migrations',
          image: 'ghcr.io/walnuts1018/iwashi-migration:f865777edb7c014e56fda0e82838626c49b55d52',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        containers: [{
          name: app.name,
          image: 'ghcr.io/walnuts1018/iwashi:f865777edb7c014e56fda0e82838626c49b55d52',
          imagePullPolicy: 'IfNotPresent',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          env: [
            { name: 'OIDC_ISSUER', value: 'https://auth.walnuts.dev' },
            { name: 'OIDC_REDIRECT_URL', value: 'https://iwashi.walnuts.dev/auth/callback' },
            { name: 'CORTEX_QUERY_URL', value: 'http://iwashi-cortex-querier.cortex.svc.cluster.local:8080/prometheus' },
            { name: 'CORTEX_OTLP_URL', value: 'http://iwashi-cortex-distributor.cortex.svc.cluster.local:8080/api/v1/otlp/v1/metrics' },
            { name: 'CORTEX_RULER_URL', value: 'http://iwashi-cortex-ruler.cortex.svc.cluster.local:8080' },
            { name: 'CORTEX_ALERTMANAGER_URL', value: 'http://iwashi-cortex-alertmanager.cortex.svc.cluster.local:8080' },
            { name: 'SMTP_SMARTHOST', value: 'smtp.resend.com:587' },
            { name: 'SMTP_FROM', value: 'netbox@resend.walnuts.dev' },
            { name: 'SMTP_USERNAME', value: 'resend' },
            { name: 'SMTP_PASSWORD_FILE', value: '/etc/iwashi-smtp/smtp_password' },
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
