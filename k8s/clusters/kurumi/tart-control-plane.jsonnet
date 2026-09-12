local flatten = import '../../components/flatten-resources.libsonnet';
local stack = import '../_components/tart-control-plane-stack.libsonnet';
local cluster = import 'cluster.json5';

// control planeのVIP。TalosネイティブのBGP機能(BGPInstanceConfig + DummyLinkConfig、
// _patches/control-plane.yaml参照)で3台のcontrol planeノードから同時に192.168.4.11/32を
// vyosへBGP広告する(ECMP)。kube-vipは使わない(Talosにはkubeadmのような使い回せるadmin
// kubeconfigがなく、kube-vipのKubernetes Lease経由leader electionと相性が悪いため)。
flatten(stack(cluster, {
  controlPlaneEndpointHost: '192.168.4.11',
  controlPlaneEndpointPort: 6443,
  hostSelectorLabels: { 'kurumi.walnuts.dev/pool': 'control-plane' },
  // Longhornが要求するsystem extension(iscsi-tools, util-linux-tools)を含むschematic。
  // https://factory.talos.dev/schematics へPOSTして生成(2026-09-11時点)。
  schematicID: '613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245',
  patches: importstr '_patches/control-plane.yaml',
}))
