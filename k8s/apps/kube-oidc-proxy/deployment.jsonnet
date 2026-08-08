local app = import 'app.json5';
local certificate = import 'certificate.jsonnet';
local config = import 'config.json5';
local serviceAccount = import 'service-account.jsonnet';

local labels = {
  'app.kubernetes.io/name': app.name,
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: labels,
    },
    template: {
      metadata: {
        labels: labels,
      },
      spec: {
        automountServiceAccountToken: true,
        serviceAccountName: serviceAccount.metadata.name,
        containers: [
          {
            name: app.name,
            image: 'ghcr.io/tremolosecurity/kube-oidc-proxy:1.0.12@sha256:d7747f308042216acd31eb48af4baefb2f508afc2023736451931b2d323907e9',
            imagePullPolicy: 'IfNotPresent',
            args: [
              '--secure-port=8443',
              '--tls-cert-file=/etc/kube-oidc-proxy/tls.crt',
              '--tls-private-key-file=/etc/kube-oidc-proxy/tls.key',
              '--tls-min-version=VersionTLS12',
              '--oidc-client-id=' + config.zitadelProjectId,
              '--oidc-issuer-url=https://auth.walnuts.dev',
              '--oidc-username-claim=email',
              '--oidc-username-prefix=zitadel:',
              '--oidc-groups-claim=my:zitadel:grants',
              '--oidc-groups-prefix=zitadel:',
              '--oidc-signing-algs=RS256',
            ],
            ports: [
              {
                name: 'https',
                containerPort: 8443,
                protocol: 'TCP',
              },
              {
                name: 'health',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/ready',
                port: 'health',
              },
              initialDelaySeconds: 5,
              periodSeconds: 10,
            },
            livenessProbe: {
              httpGet: {
                path: '/ready',
                port: 'health',
              },
              initialDelaySeconds: 15,
              periodSeconds: 20,
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
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                drop: ['ALL'],
              },
              readOnlyRootFilesystem: true,
              runAsGroup: 65532,
              runAsNonRoot: true,
              runAsUser: 65532,
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
            volumeMounts: [
              {
                name: 'tls',
                mountPath: '/etc/kube-oidc-proxy',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'tls',
            secret: {
              secretName: certificate.spec.secretName,
            },
          },
        ],
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'kubernetes.io/hostname',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: labels,
            },
          },
        ],
      },
    },
  },
}
