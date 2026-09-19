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
          image: 'ghcr.io/walnuts1018/iwashi-migration:b800bd8f72ac984087c5e32f9d564936c54b0c39@sha256:2b9f8f690d4dd63817d41aeb2a35d9d3b5d600029de7b8acd72a2371831cca1a',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities: { drop: ['ALL'] } },
        }],
        containers: [{
          name: app.name,
          image: 'ghcr.io/walnuts1018/iwashi:b800bd8f72ac984087c5e32f9d564936c54b0c39@sha256:b220dd58998f29c396f0420ce6412f6ee624999e30c5901fd245ccadd22eec80',
          imagePullPolicy: 'IfNotPresent',
          envFrom: [{ secretRef: { name: secret.spec.target.name } }],
          env: [
            { name: 'OIDC_ISSUER', value: 'https://auth.walnuts.dev' },
            { name: 'OIDC_REDIRECT_URL', value: 'https://iwashi.walnuts.dev/auth/callback' },
            { name: 'CORTEX_QUERY_URL', value: 'http://iwashi-cortex-querier.iwashi-system.svc.cluster.local:8080/prometheus' },
            { name: 'CORTEX_OTLP_URL', value: 'http://iwashi-cortex-distributor.iwashi-system.svc.cluster.local:8080/api/v1/otlp/v1/metrics' },
            { name: 'CORTEX_RULER_URL', value: 'http://iwashi-cortex-ruler.iwashi-system.svc.cluster.local:8080' },
            { name: 'CORTEX_ALERTMANAGER_URL', value: 'http://iwashi-cortex-alertmanager.iwashi-system.svc.cluster.local:8080' },
            { name: 'SMTP_SMARTHOST', value: 'iwashi-smtp-relay-mail.iwashi-system.svc.cluster.local:587' },
            { name: 'SMTP_FROM', value: 'netbox@resend.walnuts.dev' },
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
