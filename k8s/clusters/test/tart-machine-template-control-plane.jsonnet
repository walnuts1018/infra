{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
  },
  spec: {
    template: {
      spec: {
        image: 'http://seaweedfs.local.walnuts.dev/iso/ubuntu-26.04-live-server-amd64/vmlinuz',
        initrd: 'http://seaweedfs.local.walnuts.dev/iso/ubuntu-26.04-live-server-amd64/initrd',
        bootstrap: {
          format: 'NoCloud',
        },
        kernelParams: [
          'console=tty0',
          'ip=dhcp',
          'autoinstall',
          'url=http://seaweedfs.local.walnuts.dev/iso/ubuntu-26.04-live-server-amd64/image.iso',
        ],
      },
    },
  },
}
