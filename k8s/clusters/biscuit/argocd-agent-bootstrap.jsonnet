local flatten = import '../../components/flatten-resources.libsonnet';
local bootstrap = import '../_components/argocd-agent-bootstrap.libsonnet';
local cluster = import 'cluster.json5';
local ciliumBaseValues = std.parseYaml(importstr '../../apps/cilium/values.biscuit.yaml');

flatten(bootstrap(cluster, ciliumBaseValues))
