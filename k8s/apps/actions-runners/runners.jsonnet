local runners = import 'runners.libsonnet';
runners.generate([
  {
    name: 'picca',
    url: 'https://github.com/walnuts1018/picca',
    sizes: {
      small: {
        maxRunners: 5,
      },
      large: {
        maxRunners: 2,
      },
    },
  },
])
