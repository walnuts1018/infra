local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local envoyConfig = import 'configmap-envoy.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxUnavailable: 0,
        maxSurge: 1,
      },
    },
    template: {
      metadata: {
        labels: labels(app.name),
        annotations: {
          'checksum/config': std.md5(envoyConfig.data['envoy.yaml']),
        },
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
          fsGroup: 65532,
          fsGroupChangePolicy: 'OnRootMismatch',
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        initContainers: [
          {
            name: 'sts-credentials',
            image: 'public.ecr.aws/aws-cli/aws-cli:2.37.9',
            imagePullPolicy: 'IfNotPresent',
            restartPolicy: 'Always',
            command: ['/usr/bin/bash', '-c'],
            args: [
              |||
                set -eu
                set -f
                umask 077

                token_file=/var/run/secrets/sts.seaweedfs.com/serviceaccount/token
                credentials_dir=/var/run/aws
                credentials_file="${credentials_dir}/credentials"
                refresh_seconds=2400

                while true; do
                  token="$(cat "${token_file}")"
                  if credentials="$(aws sts assume-role-with-web-identity \
                    --endpoint-url "${AWS_ENDPOINT_URL_STS}" \
                    --region "${AWS_REGION}" \
                    --role-arn "${AWS_ROLE_ARN}" \
                    --role-session-name ipu-envoy \
                    --web-identity-token "${token}" \
                    --duration-seconds 3600 \
                    --no-sign-request \
                    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                    --output text 2>/dev/null)"; then
                    old_ifs="${IFS}"
                    IFS="$(printf '\t')"
                    set -- ${credentials}
                    IFS="${old_ifs}"
                    if [ "$#" -eq 3 ]; then
                      printf '[default]\naws_access_key_id = %s\naws_secret_access_key = %s\naws_session_token = %s\n' "$1" "$2" "$3" > "${credentials_file}.tmp"
                      chmod 0640 "${credentials_file}.tmp"
                      mv -f "${credentials_file}.tmp" "${credentials_file}"
                      sleep "${refresh_seconds}"
                    else
                      sleep 30
                    fi
                  else
                    sleep 30
                  fi
                done
              |||,
            ],
            env: [
              { name: 'AWS_ENDPOINT_URL_STS', value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333' },
              { name: 'AWS_REGION', value: 'us-east-1' },
              { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/ipu' },
            ],
            startupProbe: {
              exec: {
                command: ['/usr/bin/bash', '-c', 'test -s /var/run/aws/credentials'],
              },
              periodSeconds: 2,
              failureThreshold: 90,
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              runAsUser: 1000,
              runAsGroup: 65532,
            },
            resources: {
              requests: { cpu: '5m', memory: '64Mi' },
              limits: { memory: '256Mi' },
            },
            volumeMounts: [
              { name: 'seaweedfs-sts-token', mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount', readOnly: true },
              { name: 'aws-credentials', mountPath: '/var/run/aws' },
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        containers: [
          {
            name: 'envoy',
            image: 'docker.io/envoyproxy/envoy:distroless-v1.39.0',
            imagePullPolicy: 'IfNotPresent',
            command: ['envoy'],
            args: ['-c', '/etc/envoy/envoy.yaml'],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
            },
            resources: {
              limits: {
                memory: '256Mi',
              },
              requests: {
                cpu: '30m',
                memory: '48Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            volumeMounts: [
              {
                name: 'envoy-config',
                mountPath: '/etc/envoy',
                readOnly: true,
              },
              { name: 'aws-credentials', mountPath: '/var/run/aws', readOnly: true },
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          {
            name: 'envoy-config',
            configMap: { name: envoyConfig.metadata.name },
          },
          {
            name: 'aws-credentials',
            emptyDir: { medium: 'Memory' },
          },
          { name: 'tmp', emptyDir: {} },
          {
            name: 'seaweedfs-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 86400,
                    path: 'token',
                  },
                },
              ],
            },
          },
        ],
      },
    },
  },
}
