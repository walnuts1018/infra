local app = import 'app.json5';

{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: app.name + '-helm',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '1',
    },
  },
  spec: {
    project: 'default',
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: app.namespace,
    },
    sources: [
      {
        chart: 'openunison-operator',
        repoURL: 'https://nexus.tremolo.io/repository/helm',
        targetRevision: '3.0.30',
        helm: {
          releaseName: app.name,
          valueFiles: ['$values/k8s/apps/openunison/values.yaml'],
        },
      },
      {
        chart: 'orchestra',
        repoURL: 'https://nexus.tremolo.io/repository/helm',
        targetRevision: '3.1.52',
        helm: {
          releaseName: 'orchestra',
          valueFiles: ['$values/k8s/apps/openunison/values.yaml'],
        },
      },
      {
        chart: 'orchestra-login-portal',
        repoURL: 'https://nexus.tremolo.io/repository/helm',
        targetRevision: '2.3.94',
        helm: {
          releaseName: 'orchestra-login-portal',
          valueFiles: ['$values/k8s/apps/openunison/values.yaml'],
        },
      },
      {
        repoURL: 'https://github.com/walnuts1018/infra',
        targetRevision: 'main',
        ref: 'values',
      },
    ],
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
      syncOptions: [
        'ServerSideApply=true',
        'FailOnSharedResource=true',
        'RespectIgnoreDifferences=true',
      ],
    },
  },
}
