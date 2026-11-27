local app = import 'app.json5';
local script = importstr '_scripts/bootstrap.py';

{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: app.name + '-bootstrap-' + std.md5(script)[0:10],
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
  },
  spec: {
    backoffLimit: 3,
    activeDeadlineSeconds: 1200,
    template: {
      metadata: {
        labels: {
          'app.kubernetes.io/name': app.name + '-bootstrap',
        },
      },
      spec: {
        restartPolicy: 'Never',
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 1000,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        containers: [{
          name: 'bootstrap',
          image: 'python:3.15.2-alpine@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd',
          command: ['python', '-B', '/scripts/bootstrap.py'],
          env: [
            {
              name: 'ADMIN_PASSWORD',
              valueFrom: {
                secretKeyRef: {
                  name: app.name + '-admin',
                  key: 'password',
                },
              },
            },
            {
              name: 'OIDC_GROUP',
              valueFrom: {
                secretKeyRef: {
                  name: app.name + '-oidc',
                  key: 'group',
                },
              },
            },
          ],
          securityContext: {
            allowPrivilegeEscalation: false,
            readOnlyRootFilesystem: true,
            capabilities: { drop: ['ALL'] },
          },
          resources: {
            requests: { cpu: '10m', memory: '32Mi' },
            limits: { memory: '128Mi' },
          },
          volumeMounts: [{
            name: 'scripts',
            mountPath: '/scripts',
            readOnly: true,
          }],
        }],
        volumes: [{
          name: 'scripts',
          configMap: { name: app.name + '-bootstrap' },
        }],
      },
    },
  },
}
