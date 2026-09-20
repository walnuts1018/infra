local app = import 'app.json5';
local labels = {
  'app.kubernetes.io/name': 'frontend',
  'app.kubernetes.io/part-of': app.name,
};
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name + '-frontend', namespace: app.namespace, labels: labels },
  spec: {
    replicas: 2,
    revisionHistoryLimit: 3,
    selector: { matchLabels: labels },
    template: {
      metadata: { labels: labels },
      spec: {
        serviceAccountName: app.name,
        automountServiceAccountToken: false,
        securityContext: {
          seccompProfile: { type: 'RuntimeDefault' },
          runAsNonRoot: true,
          runAsUser: 101,
          runAsGroup: 101,
          fsGroup: 101,
        },
        containers: [{
          name: 'frontend',
          image: 'ghcr.io/walnuts1018/beast/frontend:50f61d9-amd64',
          imagePullPolicy: 'Always',
          ports: [{ name: 'http', containerPort: 8080 }],
          readinessProbe: { httpGet: { path: '/livez', port: 'http' }, periodSeconds: 5, timeoutSeconds: 3 },
          livenessProbe: { httpGet: { path: '/livez', port: 'http' }, periodSeconds: 10, timeoutSeconds: 3 },
          resources: {
            requests: { cpu: '25m', memory: '32Mi' },
            limits: { cpu: '250m', memory: '128Mi' },
          },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: { drop: ['ALL'] } },
          volumeMounts: [
            { name: 'nginx-cache', mountPath: '/var/cache/nginx' },
            { name: 'nginx-run', mountPath: '/var/run' },
            { name: 'nginx-tmp', mountPath: '/tmp' },
          ],
        }],
        volumes: [
          { name: 'nginx-cache', emptyDir: {} },
          { name: 'nginx-run', emptyDir: {} },
          { name: 'nginx-tmp', emptyDir: {} },
        ],
      },
    },
  },
}
