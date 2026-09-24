local flatten = import '../../../components/flatten-resources.libsonnet';
local worker = import '../../../components/picca/workers/empty-trash.libsonnet';
local app = import '../app.json5';

flatten(worker(app))
