local runners = import 'runners.libsonnet';
runners.generate([
  {
    name: 'picca',
    url: 'https://github.com/walnuts1018/picca',
    runners: [
      {
        name: 'standard-nano-amd64',
        cpu: '250m',
        memory: '256Mi',
        arch: 'amd64',
        maxRunners: 5,
      },
      {
        name: 'standard-small-amd64',
        cpu: '500m',
        memory: '512Mi',
        arch: 'amd64',
        maxRunners: 3,
      },
      {
        name: 'highmem-medium-amd64',
        cpu: '1',
        memory: '2Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
      {
        name: 'highcpu-medium-amd64',
        cpu: '2',
        memory: '2Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
    ],
  },
])
