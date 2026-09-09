local flatten = import '../../../components/flatten-resources.libsonnet';
local dense = import '../../../components/picca/ai-services/dense.libsonnet';
local app = import '../app.json5';

flatten(dense(app))
