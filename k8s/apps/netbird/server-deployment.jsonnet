local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
    labels: labels(app.name + '-server'),
  },
  spec: {
    replicas: 1,
    strategy: {
      type: 'Recreate',
    },
    selector: {
      matchLabels: labels(app.name + '-server'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-server'),
      },
      spec: {
        automountServiceAccountToken: false,
        containers: [{
          name: 'netbird-server',
          image: 'netbirdio/netbird-server:0.82.0@sha256:7b5b53b2dc8bc25639f791cf72d47cf86911894ff3f8a97cb79bab9be958109c',
          args: [
            '--config',
            '/etc/netbird/config.yaml',
          ],
          ports: [
            {
              name: 'http',
              containerPort: 80,
              protocol: 'TCP',
            },
            {
              name: 'metrics',
              containerPort: 9090,
              protocol: 'TCP',
            },
            {
              name: 'health',
              containerPort: 9000,
              protocol: 'TCP',
            },
          ],
          readinessProbe: {
            tcpSocket: {
              port: 'http',
            },
          },
          livenessProbe: {
            tcpSocket: {
              port: 'http',
            },
          },
          securityContext: {
            readOnlyRootFilesystem: false,
            allowPrivilegeEscalation: false,
            capabilities: {
              drop: ['ALL'],
              add: ['NET_BIND_SERVICE'],
            },
            seccompProfile: {
              type: 'RuntimeDefault',
            },
          },
          resources: {
            requests: {
              cpu: '10m',
              memory: '32Mi',
            },
            limits: {
              memory: '256Mi',
            },
          },
          volumeMounts: [
            {
              name: 'config',
              mountPath: '/etc/netbird/config.yaml',
              subPath: 'config.yaml',
              readOnly: true,
            },
            {
              name: 'data',
              mountPath: '/var/lib/netbird',
            },
          ],
        }],
        volumes: [
          {
            name: 'config',
            secret: {
              secretName: (import 'external-secret.jsonnet').spec.target.name,
            },
          },
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: (import 'server-pvc.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
