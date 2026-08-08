local app = import 'app.json5';
local configMap = import 'prometheus-proxy-configmap.jsonnet';

local labels = {
  'app.kubernetes.io/name': 'headlamp-prometheus-proxy',
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'headlamp-prometheus-proxy',
    namespace: app.namespace,
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels,
    },
    template: {
      metadata: {
        annotations: {
          'checksum/config': std.md5(configMap.data['nginx.conf']),
        },
        labels: labels,
      },
      spec: {
        automountServiceAccountToken: false,
        containers: [
          {
            name: 'nginx',
            image: 'nginxinc/nginx-unprivileged:1.30.2-alpine',
            ports: [
              {
                name: 'http',
                containerPort: 9090,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 'http',
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz',
                port: 'http',
              },
              initialDelaySeconds: 2,
              periodSeconds: 5,
            },
            resources: {
              requests: {
                cpu: '5m',
                memory: '16Mi',
              },
              limits: {
                memory: '64Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              runAsGroup: 101,
              runAsUser: 101,
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/etc/nginx/nginx.conf',
                subPath: 'nginx.conf',
                readOnly: true,
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: configMap.metadata.name,
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
