local flatten = import '../../components/flatten-resources.libsonnet';
local sharedInfra = import '../../components/picca/shared-infra.libsonnet';
local app = import 'app.json5';

flatten(sharedInfra(app, useSuffix=false))
