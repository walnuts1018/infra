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
    },
    large: {
      cpuRequest: '1',
      cpuLimit: '2',
      memoryRequest: '1Gi',
      memoryLimit: '8Gi',
      minRunners: 0,
    },
  },

  makeRunnerSet(repoName, repoUrl, size, customParams={})::
    local isObj = std.isObject(size);
    local sizeName =
      if isObj then
        (if std.objectHas(size, 'name') then size.name else if std.objectHas(size, 'size') then size.size else error "size name is required in repository '%s'" % repoName)
      else
        size;
    local baseConfig =
      if std.objectHas($.sizes, sizeName) then
        $.sizes[sizeName]
      else
        error "Unknown size '%s' in repository '%s'" % [sizeName, repoName];
    local sizeOverride = if isObj then size else {};
    local sizeConfig = baseConfig + sizeOverride;
    assert std.objectHas(sizeConfig, 'maxRunners') && sizeConfig.maxRunners != null : "maxRunners is required for size '%s' in repository '%s'" % [sizeName, repoName];
    local sizeCustom = if isObj && std.objectHas(size, 'custom') then size.custom else {};
    local mergedCustom = std.mergePatch(sizeCustom, customParams);
    local scaleSetName = 'arc-' + repoName + '-' + sizeName;
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
        listenerMetrics: {
          counters: {
            gha_started_jobs_total: {
              labels: [
                'repository',
                'organization',
                'enterprise',
                'job_name',
                'event_name',
                'job_workflow_ref',
                'job_workflow_name',
                'job_workflow_target',
              ],
            },
            gha_completed_jobs_total: {
              labels: [
                'repository',
                'organization',
                'enterprise',
                'job_name',
                'event_name',
                'job_result',
                'job_workflow_ref',
                'job_workflow_name',
                'job_workflow_target',
              ],
            },
          },
          gauges: {
            gha_assigned_jobs: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_running_jobs: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_registered_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_busy_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_min_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_max_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_desired_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
            gha_idle_runners: {
              labels: ['name', 'namespace', 'repository', 'organization', 'enterprise'],
            },
          },
          histograms: {
            gha_job_startup_duration_seconds: {
              labels: [
                'repository',
                'organization',
                'enterprise',
                'job_name',
                'event_name',
                'job_workflow_ref',
                'job_workflow_name',
                'job_workflow_target',
              ],
              buckets: [
                0.01,
                0.05,
                0.1,
                0.5,
                1.0,
                2.0,
                3.0,
                4.0,
                5.0,
                6.0,
                7.0,
                8.0,
                9.0,
                10.0,
                12.0,
                15.0,
                18.0,
                20.0,
                25.0,
                30.0,
                40.0,
                50.0,
                60.0,
                70.0,
                80.0,
                90.0,
                100.0,
                110.0,
                120.0,
                150.0,
                180.0,
                210.0,
                240.0,
                300.0,
                360.0,
                420.0,
                480.0,
                540.0,
                600.0,
                900.0,
                1200.0,
                1800.0,
                2400.0,
                3000.0,
                3600.0,
              ],
            },
            gha_job_execution_duration_seconds: {
              labels: [
                'repository',
                'organization',
                'enterprise',
                'job_name',
                'event_name',
                'job_result',
                'job_workflow_ref',
                'job_workflow_name',
                'job_workflow_target',
              ],
              buckets: [
                0.01,
                0.05,
                0.1,
                0.5,
                1.0,
                2.0,
                3.0,
                4.0,
                5.0,
                6.0,
                7.0,
                8.0,
                9.0,
                10.0,
                12.0,
                15.0,
                18.0,
                20.0,
                25.0,
                30.0,
                40.0,
                50.0,
                60.0,
                70.0,
                80.0,
                90.0,
                100.0,
                110.0,
                120.0,
                150.0,
                180.0,
                210.0,
                240.0,
                300.0,
                360.0,
                420.0,
                480.0,
                540.0,
                600.0,
                900.0,
                1200.0,
                1800.0,
                2400.0,
                3000.0,
                3600.0,
              ],
            },
          },
        },
        listenerTemplate: {
          spec: {
            containers: [
              {
                name: 'listener',
                resources: {
                  requests: {
                    cpu: '10m',
                    memory: '32Mi',
                  },
                  limits: {
                    cpu: '100m',
                    memory: '128Mi',
                  },
                },
              },
            ],
          },
        },
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
                env: [
                  {
                    name: 'ACTIONS_CACHE_URL',
                    value: 'http://gha-cache-server.arc-systems.svc:3000/',
                  },
                  {
                    name: 'ACTIONS_RESULTS_URL',
                    value: 'http://gha-cache-server.arc-systems.svc:3000/',
                  },
                  {
                    name: 'ACTIONS_RUNTIME_TOKEN',
                    value: 'dummy-token',
                  },
                  {
                    name: 'DOTNET_gcServer',
                    value: '0',
                  },
                  {
                    name: 'DOTNET_GCHeapHardLimit',
                    value: '0x10000000',
                  },
                  {
                    name: 'DOTNET_GCConserveMemory',
                    value: '9',
                  },
                  {
                    name: 'DOTNET_TieredPGO',
                    value: '0',
                  },
                  {
                    name: 'MALLOC_ARENA_MAX',
                    value: '2',
                  },
                ],
              },
            ],
          },
        },
      }, mergedCustom),
    },

  generate(repos)::
    std.flattenArrays([
      local repoCustom = if std.objectHas(repo, 'custom') then repo.custom else {};
      local normalizedSizes =
        if std.isArray(repo.sizes) then
          [
            if std.isString(s) then
              error "maxRunners is required for size '%s' in repository '%s'. Please specify an object, e.g. { size: '%s', maxRunners: 5 }" % [s, repo.name, s]
            else if std.isObject(s) then
              s
            else
              error "Invalid size element in repository '%s': %s" % [repo.name, std.toString(s)]
            for s in repo.sizes
          ]
        else if std.isObject(repo.sizes) then
          [
            { name: k } + (if std.isObject(repo.sizes[k]) then repo.sizes[k] else error "Size config for '%s' in repository '%s' must be an object" % [k, repo.name])
            for k in std.objectFields(repo.sizes)
          ]
        else
          error "sizes in repository '%s' must be an array or an object" % repo.name;

      [
        $.makeRunnerSet(repo.name, repo.url, sizeItem, repoCustom)
        for sizeItem in normalizedSizes
      ]
      for repo in repos
    ]),
}
