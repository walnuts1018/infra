function(app)
  local labels = import '../../../../labels.libsonnet';
  local commonEnv = (import '../../env/common.libsonnet')(app);
  local postgresSecret = (import '../../postgres/external-secret.libsonnet')(app);
  local scyllaSecret = (import '../../scylla/external-secret.libsonnet')(app);
  local valkeySecret = (import '../../valkey/external-secret.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local oidcSecret = (import '../../oidc/external-secret.libsonnet')(app);
  local graphqlSigningSecret = (import '../../common/graphql-signing-secret.libsonnet')(app);
  local plans = (import '../../common/plans/mount.libsonnet')(app);
  local s3Irsa = (import '../../s3-irsa.libsonnet')(app);
  local scyllaTls = (import '../../scylla/tls.libsonnet')(app);
  local sa = (import '../../sa.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-library-notify-worker',
      namespace: app.namespace,
      labels: labels(app.name + '-library-notify-worker'),
    },
    spec: {
      replicas: 0,
      selector: {
        matchLabels: labels(app.name + '-library-notify-worker'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-library-notify-worker'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            (import '../../../../container.libsonnet') {
              name: 'library-notify-worker',
              image: 'ghcr.io/walnuts1018/picca/library-notify-worker:v0.0.49',
              imagePullPolicy: 'IfNotPresent',
              envFrom: [
                { secretRef: { name: postgresSecret.spec.target.name } },
                { secretRef: { name: scyllaSecret.spec.target.name } },
                { secretRef: { name: valkeySecret.spec.target.name } },
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
                { secretRef: { name: oidcSecret.spec.target.name } },
                { secretRef: { name: graphqlSigningSecret.spec.target.name } },
              ],
              env: commonEnv + s3Irsa.env + scyllaTls.env + plans.env + [
                {
                  name: 'OTEL_SERVICE_NAME',
                  value: 'picca-library-notify-worker',
                },
              ],
              resources: {
                requests: {
                  cpu: '100m',
                  memory: '256Mi',
                },
                limits: {
                  cpu: '1',
                  memory: '512Mi',
                },
              },
              ports: [
                {
                  containerPort: 8080,
                  name: 'health',
                },
              ],
              startupProbe: {
                httpGet: {
                  path: '/healthz',
                  port: 8080,
                },
                periodSeconds: 10,
                failureThreshold: 18,
              },
              livenessProbe: {
                httpGet: {
                  path: '/healthz',
                  port: 8080,
                },
                periodSeconds: 15,
                failureThreshold: 3,
              },
              volumeMounts: [
                {
                  name: 'tmp',
                  mountPath: '/tmp',
                },
              ] + s3Irsa.volumeMounts + scyllaTls.volumeMounts + plans.volumeMounts,
            },
          ],
          securityContext: {
            runAsNonRoot: true,
            runAsUser: 65532,
            runAsGroup: 65532,
          },
          volumes: [
            { name: 'tmp', emptyDir: {} },
          ] + s3Irsa.volumes + scyllaTls.volumes + plans.volumes,
        },
      },
    },
  }
