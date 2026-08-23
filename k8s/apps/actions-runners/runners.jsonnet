local runners = import 'runners.libsonnet';
runners.generate([
  {
    name: 'picca',
    url: 'https://github.com/walnuts1018/picca',
    runners: [
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
        name: 'medium-amd64',
        cpu: '1',
        memory: '1Gi',
        arch: 'amd64',
        maxRunners: 1,
      },
      {
        name: 'highmem-xlarge-amd64',
        cpu: '300m',
        memory: '8Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
      {
        name: 'xlarge-amd64',
        cpu: '1.5',
        memory: '8Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
    ],
  },
])
