local flatten = import '../../../components/flatten-resources.libsonnet';
local ocr = import '../../../components/picca/ai-services/ocr.libsonnet';
local app = import '../app.json5';

flatten(ocr(app))
