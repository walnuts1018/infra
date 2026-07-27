{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1beta1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
  },
  spec: {
    template: {
      spec: {
        image: {
          ref: 'oci://ghcr.io/walnuts1018/cluster-api-provider-tart-os-ubuntu-26.04-amd64-kubeadm@sha256:cb0d1c44c1d29626ad95476a29d6bae7230fdc26698ee40f053e7de4e1a402ad
',
        },
        platformProfile: 'amd64-uefi-ab-ubuntu-26.04-kubeadm/v1',
        updatePolicy: {
          mode: 'Replace',
        },
        deletionPolicy: 'WipeAll',
      },
    },
  },
}
