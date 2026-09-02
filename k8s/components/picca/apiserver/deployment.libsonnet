function(app)
  local labels = import '../../labels.libsonnet';
  local commonEnv = (import '../env/common.libsonnet')(app);
  local postgresSecret = (import '../postgres/secret.libsonnet')(app);
  local scyllaSecret = (import '../scylla/secret.libsonnet')(app);
  local valkeySecret = (import '../valkey/secret.libsonnet')(app);
  local rabbitmqSecret = (import '../rabbitmq/secret.libsonnet')(app);
  local oidcSecret = (import '../oidc/secret.libsonnet')(app);
  local graphqlSigningSecret = (import '../common/graphql-signing-secret.libsonnet')(app);
  local imgproxySecret = (import '../imgproxy/secret.libsonnet')(app);
  local plans = (import '../common/plans/mount.libsonnet')(app);
  local s3Irsa = (import '../s3-irsa.libsonnet')(app);
  local scyllaTls = (import '../scylla/tls.libsonnet')(app);
  local sa = (import '../sa.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-apiserver',
      namespace: app.namespace,
      labels: labels(app.name + '-apiserver'),
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: labels(app.name + '-apiserver'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-apiserver'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          initContainers: [
            (import '../../container.libsonnet') {
              name: 'migrations',
              image: 'ghcr.io/walnuts1018/picca/migrations:v0.0.49',
              imagePullPolicy: 'IfNotPresent',
              // migrationsコマンドはScyllaConfigのみをパースするため、ScyllaDB用Secretだけで足りる。
              envFrom: [
                {
                  secretRef: {
                    name: scyllaSecret.spec.target.name,
                  },
                },
              ],
              env: commonEnv + s3Irsa.env + scyllaTls.env + [
                {
                  name: 'OTEL_SERVICE_NAME',
                  value: 'picca-apiserver',
                },
              ],
              volumeMounts: s3Irsa.volumeMounts + scyllaTls.volumeMounts,
            },
          ],
          containers: [
            (import '../../container.libsonnet') {
              name: 'apiserver',
              image: 'ghcr.io/walnuts1018/picca/apiserver:v0.0.49',
              imagePullPolicy: 'IfNotPresent',
              // apiserverはconfig.Load()で全設定を1つのConfig構造体としてパースするため、
              // imgproxy用を含む全てのミドルウェアSecretを必要とする。
              envFrom: [
                { secretRef: { name: postgresSecret.spec.target.name } },
                { secretRef: { name: scyllaSecret.spec.target.name } },
                { secretRef: { name: valkeySecret.spec.target.name } },
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
                { secretRef: { name: oidcSecret.spec.target.name } },
                { secretRef: { name: graphqlSigningSecret.spec.target.name } },
                { secretRef: { name: imgproxySecret.spec.target.name } },
              ],
              env: commonEnv + s3Irsa.env + scyllaTls.env + plans.env + [
                {
                  name: 'OTEL_SERVICE_NAME',
                  value: 'picca-apiserver',
                },
              ],
              ports: [
                {
                  containerPort: 8080,
                },
              ],
              livenessProbe: {
                httpGet: {
                  path: '/livez',
                  port: 8080,
                },
                initialDelaySeconds: 10,
                failureThreshold: 5,
              },
              readinessProbe: {
                httpGet: {
                  path: '/readyz',
                  port: 8080,
                },
                initialDelaySeconds: 10,
                failureThreshold: 5,
              },
              resources: {
                requests: {
                  cpu: '50m',
                  memory: '128Mi',
                },
                limits: {
                  cpu: '500m',
                  memory: '512Mi',
                },
              },
              volumeMounts: [
                { name: 'tmp', mountPath: '/tmp' },
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
