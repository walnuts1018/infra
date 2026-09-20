local flatten = import '../../components/flatten-resources.libsonnet';
local stack = import '../_components/tart-worker-stack.libsonnet';
local cluster = import 'cluster.json5';

flatten(stack(cluster, 'worker', {
  hostSelectorLabels: { 'kurumi.walnuts.dev/pool': 'worker' },
  // control planeと同じschematic(Longhorn用のiscsi-tools, util-linux-tools)を使う。
  schematicID: '613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245',
  patches: importstr '_patches/worker.yaml',
  replicas: cluster.workerMachineCount,
}))
