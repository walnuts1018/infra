local flatten = import '../../components/flatten-resources.libsonnet';
local stack = import '../_components/tart-control-plane-stack.libsonnet';
local cluster = import 'cluster.json5';

flatten(stack(cluster, {
  controlPlaneEndpointHost: '192.168.0.15',
  controlPlaneEndpointPort: 6443,
  hostSelectorLabels: { 'infrastructure.cluster.x-k8s.io/host-name': 'eclair' },
  schematicID: '376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba',
  patches: importstr '_patches/control-plane.yaml',
}))
