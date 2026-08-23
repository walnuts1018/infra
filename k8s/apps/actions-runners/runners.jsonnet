local runners = import 'runners.libsonnet';
runners.generate([
  {
    name: 'picca',
    url: 'https://github.com/walnuts1018/picca',
    runners: [
      {
        name: 'nano',
        cpu: '100m',
        memory: '256Mi',
        arch: 'amd64',
        maxRunners: 3,
      },
      {
        name: 'small',
        cpu: '500m',
        memory: '512Mi',
        arch: 'amd64',
        maxRunners: 3,
      },
      {
        name: 'medium',
        cpu: '1',
        memory: '1Gi',
        arch: 'amd64',
        maxRunners: 1,
      },
      {
        name: 'memory-xlarge',
        cpu: '300m',
        memory: '8Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
      {
        name: 'xlarge',
        cpu: '1.5',
        memory: '8Gi',
        arch: 'amd64',
        maxRunners: 2,
      },
    ],
  },
])
