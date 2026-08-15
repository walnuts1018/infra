local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';

{
  sizes:: {
    small: {
      cpuRequest: '500m',
      cpuLimit: '1',
      memoryRequest: '512Mi',
      memoryLimit: '4Gi',
      minRunners: 0,
      maxRunners: 5,
    },
    large: {
      cpuRequest: '1',
      cpuLimit: '2',
      memoryRequest: '1Gi',
      memoryLimit: '8Gi',
      minRunners: 0,
      maxRunners: 2,
    },
  },

  makeRunnerSet(repoName, repoUrl, size, customParams={})::
    local sizeConfig = $.sizes[size];
    local scaleSetName = 'arc-' + repoName + '-' + size;
    helm {
      name: scaleSetName,
      namespace: app.namespace,
      ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set',
      targetRevision: '0.14.2',
      valuesObject: std.mergePatch({
        controllerServiceAccount: {
          namespace: 'arc-systems',
          name: 'actions-runner-controller-gha-rs-controller',
        },
        githubConfigUrl: repoUrl,
        githubConfigSecret: 'arc-secret',
        minRunners: sizeConfig.minRunners,
        maxRunners: sizeConfig.maxRunners,
        containerMode: {
          type: 'dind',
        },
        template: {
          spec: {
            automountServiceAccountToken: false,
            nodeSelector: {
              'kubernetes.io/arch': 'amd64',
            },
            containers: [
              {
                name: 'runner',
                image: 'ghcr.io/actions/actions-runner:2.336.0',
                command: ['/home/runner/run.sh'],
                resources: {
                  requests: {
                    cpu: sizeConfig.cpuRequest,
                    memory: sizeConfig.memoryRequest,
                  },
                  limits: {
                    cpu: sizeConfig.cpuLimit,
                    memory: sizeConfig.memoryLimit,
                  },
                },
              },
            ],
          },
        },
      }, customParams),
    },

  generate(repos)::
    std.flattenArrays([
      [
        $.makeRunnerSet(repo.name, repo.url, size, if std.objectHas(repo, 'custom') then repo.custom else {})
        for size in repo.sizes
      ]
      for repo in repos
    ]),
}
