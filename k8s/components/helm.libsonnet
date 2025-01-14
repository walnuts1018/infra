{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  ociChartURL:: '',
  chart:: '',
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
      local useOCI = !std.isEmpty($.ociChartURL),
      local splitedOCIChartURL = std.splitLimitR($.ociChartURL, '/', 1),
      local argoChart = if useOCI then splitedOCIChartURL[1] else $.chart,
      local argoRepoURL = if useOCI then splitedOCIChartURL[0] else $.repoURL,

      assert !std.isEmpty(argoChart) : 'ociChartURL or chart is required',
      assert !std.isEmpty(argoRepoURL) : 'ociChartURL or repoURL is required',

      chart: argoChart,
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
