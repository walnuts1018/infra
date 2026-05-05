{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
  },
  spec: {
    template: {
      spec: {
        image: 'https://cloud-images.ubuntu.com/releases/resolute/release/unpacked/ubuntu-26.04-server-cloudimg-amd64-vmlinuz-generic',
        initrd: 'https://cloud-images.ubuntu.com/releases/resolute/release/unpacked/ubuntu-26.04-server-cloudimg-amd64-initrd-generic',
        kernelParams: [
          'console=ttyS0',
          'ip=dhcp',
          'autoinstall',
          'ds=nocloud-net;s=http://tart.local.walnuts.dev/metadata',
        ],
      },
    },
  },
}
