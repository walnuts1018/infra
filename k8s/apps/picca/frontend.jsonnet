local flatten = import '../../components/flatten-resources.libsonnet';
local frontend = import '../../components/picca/frontend.libsonnet';
local app = import 'app.json5';

flatten(frontend(app))
