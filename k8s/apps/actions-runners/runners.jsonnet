local runners = [
  {
    name: 'nano-amd64',
    cpu: '100m',
    memory: '256Mi',
    arch: 'amd64',
    maxRunners: 3,
  },
  {
    name: 'small-amd64',
    cpu: '500m',
    memory: '512Mi',
    arch: 'amd64',
    maxRunners: 3,
  },
  {
    name: 'large-amd64',
    cpu: '2',
    memory: '4Gi',
    arch: 'amd64',
    maxRunners: 2,
  },
  {
    name: 'xlarge-amd64',
    cpu: '4',
    memory: '8Gi',
    arch: 'amd64',
    maxRunners: 2,
  },
];

local app = import 'app.json5';
local githubAppSecret = import 'github-app-secret.jsonnet';
[
  {
    apiVersion: 'sharc.walnuts.dev/v1alpha1',
    kind: 'RunnerScaleSet',
    metadata: {
      name: 'arc-picca-%s' % runner.name,
      namespace: app.namespace,
    },
    spec: {
      github: {
        configURL: 'https://github.com/walnuts1018/picca',
        scaleSetName: 'arc-picca-%s' % runner.name,
        runnerGroup: 'default',
        credentialsSecretRef: {
          name: githubAppSecret.spec.target.name,
        },
      },
      nodePoolRef: {
        name: (import 'nodepool.jsonnet').metadata.name,
      },
      scaling: {
        minRunners: 0,
        maxRunners: runner.maxRunners,
      },
      runner: {
        containerMode: 'dind',
        dind: {
          image: 'docker:29.7.2-dind',
          dockerGroupGID: '123',
          mtu: '1280',
        },
        metrics: {
          enabled: false,
        },
        template: {
          spec: {
            resources: {
              requests: {
                cpu: runner.cpu,
                memory: runner.memory,
              },
              limits: {
                cpu: runner.cpu,
                memory: runner.memory,
              },
            },
            automountServiceAccountToken: false,
            enableServiceLinks: false,
            restartPolicy: 'Never',
            nodeSelector: {
              'kubernetes.io/arch': runner.arch,
            },
            containers: [
              {
                name: 'runner',
                image: 'ghcr.io/walnuts1018/infra/actions-runner:2.336.0',
                command: ['/home/runner/run.sh'],
                env: [
                  { name: 'DOTNET_gcServer', value: '0' },
                  { name: 'DOTNET_GCHeapHardLimit', value: '0x10000000' },
                  { name: 'DOTNET_GCConserveMemory', value: '9' },
                  { name: 'DOTNET_TieredPGO', value: '0' },
                  { name: 'MALLOC_ARENA_MAX', value: '2' },
                  { name: 'CUSTOM_ACTIONS_RESULTS_URL', value: 'https://gha-cache-server.local.walnuts.dev/' },
                ],
              },
            ],
          },
        },
      },
    },
  }
  for runner in runners
]
