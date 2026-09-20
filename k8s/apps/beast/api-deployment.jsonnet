local app = import 'app.json5';
local images = import 'images.libsonnet';
local labels = {
  'app.kubernetes.io/name': 'backend',
  'app.kubernetes.io/part-of': app.name,
};
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-apiserver',
    namespace: app.namespace,
    labels: labels,
  },
  spec: {
    replicas: 2,
    revisionHistoryLimit: 3,
    strategy: { type: 'Recreate' },
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        serviceAccountName: app.name,
        automountServiceAccountToken: false,
        securityContext: {
          seccompProfile: { type: 'RuntimeDefault' },
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
          fsGroup: 65532,
        },
        containers: [{
          name: 'apiserver',
          image: images.backend + ':' + images.tag,
          imagePullPolicy: 'Always',
          envFrom: [
            { configMapRef: { name: app.name + '-config' } },
            { secretRef: { name: app.name + '-runtime' } },
          ],
          env: [
            { name: 'AWS_ENDPOINT_URL', valueFrom: { configMapKeyRef: { name: app.name + '-config', key: 'S3_ENDPOINT', optional: true } } },
            { name: 'S3_ENDPOINT', valueFrom: { configMapKeyRef: { name: app.name + '-config', key: 'S3_ENDPOINT', optional: true } } },
          ],
          ports: [{ name: 'http', containerPort: 8080 }],
          startupProbe: { httpGet: { path: '/livez', port: 'http' }, periodSeconds: 5, timeoutSeconds: 3, failureThreshold: 30 },
          readinessProbe: { httpGet: { path: '/readyz', port: 'http' }, periodSeconds: 5, timeoutSeconds: 3, failureThreshold: 6 },
          livenessProbe: { httpGet: { path: '/livez', port: 'http' }, periodSeconds: 10, timeoutSeconds: 3, failureThreshold: 3 },
          resources: {
            requests: { cpu: '100m', memory: '128Mi' },
            limits: { cpu: '1', memory: '512Mi' },
          },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: { drop: ['ALL'] } },
          volumeMounts: [{ name: 'tmp', mountPath: '/tmp' }],
        }],
        volumes: [{ name: 'tmp', emptyDir: {} }],
        terminationGracePeriodSeconds: 30,
      },
    },
  },
}
