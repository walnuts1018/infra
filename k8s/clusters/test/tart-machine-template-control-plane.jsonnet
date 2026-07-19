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
          ref: 'oci://ghcr.io/walnuts1018/cluster-api-provider-tart-os-ubuntu-26.04-amd64-kubeadm@sha256:3b7e24ec5c4d5c08979d19a5c2f214b760477a4031942f2781bca0ea3b10f233',
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
