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
                ],
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
