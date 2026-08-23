local runners = import 'runners.libsonnet';
runners.generate([
  {
    name: 'picca',
    url: 'https://github.com/walnuts1018/picca',
    sizes: {
      'standard-nano-amd64': {
        maxRunners: 5,
      },
      'standard-small-amd64': {
        maxRunners: 3,
      },
      'highmem-medium-amd64': {
        maxRunners: 2,
      },
      'highcpu-medium-amd64': {
        maxRunners: 2,
      },
    },
  },
])
