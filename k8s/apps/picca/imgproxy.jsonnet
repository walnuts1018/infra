local flatten = import '../../components/flatten-resources.libsonnet';
local imgproxy = import '../../components/picca/imgproxy/all.libsonnet';
local app = import 'app.json5';

flatten(imgproxy(app))
