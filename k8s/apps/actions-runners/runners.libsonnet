local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';

local sizes = {
  small: {
    cpuRequest: '500m',
    cpuLimit: '1',
    memoryRequest: '512Mi',
    memoryLimit: '4Gi',
  },
  large: {
    cpuRequest: '1',
    cpuLimit: '2',
    memoryRequest: '1Gi',
    memoryLimit: '8Gi',
  },
};

local makeRunnerSet(repo, sizeName, sizeConfig) =
  local size = sizes[sizeName];
  helm {
    name: 'arc-%s-%s' % [repo.name, sizeName],
    namespace: app.namespace,
    ociChartURL: 'ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set',
    targetRevision: '0.14.2',
    valuesObject: {
      controllerServiceAccount: {
        namespace: 'arc-systems',
        name: 'actions-runner-controller-gha-rs-controller',
      },
      githubConfigUrl: repo.url,
      githubConfigSecret: 'arc-secret',
      minRunners: 0,
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
      template: {
        spec: {
          automountServiceAccountToken: false,
          nodeSelector: {
            'kubernetes.io/arch': 'amd64',
          },
          resources: {
            requests: {
              cpu: size.cpuRequest,
              memory: size.memoryRequest,
            },
            limits: {
              cpu: size.cpuLimit,
              memory: size.memoryLimit,
            },
          },
          initContainers: [
            {
              name: 'init-dind-externals',
              image: 'ghcr.io/walnuts1018/infra/actions-runner:2.336.0',
              command: ['cp', '-r', '/home/runner/externals/.', '/home/runner/tmpDir/'],
              volumeMounts: [
                { name: 'dind-externals', mountPath: '/home/runner/tmpDir' },
              ],
            },
            {
              name: 'dind',
              image: 'docker:dind',
              args: [
                'dockerd',
                '--host=unix:///var/run/docker.sock',
                '--group=$(DOCKER_GROUP_GID)',
              ],
              env: [
                { name: 'DOCKER_GROUP_GID', value: '123' },
              ],
              securityContext: {
                privileged: true,
              },
              restartPolicy: 'Always',
              startupProbe: {
                exec: { command: ['docker', 'info'] },
                initialDelaySeconds: 0,
                failureThreshold: 24,
                periodSeconds: 5,
              },
              volumeMounts: [
                { name: 'work', mountPath: '/home/runner/_work' },
                { name: 'dind-sock', mountPath: '/var/run' },
                { name: 'dind-externals', mountPath: '/home/runner/externals' },
                { name: 'docker-storage', mountPath: '/var/lib/docker' },
              ],
            },
          ],
          containers: [
            {
              name: 'runner',
              image: 'ghcr.io/walnuts1018/infra/actions-runner:2.336.0',
              imagePullPolicy: 'Always',  // TODO: 消す
              command: ['/home/runner/run.sh'],
              env: [
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
                {
                  name: 'DOCKER_HOST',
                  value: 'unix:///var/run/docker.sock',
                },
                {
                  name: 'RUNNER_WAIT_FOR_DOCKER_IN_SECONDS',
                  value: '120',
                },
                {
                  name: 'CUSTOM_ACTIONS_RESULTS_URL',
                  value: 'http://gha-cache-server-github-actions-cache-server.arc-systems.svc.cluster.local:3000/',
                },
              ],
              volumeMounts: [
                { name: 'work', mountPath: '/home/runner/_work' },
                { name: 'dind-sock', mountPath: '/var/run' },
              ],
            },
          ],
          volumes: [
            { name: 'work', emptyDir: {} },
            { name: 'dind-sock', emptyDir: {} },
            { name: 'dind-externals', emptyDir: {} },
            { name: 'docker-storage', emptyDir: {} },
          ],
        },
      },
    },
  };

{
  generate(repos):: std.flattenArrays([
    [
      makeRunnerSet(repo, sizeName, repo.sizes[sizeName])
      for sizeName in std.objectFields(repo.sizes)
    ]
    for repo in repos
  ]),
}
