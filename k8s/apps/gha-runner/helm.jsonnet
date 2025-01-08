local urls = (import 'urls.libsonnet');
local gen = function(githubConfigUrl)
  (import '../../components/helm.libsonnet') {
    name: std.md5(githubConfigUrl),
    namespace: (import 'app.json5').namespace,

    ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set',
    targetRevision: '0.10.1',
    valuesObject: {
      githubConfigSecret: {
        githubConfigSecret: (import 'external-secret.jsonnet').spec.target.name,
      },
      githubConfigUrl: githubConfigUrl,
      controllerServiceAccount: {
        namespace: (import '../gha-runner-controller/app.json5').namespace,
        name: (import '../gha-runner-controller/app.json5').name + '-gha-rs-controller',
      },
    },
  };

std.map(gen, urls)
