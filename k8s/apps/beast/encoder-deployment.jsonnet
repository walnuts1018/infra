local app = import 'app.json5';
local images = import 'images.libsonnet';
local labels = {
  'app.kubernetes.io/name': 'encoder',
  'app.kubernetes.io/part-of': app.name,
};
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: { name: app.name + '-encoder', namespace: app.namespace, labels: labels },
  spec: {
    replicas: 1,
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
          name: 'encoder',
          image: images.encoder + ':' + images.tag,
          imagePullPolicy: 'Always',
          envFrom: [
            { configMapRef: { name: app.name + '-config' } },
            { secretRef: { name: app.name + '-runtime' } },
          ],
          resources: {
            requests: { cpu: '100m', memory: '256Mi' },
            limits: { cpu: '2', memory: '1Gi' },
          },
          securityContext: { allowPrivilegeEscalation: false, readOnlyRootFilesystem: true, capabilities: { drop: ['ALL'] } },
          volumeMounts: [{ name: 'work', mountPath: '/tmp/beast-encoder' }],
        }],
        volumes: [{ name: 'work', emptyDir: {} }],
        terminationGracePeriodSeconds: 30,
      },
    },
  },
}
