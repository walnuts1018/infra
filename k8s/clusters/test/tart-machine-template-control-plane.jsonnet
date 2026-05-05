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
          'console=tty0',
          'ip=dhcp',
          'boot=casper',
          'autoinstall',
          'url=http://ftp.riken.go.jp/Linux/ubuntu-releases/26.04/ubuntu-26.04-live-server-amd64.iso',
        ],
      },
    },
  },
}
