{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  chart:: error 'chart is required',
  ociRepoURL:: '',
  repoURL:: '',
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
      syncOptions: [
        'ServerSideApply=true',
        'FailOnSharedResource=true',
      ],
    },
    source: {
      local argoRepoURL = if $.ociRepoURL != '' then $.ociRepoURL else $.repoURL,
      assert !std.isEmpty(argoRepoURL) : 'ociRepoURL or repoURL is required',
      chart: $.chart,
      repoURL: argoRepoURL,
      targetRevision: $.targetRevision,
      helm: {
        releaseName: $.name,
        [if $.values != '' then 'values']: $.values,
        [if $.valuesObject != null then 'valuesObject']: $.valuesObject,
      },
    },
  },
}
