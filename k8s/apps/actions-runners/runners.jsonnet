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
        name: 'large-amd64',
        cpu: '2',
        memory: '4Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
      {
        name: 'xlarge-amd64',
        cpu: '3',
        memory: '8Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
    ],
  },
])
