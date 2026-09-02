local flatten = import '../../components/flatten-resources.libsonnet';
local apiserver = import '../../components/picca/apiserver.libsonnet';
local app = import 'app.json5';

flatten(apiserver(app))
