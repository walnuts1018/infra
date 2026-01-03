local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

local resources = helm.template((import 'app.json5').name, '../../charts/zitadel', {
  namespace: (import 'app.json5').namespace,
  values: std.parseYaml(importstr 'values.yaml'),
});

std.objectValues(resources)
