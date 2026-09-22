function(app)
  local labels = import '../../../labels.libsonnet';
  local commonEnv = (import '../env/common.libsonnet')(app);
  local postgresSecret = (import '../postgres/external-secret.libsonnet')(app);
  local scyllaSecret = (import '../scylla/external-secret.libsonnet')(app);
  local valkeySecret = (import '../valkey/external-secret.libsonnet')(app);
  local rabbitmqSecret = (import '../rabbitmq/external-secret.libsonnet')(app);
  local oidcSecret = (import '../oidc/external-secret.libsonnet')(app);
  local albumCapabilitySecret = (import '../common/album-capability-secret.libsonnet')(app);
  local imgproxySecret = (import '../imgproxy/external-secret.libsonnet')(app);
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
            (import '../../../container.libsonnet') {
              name: 'migrations',
              image: 'ghcr.io/walnuts1018/picca/migrations:v0.0.95@sha256:36ff2df17930d296802bc19b6418157a05eddba988430685cfdeac97eaa38b03',
              imagePullPolicy: 'IfNotPresent',
              envFrom: [
                {
                  secretRef: {
                    name: postgresSecret.spec.target.name,
                  },
                },
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
            (import '../../../container.libsonnet') {
              name: 'apiserver',
              image: 'ghcr.io/walnuts1018/picca/apiserver:v0.0.95@sha256:44b70d1d6eaf60fdd91f2a7a18b451483a787294c68fc285f74ee64a1c6c2d76',
              imagePullPolicy: 'IfNotPresent',
              envFrom: [
                { secretRef: { name: postgresSecret.spec.target.name } },
                { secretRef: { name: scyllaSecret.spec.target.name } },
                { secretRef: { name: valkeySecret.spec.target.name } },
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
                { secretRef: { name: oidcSecret.spec.target.name } },
                { secretRef: { name: albumCapabilitySecret.spec.target.name } },
                { secretRef: { name: imgproxySecret.spec.target.name } },
              ],
              env: commonEnv + s3Irsa.env + scyllaTls.env + plans.env + [
                {
                  name: 'IMGPROXY_PUBLIC_URL',
                  value: 'https://imgproxy-' + app.name + '.walnuts.dev',
                },
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
