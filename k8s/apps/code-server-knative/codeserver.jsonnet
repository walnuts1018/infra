{
  apiVersion: 'cs.walnuts.dev/v1alpha2',
  kind: 'CodeServerDeployment',
  metadata: {
    labels: {
      'app.kubernetes.io/name': 'codebox',
    },
    name: (import 'app.json5').name,
  },
  spec: {
    replicas: 1,
    template: {
      spec: {
        storageSize: '3Gi',
        storageClassName: 'local-path',
        initPlugins: {
          git: {
            repourl: 'github.com/walnuts1018/knative',
            branch: 'master',
          },
          copyDefaultConfig: {},
          copyHome: {},
        },
        envs: [
          {
            name: 'LANGUAGE_DEFAULT',
            value: 'ja',
          },
        ],
        image: 'ghcr.io/kmc-jp/code-server-images-golang:f66bb947f1dbfe0c07c8323ef45ebd32af0a72f4-54',
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        domain: 'walnuts.dev',
        ingressClassName: 'cilium',
        resources: {
          limits: {
            memory: '4Gi',
          },
          requests: {
            memory: '512Mi',
          },
        },
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
      },
    },
  },
}
