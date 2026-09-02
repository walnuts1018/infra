local flatten = import '../../../components/flatten-resources.libsonnet';
local worker = import '../../../components/picca/workers/video-processing/all.libsonnet';
local app = import '../app.json5';

flatten(worker(app))
