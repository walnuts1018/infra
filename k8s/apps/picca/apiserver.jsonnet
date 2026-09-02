local flatten = import '../../components/flatten-resources.libsonnet';
local apiserver = import '../../components/picca/apiserver/all.libsonnet';
local app = import 'app.json5';

flatten(apiserver(app))
