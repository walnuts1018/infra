local flatten = import '../../../components/flatten-resources.libsonnet';
local ocrVl = import '../../../components/picca/ai-services/ocr-vl.libsonnet';
local app = import '../app.json5';

flatten(ocrVl(app))
