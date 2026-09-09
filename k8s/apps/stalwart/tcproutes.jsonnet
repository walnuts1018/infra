local routes = import 'tcproutes.libsonnet';

[
  routes.smtp,
  routes.smtps,
  routes.submission,
  routes.imaps,
]
