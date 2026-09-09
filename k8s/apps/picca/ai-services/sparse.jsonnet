local flatten = import '../../../components/flatten-resources.libsonnet';
local sparse = import '../../../components/picca/ai-services/sparse.libsonnet';
local app = import '../app.json5';

flatten(sparse(app))
