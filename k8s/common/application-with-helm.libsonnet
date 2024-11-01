{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  chart:: error 'chart is required',
  repoURL:: error 'repoURL is required',
  targetRevision:: error 'targetRevision is required',
  values:: '',
  valuesObject:: null,

  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'Application',
  metadata: {
    name: $.name + '-helm',
    namespace: 'argocd',
  },
  spec: {
    project: 'default',
    destination: {
      server: 'https://kubernetes.default.svc',
      namespace: $.namespace,
    },
    syncPolicy: {
      automated: {
        selfHeal: true,
        prune: true,
      },
    },
    source: {
      chart: $.chart,
      repoURL: $.repoURL,
      targetRevision: $.targetRevision,
      helm: {
        releaseName: 'argocd',
        [if $.values != '' then 'values']: $.values,
        [if $.valuesObject != null then 'valuesObject']: $.valuesObject,
      },
    },
  },
}
