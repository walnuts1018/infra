local flatten = import '../../components/flatten-resources.libsonnet';
local bootstrap = import '../_components/argocd-agent-bootstrap.libsonnet';
local cluster = import 'cluster.json5';
local ciliumValues = (import '../_components/_internal/cilium-values.libsonnet')(cluster.name);

flatten(bootstrap(cluster, ciliumValues))
