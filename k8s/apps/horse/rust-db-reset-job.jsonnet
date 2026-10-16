local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'database-reset-external-secret.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'Job',
  metadata: {
    name: 'horse-rust-db-reset-v2',
    namespace: app.namespace,
    labels: labels('horse-db-reset'),
    annotations: { 'argocd.argoproj.io/sync-wave': '-1' },
  },
  spec: {
    backoffLimit: 2,
    activeDeadlineSeconds: 300,
    template: {
      metadata: { labels: labels('horse-db-reset') },
      spec: {
        restartPolicy: 'Never',
        volumes: [{
          name: 'database-credentials',
          secret: {
            secretName: externalSecret.spec.target.name,
            optional: true,
          },
        }],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 26,
          runAsGroup: 26,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        initContainers: [{
          name: 'wait-for-database-credentials',
          image: 'ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie@sha256:c7747d8d1049fff9cf30d9cd83d14d609c957afb5ffbcd114145f393ea1850e1',
          imagePullPolicy: 'IfNotPresent',
          command: ['/bin/sh', '-ec'],
          args: ['i=0; while [ "$i" -lt 120 ]; do test -s /run/database-credentials/password && exit 0; sleep 1; i=$((i + 1)); done; exit 1'],
          volumeMounts: [{ name: 'database-credentials', mountPath: '/run/database-credentials', readOnly: true }],
          securityContext: {
            allowPrivilegeEscalation: false,
            capabilities: { drop: ['ALL'] },
            readOnlyRootFilesystem: true,
          },
          resources: {
            requests: { cpu: '10m', memory: '16Mi' },
            limits: { cpu: '100m', memory: '64Mi' },
          },
        }],
        containers: [{
          name: 'reset',
          image: 'ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie@sha256:c7747d8d1049fff9cf30d9cd83d14d609c957afb5ffbcd114145f393ea1850e1',
          imagePullPolicy: 'IfNotPresent',
          command: ['psql'],
          args: [
            '-v',
            'ON_ERROR_STOP=1',
            '-c',
            'DROP SCHEMA public CASCADE; CREATE SCHEMA public AUTHORIZATION horse; DROP SCHEMA IF EXISTS atlas_schema_revisions CASCADE;',
          ],
          env: [
            { name: 'PGHOST', value: 'postgresql-default-rw.databases.svc.cluster.local' },
            { name: 'PGPORT', value: '5432' },
            { name: 'PGUSER', value: 'horse' },
            { name: 'PGDATABASE', value: 'horse' },
            {
              name: 'PGPASSWORD',
              valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'password' } },
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
