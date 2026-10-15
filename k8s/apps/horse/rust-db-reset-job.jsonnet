local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: 'horse-rust-db-reset',
    namespace: app.namespace,
    labels: labels('horse-db-reset'),
    annotations: { 'argocd.argoproj.io/sync-wave': '-1' },
  },
  spec: {
    backoffLimit: 2,
    template: {
      metadata: { labels: labels('horse-db-reset') },
      spec: {
        restartPolicy: 'Never',
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 26,
          runAsGroup: 26,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        containers: [{
          name: 'reset',
          image: 'ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie@sha256:c7747d8d1049fff9cf30d9cd83d14d609c957afb5ffbcd114145f393ea1850e1',
          imagePullPolicy: 'IfNotPresent',
          command: ['psql'],
          args: [
            '-v',
            'ON_ERROR_STOP=1',
            '-c',
            'DROP SCHEMA public CASCADE; CREATE SCHEMA public AUTHORIZATION horse;',
          ],
          env: [
            { name: 'PGHOST', value: 'postgresql-default-rw.databases.svc.cluster.local' },
            { name: 'PGPORT', value: '5432' },
            { name: 'PGUSER', value: 'horse' },
            { name: 'PGDATABASE', value: 'horse' },
            {
              name: 'PGPASSWORD',
              valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'POSTGRES_PASSWORD' } },
            },
          ],
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: { drop: ['ALL'] },
            readOnlyRootFilesystem: true,
          },
          resources: {
            requests: { cpu: '10m', memory: '32Mi' },
            limits: { cpu: '100m', memory: '128Mi' },
          },
        }],
      },
    },
  },
}
