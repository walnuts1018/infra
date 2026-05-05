{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
  },
  spec: {
    template: {
      spec: {
        image: 'http://cloud-images.ubuntu.com/releases/resolute/release/unpacked/ubuntu-26.04-server-cloudimg-amd64-vmlinuz-generic',
        initrd: 'http://cloud-images.ubuntu.com/releases/resolute/release/unpacked/ubuntu-26.04-server-cloudimg-amd64-initrd-generic',
        bootstrap: {
          format: 'NoCloud',
        },
        kernelParams: [
          'console=ttyS0',
          'ip=dhcp',
          'autoinstall',
        ],
      },
    },
  },
}
