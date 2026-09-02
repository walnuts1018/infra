local flatten = import '../../../components/flatten-resources.libsonnet';
local caption = import '../../../components/picca/ai-services/caption.libsonnet';
local app = import '../app.json5';

flatten(caption(app))
